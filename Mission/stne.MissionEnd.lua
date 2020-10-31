local Cfg = {
--#################################################################################################
--
--  MissionEnd
--
--  Mission end timer with warnings.
--  Overtime to give more time for clients to land. (optional)
--  Expedite mission end when no activity. (optional)
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                      -- Debug mode, true/false
    EndFlag = 666,                                      -- Mission end flag
    MissionTime = 18000,                                -- Time to set mission end flag true, in seconds
    OverTime = 900,                                     -- Extra time for clients to land (0 = disabled), in seconds
    ExpediteTime = 2100,                                -- Expedite mission end time if no clients alive (0 = disabled), in seconds
    Warnings = {                                        -- Warning timers before mission end, in seconds
        3600,
        1800,
        900,
        600,
        300,
        60,
        30,
        10,
    },
    SoundFolder = 'Sounds',                             -- (optional) Sounds folder, in .miz file
    SoundFile = 'Digibeep.ogg',                         -- (optional) Message sound file, in sounds folder
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.MissionEnd.lua'
local Version = '201031'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_MissionEnd then
    for key, value in pairs(STNE_Config_MissionEnd) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local EndFlag = Cfg.EndFlag
local MissionTime = Cfg.MissionTime
local OverTime = Cfg.OverTime
local ExpediteTime = Cfg.ExpediteTime
local WarningTimes = Cfg.Warnings
local SoundFolder = Cfg.SoundFolder
local SoundFile = Cfg.SoundFile

-- Cliet set
local Set_Client = SET_CLIENT:New()
Set_Client:FilterActive()
Set_Client:FilterStart()

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Flags == nil then STNE.Flags = {} end
STNE.Flags.MissionEnd = EndFlag

-- Local variables
local Time0 = timer.getTime0()

-- Sound file
local MessageSound = nil
if SoundFile ~= nil then
    local FFile = SoundFile
    if SoundFolder ~= nil then
        FFile = SoundFolder..'/'..SoundFile
    end
    MessageSound = USERSOUND:New(FFile)
    if Debug then BASE:E({FileVer,SoundFile=FFile}) end
end

--- Set end flag true
local function SetEndFlag()
    if Debug then BASE:E({FileVer,SetEndFlag=STNE.Flags.MissionEnd}) end
    trigger.action.setUserFlag(STNE.Flags.MissionEnd, 1)
end

--- Send error message
--- @param MessageText string
local function SendError(MessageText)
    local ErrorMsg = 'ERROR: '..FileVer..' '..MessageText
    MESSAGE:New(ErrorMsg, 300):ToAll()
    env.info(ErrorMsg)
end

--- Send message to all
--- @param MessageText string
--- @param Duration number
--- @param ClearOld boolean
--- @param UseSound boolean
local function SendMessage(MessageText, Duration, ClearOld, UseSound)
    local Dur = Duration or 15
    local Clr = ClearOld or false
    local Snd = UseSound or false
    if Debug then BASE:E({FileVer,SendMessage=MessageText,Duration=Dur,ClearOld=Clr,UseSound=Snd}) end
    MESSAGE:New(MessageText, Dur, nil, Clr):ToAll()
    if MessageSound and Snd == true then
        MessageSound:ToAll()
    end
end

--- Round number to nearest integer
--- @param Number number
local function RoundNumber(Number)
    local Lower = math.floor(Number)
    local Upper = math.ceil(Number)
    if (Number - Lower) < (Upper - Number) then
        return Lower
    else
        return Upper
    end
end

--- Convert seconds to string
--- @param Seconds number
local function SecondsToString(Seconds)
    local Message = ''
    if Seconds > 60 then
        Seconds = RoundNumber(Seconds / 60)
        Message = Message..tostring(Seconds)..' minute(s)'
    else
        Seconds = RoundNumber(Seconds)
        Message = Message..tostring(Seconds)..' second(s)'
    end
    return Message
end

-- Warning time scheduler
for _, WarningTime in pairs(WarningTimes) do
    if WarningTime < MissionTime then
        SCHEDULER:New(nil, function()
            SendMessage('MISSION END: Time left '..SecondsToString(WarningTime), nil, nil, true)
        end, {WarningTime}, MissionTime - WarningTime)
    end
end

--- Check if client is on water
--- @param Coord table
local function ClientOnWater(Client)
    local Coord = Client:GetCoordinate()
    if Coord:IsSurfaceTypeShallowWater() or Coord:IsSurfaceTypeWater() then
        return true
    else
        return false
    end
end

--- Is all alive clients landed and not taxiing
local function IsAllClientsLanded()
    local AllClientsLanded = true
    local ClientNamesInAir = {}
    local ClientNamesInTaxi = {}
    Set_Client:ForEachClient(
        function(Client)
            if Client ~= nil and Client:IsAlive() then
                local ClientName = Client:GetPlayerName()
                if ClientName ~= nil then
                    if Client:InAir() == true then
                        table.insert(ClientNamesInAir, ClientName)
                        AllClientsLanded = false
                    elseif Client:InAir() == false and Client:GetVelocityKNOTS() >= 1 and ClientOnWater(Client) == false then
                        table.insert(ClientNamesInTaxi, ClientName)
                        AllClientsLanded = false
                    end
                end
            end
        end
    )
    if Debug then BASE:E({FileVer,Landed=AllClientsLanded,InAir=ClientNamesInAir,Taxiing=ClientNamesInTaxi}) end
    return AllClientsLanded, ClientNamesInAir, ClientNamesInTaxi
end

--- Is all clients dead or spectating
local function IsAllClientsDead()
    local AllClientsDead = true
    Set_Client:ForEachClient(
        function(Client)
            if Client ~= nil and Client:IsAlive() then
                AllClientsDead = false
            end
        end
    )
    if Debug then BASE:E({FileVer,AllClientsDead=AllClientsDead}) end
    return AllClientsDead
end

-- Expedite mission end scheduler
if ExpediteTime > 0 then
    if ExpediteTime > MissionTime then
        SendError('ExpediteTime value too high')
    else
        local TimeFrame = 300
        local TimeStamp = nil
        SCHEDULER:New(nil, function()
            local AbsTime = timer.getAbsTime()
            local TimeLeft = MissionTime - (AbsTime - Time0)
            local RestartTime = TimeLeft
            local AllClientsDead = IsAllClientsDead()
            if AllClientsDead then
                if TimeStamp == nil then
                    TimeStamp = AbsTime
                end
                RestartTime = (TimeStamp + TimeFrame) - AbsTime
            else
                TimeStamp = nil
            end
            if TimeStamp ~= nil and RestartTime < TimeLeft then
                if RestartTime <= 0 then
                    SendMessage('MISSION END: Expedited mission end', nil, true, true)
                    SetEndFlag()
                else
                    SendMessage('MISSION END: Time left '..SecondsToString(TimeLeft)..'\nNo active players found.\nIf no activity in '..SecondsToString(RestartTime)..' -> Expedited mission end possible.', 55, nil, true)
                end
            end
        end, {}, MissionTime - ExpediteTime, 60, nil, MissionTime)
    end
end

-- Mission end and overtime scheduler
local ForceEndTime = nil
SCHEDULER:New(nil, function()
    local AllClientsLanded, ClientNamesInAir, ClientNamesInTaxi = IsAllClientsLanded()
    local AbsTime = timer.getAbsTime()
    if ForceEndTime == nil then
        ForceEndTime = AbsTime + OverTime
    end
    local OverTimeLeft = ForceEndTime - AbsTime
    if AllClientsLanded or OverTimeLeft <= 0 then
        SendMessage('MISSION END: Mission end', nil, true, true)
        SetEndFlag()
    else
        local MessageText = 'MISSION END: Overtime left '..SecondsToString(OverTimeLeft)..', expedite landing !'
        if #ClientNamesInAir > 0 then
            for _, ClientName in pairs(ClientNamesInAir) do
                MessageText = MessageText..'\nPlayers airborne:'
                MessageText = MessageText..'\n - '..ClientName
            end
        end
        if #ClientNamesInTaxi > 0 then
            for _, ClientName in pairs(ClientNamesInTaxi) do
                MessageText = MessageText..'\nPlayers taxiing on ground:'
                MessageText = MessageText..'\n - '..ClientName
            end
        end
        SendMessage(MessageText, 10, true, false)
    end
end, {}, MissionTime, 10)

-- EOF
env.info('FILE: '..FileVer..' END')
