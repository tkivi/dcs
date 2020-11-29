local Cfg = {
--#################################################################################################
--
--  Statistics
--
--  Collect mission statistics.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.Statistics.lua'
local Version = '201129'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_Statistics then
    for key, value in pairs(STNE_Config_Statistics) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Save == nil then STNE.Save = {} end
if STNE.Save.Tables == nil then STNE.Save.Tables = {} end
if STNE.Save.Tables.Statistics == nil then STNE.Save.Tables.Statistics = {} end
if STNE.Save.Tables.Statistics.TimeTable == nil then STNE.Save.Tables.Statistics.TimeTable = {} end
if STNE.Save.Tables.Statistics.Count == nil then STNE.Save.Tables.Statistics.Count = {} end
if STNE.Save.Tables.Statistics.Count.Total == nil then STNE.Save.Tables.Statistics.Count.Total = {} end
STNE.Save.Tables.Statistics.Count.Current = {}

-- Eventhandler
--if STNE == nil then STNE = {} end
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.Statistics == nil then STNE.EventHandler.Statistics = {} end
STNE.EventHandler.Statistics = EVENTHANDLER:New()
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_SHOT) -- OnEventShot
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_HIT) -- OnEventHit
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_TAKEOFF) -- OnEventTakeoff
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_LAND) -- OnEventLand
STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_CRASH) -- OnEventCrash
STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_EJECTION) -- OnEventEjection
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_REFUELING) -- OnEventRefueling
STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_DEAD) --  OnEventDead
STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_PILOT_DEAD) -- OnEventPilotDead
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_BASE_CAPTURED) -- OnEventBaseCaptured
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_MISSION_START) -- OnEventMissionStart
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_MISSION_END) -- OnEventMissionEnd
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_TOOK_CONTROL) -- OnEventTookControl
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_REFUELING_STOP) -- OnEventRefuelingStop
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_BIRTH) -- OnEventBirth
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_HUMAN_FAILURE) -- OnEventHumanFailure
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_ENGINE_STARTUP) -- OnEventEngineStartup
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_ENGINE_SHUTDOWN) -- OnEventEngineShutdown
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_PLAYER_ENTER_UNIT) -- OnEventPlayerEnterUnit
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_PLAYER_LEAVE_UNIT) -- OnEventPlayerLeaveUnit
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_PLAYER_COMMENT) -- OnEventPlayerComment
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_SHOOTING_START) -- OnEventShootingStart
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_SHOOTING_END) -- OnEventShootingEnd
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_MARK_ADDED) -- OnEventMarkAdded
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_MARK_CHANGE) -- OnEventMarkChange
--STNE.EventHandler.Statistics:HandleEvent(world.event.S_EVENT_MARK_REMOVED) -- OnEventMarkRemoved
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.NewCargo) -- OnEventNewCargo
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.DeleteCargo) -- OnEventDeleteCargo
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.NewZone) -- OnEventNewZone
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.DeleteZone) -- OnEventDeleteZone
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.NewZoneGoal) -- OnEventNewZoneGoal
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.DeleteZoneGoal) -- OnEventDeleteZoneGoal
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.RemoveUnit) -- OnEventRemoveUnit
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.DetailedFailure) -- OnEventDetailedFailure
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.Kill) -- OnEventKill
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.Score) -- OnEventScore
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.UnitLost) -- OnEventUnitLost
--STNE.EventHandler.Statistics:HandleEvent(EVENTS.LandingAfterEjection) -- OnEventLandingAfterEjection

--- Add parsed EventData to STNE.Save.Tables.Statistics table
--- @param EventName string
--- @param GroupName string
--- @param UnitName string
--- @param Time number
--- @param PlayerName string
--- @param TypeName string
--- @param Coalition number
--- @param Latitude number
--- @param Longitude number
local function AddParsedDataToTable(EventName, GroupName, UnitName, Time, PlayerName, TypeName, Coalition, Latitude, Longitude)
    --if STNE.Save.Tables.Statistics['TimeTable'] == nil then STNE.Save.Tables.Statistics['TimeTable'] = {} end
    --STNE.Save.Tables.Statistics['TimeTable'][Time] = {EventName=EventName,PlayerName=PlayerName,GroupName=GroupName,UnitName=UnitName,TypeName=TypeName,Coalition=Coalition,Latitude=Latitude,Longitude=Longitude}

    if PlayerName ~= 'AI' then PlayerName = 'Players' end
    for Header, _ in pairs(STNE.Save.Tables.Statistics.Count) do
        if STNE.Save.Tables.Statistics.Count[Header][PlayerName] == nil then STNE.Save.Tables.Statistics.Count[Header][PlayerName] = {} end
        if STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition] == nil then STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition] = {} end
        if STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName] == nil then STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName] = {} end
        if STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName][TypeName] == nil then STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName][TypeName] = 0 end
        STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName][TypeName] = STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName][TypeName] + 1
        if Debug then BASE:E({FileVer,AddParsedDataToTable=STNE.Save.Tables.Statistics.Count[Header][PlayerName][Coalition][EventName][TypeName]}) end
    end
end

--- Parse EventData
--- @param EventDataName string
--- @param EventData table
local function ParseEventData(EventDataName, EventData)
    local EventName = EventDataName or 'Unknown'
    local GroupName = EventData.IniGroupName or 'Unknown'
    local UnitName = EventData.IniUnitName or 'Unknown'
    local Time = EventData.time or 0
    local PlayerName = EventData.IniPlayerName or 'AI'
    local TypeName = EventData.IniTypeName or 'Unknown'
    local Coalition = EventData.IniCoalition or 99
    local Latitude = 0
    local Longitude = 0
    if Debug then
        BASE:E({FileVer,ParseEventData=EventName,GroupName=GroupName,UnitName=UnitName,Time=Time,PlayerName=PlayerName,TypeName=TypeName,Coalition=Coalition})
        if EventData.IniUnit ~= nil then
            local Coord = EventData.IniUnit:GetCoordinate()
            Latitude, Longitude = Coord:GetLLDDM()
            Coord:MarkToAll('Event: '..EventName..'\nUnit: '..UnitName..' ('..TypeName..')\nPlayer: '..PlayerName..' ('..Coalition..')\nGoogle LL:\n'..Latitude..', '..Longitude)
        end
    end
    AddParsedDataToTable(EventName, GroupName, UnitName, Time, PlayerName, TypeName, Coalition, Latitude, Longitude)
end

--[[ OnEventShot
function STNE.EventHandler.Statistics:OnEventShot(EventData)
    local EventDataName = 'OnEventShot'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

--[[ OnEventHit
function STNE.EventHandler.Statistics:OnEventHit(EventData)
    local EventDataName = 'OnEventHit'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

--[[ OnEventTakeoff
function STNE.EventHandler.Statistics:OnEventTakeoff(EventData)
    --STNE.API.SaveTableToFile(EventData, true) -- DEBUG DEBUG DEBUG
    local EventDataName = 'OnEventTakeoff'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

--[[ OnEventLand
function STNE.EventHandler.Statistics:OnEventLand(EventData)
    --STNE.API.SaveTableToFile(EventData, true) -- DEBUG DEBUG DEBUG
    local EventDataName = 'OnEventLand'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

-- OnEventCrash
function STNE.EventHandler.Statistics:OnEventCrash(EventData)
    local EventDataName = 'OnEventCrash'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end

-- OnEventEjection
function STNE.EventHandler.Statistics:OnEventEjection(EventData)
    local EventDataName = 'OnEventEjection'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end

-- OnEventDead
function STNE.EventHandler.Statistics:OnEventDead(EventData)
    local EventDataName = 'OnEventDead'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end

-- OnEventPilotDead
function STNE.EventHandler.Statistics:OnEventPilotDead(EventData)
    local EventDataName = 'OnEventPilotDead'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end

--[[ OnEventShootingStart
function STNE.EventHandler.Statistics:OnEventShootingStart(EventData)
    local EventDataName = 'OnEventShootingStart'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

--[[ OnEventShootingEnd
function STNE.EventHandler.Statistics:OnEventShootingEnd(EventData)
    local EventDataName = 'OnEventShootingEnd'
    if Debug then BASE:E({FileVer,EventDataName,EventData=EventData}) end
    ParseEventData(EventDataName, EventData)
end]]

-- EOF
env.info('FILE: '..FileVer..' END')