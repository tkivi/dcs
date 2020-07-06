local Cfg = {
--#################################################################################################
--
--	CarrierRecovery
--
--	Simple carrier recovery with turn to wind.
--  Optional rescue helicopter, AWACS and recovery tanker.
--
--	https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                              -- Debug mode, true/false
    Carrier_Group = 'Carrier_Group',            -- Carrier name, GROUP
    Carrier_Unit = 'Carrier_Unit',              -- Carrier name, UNIT
    Carrier_TACAN = {107, 'X', 'GRW'},          -- Carrier TACAN (Channel, Mode, Message)
    Carrier_ICLS = {7, 'GRW'},                  -- Carrier ICLS (Channel, Message)
    Carrier_WOD = 25,                           -- Carrier wind over deck in knots
    Rescue_Enable = true,                       -- Rescue helicopter enable, true/false
    Rescue_Group = 'Rescue_Group',              -- Rescue helicopter name, GROUP
    AWACS_Enable = true,                        -- AWACS enable, true/false
    AWACS_Group = 'AWACS_Group',                -- AWACS name, GROUP
    AWACS_Radio = 270,                          -- AWACS radio Mhz (AM)
    AWACS_Speed = 275,                          -- AWACS true air speed (TAS) in knots
    AWACS_Alt = 16000,                          -- AWACS alt in feet
    Tanker_Enable = true,                       -- Tanker enable, true/false
    Tanker_Group = 'Tanker_Group',              -- Tanker name, GROUP
    Tanker_TACAN = {10, 'TKR'},                 -- Tanker TACAN mode Y (Channel, Message)
    Tanker_Radio = 260,                         -- Tanker radio Mhz (AM)
    Tanker_Speed = 275,                         -- Tanker true air speed (TAS) in knots
    Tanker_Alt = 6000,                          -- Tanker alt in feet
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local FileNme = 'stne.CarrierRecovery.lua'
local Version = '1.0.0'
local FileMsg = FileNme..'/'..Version
env.info('FILE: '..FileMsg..' START')

-- Override configuration
if STNE_Config_CarrierRecovery then
    for key, value in pairs(STNE_Config_CarrierRecovery) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileMsg,Cfg=Cfg})
local Debug = Cfg.Debug
local Carrier_Group = GROUP:FindByName(Cfg.Carrier_Group)
local Carrier_Unit = UNIT:FindByName(Cfg.Carrier_Unit)
local Carrier_TACAN = Cfg.Carrier_TACAN
local Carrier_ICLS = Cfg.Carrier_ICLS
local Carrier_WODKnots = Cfg.Carrier_WOD
local Rescue_Enable = Cfg.Rescue_Enable
local Rescue_Group = Cfg.Rescue_Group
local AWACS_Enable = Cfg.AWACS_Enable
local AWACS_Group = Cfg.AWACS_Group
local AWACS_Radio = Cfg.AWACS_Radio
local AWACS_Speed = Cfg.AWACS_Speed
local AWACS_Alt = Cfg.AWACS_Alt
local Tanker_Enable = Cfg.Tanker_Enable
local Tanker_Group = Cfg.Tanker_Group
local Tanker_TACAN = Cfg.Tanker_TACAN
local Tanker_Radio = Cfg.Tanker_Radio
local Tanker_Speed = Cfg.Tanker_Speed
local Tanker_Alt = Cfg.Tanker_Alt

-- Show error if carrier UNIT or GROUP not found
if Carrier_Group == nil or Carrier_Unit == nil then
    local ErrorMsg = 'ERROR: '..FileMsg..' Missing carrier UNIT or GROUP'
    MESSAGE:New(ErrorMsg, 300):ToAll()
    env.info(ErrorMsg)
end

-- Carrier rescue helicopter
if Rescue_Enable then
    local Helo = RESCUEHELO:New(Carrier_Unit, Rescue_Group)
    Helo:SetTakeoffCold()
    if Debug then Helo:SetDebugModeON() end
    Helo:Start()
end

-- Carrier AWACS
if AWACS_Enable then
    local AWACS = RECOVERYTANKER:New(Carrier_Unit, AWACS_Group)
    AWACS:SetAWACS()
    AWACS:SetTACANoff()
    AWACS:SetRadio(AWACS_Radio)
    AWACS:SetSpeed(AWACS_Speed)
    AWACS:SetAltitude(AWACS_Alt)
    AWACS:SetTakeoffCold()
    if Debug then AWACS:SetDebugModeON() end
    AWACS:Start()
end

-- Carrier recovery tanker
if Tanker_Enable then
    local Tanker = RECOVERYTANKER:New(Carrier_Unit, Tanker_Group)
    Tanker:SetTACAN(Tanker_TACAN[1], Tanker_TACAN[2])
    Tanker:SetRadio(Tanker_Radio)
    Tanker:SetSpeed(Tanker_Speed)
    Tanker:SetAltitude(Tanker_Alt)
    Tanker:SetTakeoffCold()
    if Debug then Tanker:SetDebugModeON() end
    Tanker:Start()
end

-- Carrier TACAN/ICLS, refresh after 15 minutes
SCHEDULER:New(nil, function()
	local Carrier_Beacon = Carrier_Unit:GetBeacon()
	Carrier_Beacon:ActivateTACAN(Carrier_TACAN[1], Carrier_TACAN[2], Carrier_TACAN[3], true)
	Carrier_Beacon:ActivateICLS(Carrier_ICLS[1], Carrier_ICLS[2])
end, {}, 10, 900)

-- Carrier turn to wind, refresh after 3 minutes
SCHEDULER:New(nil, function()
	local WindOverDeckMps = UTILS.KnotsToMps(Carrier_WODKnots)
	local SpeedKmph = 1
	local Carrier_Unit_Hdg = Carrier_Unit:GetHeading()
	local Coord = Carrier_Group:GetCoordinate()
	local Direction, Strength = Coord:GetWind(UTILS.FeetToMeters(170))
	if Strength < WindOverDeckMps then
		local NewSpeed = WindOverDeckMps - Strength
		SpeedKmph = UTILS.MpsToKmph(NewSpeed)
	end
	local ToCoord = Coord:Translate(50000, Direction)
	if Direction > Carrier_Unit_Hdg + 5 or Direction < Carrier_Unit_Hdg - 5 then
		SpeedKmph = UTILS.KnotsToKmph(20)
	end
	Carrier_Group:RouteGroundTo(ToCoord, SpeedKmph, 'Off Road', 1)
end, {}, 10, 180)

-- EOF
env.info('FILE: '..FileMsg..' END')
