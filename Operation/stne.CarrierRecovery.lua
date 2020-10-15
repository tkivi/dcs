local Cfg = {
--#################################################################################################
--
--  CarrierRecovery
--
--  Carrier recovery with turn to wind and client detection.
--  Optional rescue helicopter, AWACS and recovery tanker.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = true,                               -- Debug mode, true/false
    Carrier = {
        Group = 'CSG-1_PRC',                    -- Carrier name, GROUP
        Unit = 'CVN-73',                        -- Carrier name, UNIT
        TACAN = {73, 'X', 'DUB'},               -- Carrier TACAN {Channel, Mode, Message}
        ICLS = {3, 'ILS'},                      -- Carrier ICLS {Channel, Message}
        WindOverDeck = 30,                      -- Carrier wind over deck in knots
    },
    Rescue = {
        Enable = false,                         -- Rescue helicopter enable, true/false
        Group = 'ANGEL 1-1',                    -- Rescue helicopter name, GROUP
        AirStart = false,                       -- Rescue helicopter start in air, true/false
    },
    AWACS = {
        Enable = false,                         -- AWACS enable, true/false
        Group = 'AWACS_Group',                  -- AWACS name, GROUP
        AirStart = false,                       -- AWACS start in air, true/false
        Radio = 270,                            -- AWACS radio Mhz (AM)
        Speed = 275,                            -- AWACS true air speed (TAS) in knots
        Alt = 16000,                            -- AWACS alt in feet
    },
    Tanker = {
        Enable = false,                         -- Tanker enable, true/false
        Group = 'Tanker_Group',                 -- Tanker name, GROUP
        AirStart = false,                       -- Tanker start in air, true/false
        TACAN = {10, 'TKR'},                    -- Tanker TACAN mode Y {Channel, Message}
        Radio = 260,                            -- Tanker radio Mhz (AM)
        Speed = 275,                            -- Tanker true air speed (TAS) in knots
        Alt = 6000,                             -- Tanker alt in feet
    },
    ClientRange = 27780,                        -- Speed up carrier speed if client distance is lower than this, in meters
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.CarrierRecovery.lua'
local Version = '201015'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_CarrierRecovery then
    for key, value in pairs(STNE_Config_CarrierRecovery) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local Carrier = Cfg.Carrier
local Rescue = Cfg.Rescue
local AWACS = Cfg.AWACS
local Tanker = Cfg.Tanker
local ClientRange = Cfg.ClientRange

-- Local variables
local TurnToWindScheduler = 60
local InitRecoverPlanes = false
local Debug2 = false

--- Carrier rescue helicopter
local function CarrierRescue()
    if Rescue.Enable then
        if Debug then BASE:E({FileVer,Rescue=Rescue.Enable,Group=Rescue.Group}) end
        local CarrierRescue = RESCUEHELO:New(UNIT:FindByName(Carrier.Unit), Rescue.Group)
        if Rescue.AirStart then
            CarrierRescue:SetTakeoffAir()
        else
            CarrierRescue:SetTakeoffCold()
        end
        if Debug2 then CarrierRescue:SetDebugModeON() end
        CarrierRescue:Start()
    else
        if Debug then BASE:E({FileVer,Rescue=Rescue.Enable}) end
    end
end

--- Carrier AWACS
local function CarrierAWACS()
    if AWACS.Enable then
        if Debug then BASE:E({FileVer,AWACS=AWACS.Enable,Group=AWACS.Group,Radio=AWACS.Radio,Speed=AWACS.Speed,Alt=AWACS.Alt}) end
        local CarrierAWACS = RECOVERYTANKER:New(UNIT:FindByName(Carrier.Unit), AWACS.Group)
        CarrierAWACS:SetAWACS()
        CarrierAWACS:SetTACANoff()
        CarrierAWACS:SetRadio(AWACS.Radio)
        CarrierAWACS:SetSpeed(AWACS.Speed)
        CarrierAWACS:SetAltitude(AWACS.Alt)
        if AWACS.AirStart then
            CarrierAWACS:SetTakeoffAir()
        else
            CarrierAWACS:SetTakeoffCold()
        end
        if Debug2 then CarrierAWACS:SetDebugModeON() end
        CarrierAWACS:Start()
    else
        if Debug then BASE:E({FileVer,AWACS=AWACS.Enable}) end
    end
end

--- Carrier recovery tanker
local function CarrierTanker()
    if Tanker.Enable then
        local Channel = Tanker.TACAN[1]
        local Message = Tanker.TACAN[2]
        if Debug then BASE:E({FileVer,Tanker=Tanker.Enable,Group=Tanker.Group,Radio=Tanker.Radio,Speed=Tanker.Speed,Alt=Tanker.Alt,Channel=Channel,Message=Message}) end
        local CarrierTanker = RECOVERYTANKER:New(UNIT:FindByName(Carrier.Unit), Tanker.Group)
        CarrierTanker:SetTACAN(Channel, Message)
        CarrierTanker:SetRadio(Tanker.Radio)
        CarrierTanker:SetSpeed(Tanker.Speed)
        CarrierTanker:SetAltitude(Tanker.Alt)
        if Tanker.AirStart then
            CarrierTanker:SetTakeoffAir()
        else
            CarrierTanker:SetTakeoffCold()
        end
        if Debug2 then CarrierTanker:SetDebugModeON() end
        CarrierTanker:Start()
    else
        if Debug then BASE:E({FileVer,Tanker=Tanker.Enable}) end
    end
end

--- Turn carrier to wind
--- @param WindOverDeckSpeed boolean
local function TurnToWind(WindOverDeckSpeed)
    if Debug then BASE:E({FileVer,'TurnToWind',WindOverDeckSpeed=WindOverDeckSpeed}) end
    local CarrierGrp = GROUP:FindByName(Carrier.Group)
    local CarrierUnit = UNIT:FindByName(Carrier.Unit)
    local WindOverDeckMps = UTILS.KnotsToMps(Carrier.WindOverDeck)
    local SpeedKmph = 1
    local Carrier_Unit_Hdg = CarrierUnit:GetHeading()
    local Coord = CarrierUnit:GetCoordinate()
    local Direction, Strength = Coord:GetWind(UTILS.FeetToMeters(170))
    if Strength < WindOverDeckMps and WindOverDeckSpeed then
        local NewSpeed = WindOverDeckMps - Strength
        SpeedKmph = UTILS.MpsToKmph(NewSpeed)
    end
    local ToCoord = Coord:Translate(50000, Direction)
    if Direction > Carrier_Unit_Hdg + 5 or Direction < Carrier_Unit_Hdg - 5 then
        SpeedKmph = UTILS.KnotsToKmph(20)
    end
    CarrierGrp:RouteGroundTo(ToCoord, SpeedKmph, 'Off Road', 1)
end

--- Check if client is near carrier
--- @param Client table
local function IsClientInRange(Client)
    if Client ~= nil then
        local Carrier = GROUP:FindByName(Carrier.Group)
        if Carrier ~= nil and Carrier:IsAlive() then
            local CarrierCoord = Carrier:GetCoordinate()
            local ClientCoord = Client:GetCoordinate()
            local Distance = ClientCoord:Get2DDistance(CarrierCoord)
            if Debug then BASE:E({FileVer,Client=Client:GetName(),Carrier=Carrier.Group,Distance=math.floor(Distance),InRange=Distance<=ClientRange}) end
            if Distance <= ClientRange then
                return true
            end
        end
    end
    return false
end

--- Set carrier TACAN
--- @param CarrierUnit table
local function SetCarrierTACAN(CarrierUnit)
    local Channel = Carrier.TACAN[1]
    local Mode = Carrier.TACAN[2]
    local Message = Carrier.TACAN[3]
    if Debug then BASE:E({FileVer,'SetCarrierTACAN',Channel=Channel,Mode=Mode,Message=Message}) end
    local CarrierBeacon = CarrierUnit:GetBeacon()
    CarrierBeacon:ActivateTACAN(Channel, Mode, Message, true)
end

--- Set carrier ICLS
--- @param CarrierUnit table
local function SetCarrierICLS(CarrierUnit)
    local Channel = Carrier.ICLS[1]
    local Message = Carrier.ICLS[2]
    if Debug then BASE:E({FileVer,'SetCarrierICLS',Channel=Channel,Message=Message}) end
    local CarrierBeacon = CarrierUnit:GetBeacon()
    CarrierBeacon:ActivateICLS(Channel, Message)
end

-- Carrier TACAN/ICLS scheduler
SCHEDULER:New(nil, function()
    local CarrierUnit = UNIT:FindByName(Carrier.Unit)
    if CarrierUnit ~= nil and CarrierUnit:IsAlive() then
        SetCarrierTACAN(CarrierUnit)
        SetCarrierICLS(CarrierUnit)
    end
end, {}, 10, 1200)

-- TurnToWind scheduler
SCHEDULER:New(nil, function()
    if Debug then BASE:E({FileVer,TurnToWindScheduler=TurnToWindScheduler}) end
    local InRange = false
    local ClientSet = SET_CLIENT:New()
    ClientSet:FilterActive()
    ClientSet:FilterOnce()
    ClientSet:ForEachClient(
        function(Client)
            if Client ~= nil and Client:IsAlive() and not InRange then
                InRange = IsClientInRange(Client)
            end
        end
    )
    -- Carrier turn to wind
    TurnToWind(InRange)
    -- Initialize recovery planes
    if InRange then
        if not InitRecoverPlanes then
            InitRecoverPlanes = true
            CarrierRescue()
            CarrierAWACS()
            CarrierTanker()
        end
    end
end, {}, 10, TurnToWindScheduler)

-- EOF
env.info('FILE: '..FileVer..' END')
