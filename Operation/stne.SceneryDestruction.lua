local Cfg = {
--#################################################################################################
--
--  SceneryDestruction
--
--  Monitor scenery destruction in zone and set flag if monitored object is destroyed.
--  Destroy scenery object with explosion if flag is already true.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = true,                                               -- Debug mode, true/false
    SceneryData = {
        ['SceneryZone1'] = {                                    -- ['Zone']
            [150208603] = {10001, 1000, 'Fuel tank'},           -- [SceneryID] = {Flag, ExplodeForce, Description}
            [150208542] = {10002, 1000, 'Office'},
            [150208710] = {10003, 5000, 'Oil tank'},
            [150208707] = {10004, 5000, 'Oil tank'},
            [150208712] = {10005, 5000, 'Oil tank'},
            [150208709] = {10006, 5000, 'Oil tank'},
        },
        ['SceneryZone2'] = {},
        ['SceneryZone3'] = {},
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SceneryDestruction.lua'
local Version = '201022'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SceneryDestruction then
    for key, value in pairs(STNE_Config_SceneryDestruction) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SceneryData = Cfg.SceneryData

-- Eventhandler
if STNE == nil then STNE = {} end
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.SceneryDestruction == nil then STNE.EventHandler.SceneryDestruction = {} end
STNE.EventHandler.SceneryDestruction = EVENTHANDLER:New()
STNE.EventHandler.SceneryDestruction:HandleEvent(world.event.S_EVENT_DEAD)

--- Burning fire & smoke
--- @param Coord table
--- @param WithFire boolean
local function BurningSmoke(Coord, WithFire)
    local Preset = 0
    if WithFire then
        Preset = math.random(0, 3)
    else
        Preset = math.random(4, 7)
    end
    local Density = math.random()
    Coord:BigSmokeAndFire(Preset, Density)
    if Debug then BASE:E({FileVer,'BurningSmoke',Preset=Preset,Density=Density}) end
end

-- Check all zones and destroy scenery if flag value true
local SceneryMarkers = {}
for ZoneName, SceneryIDs in pairs(SceneryData) do
    local Zone = ZONE:FindByName(ZoneName)
    if Zone ~= nil then
        local ZoneCoord = Zone:GetCoordinate()
        local ZoneRadius = Zone:GetRadius()
        local SceneryObjects = ZoneCoord:ScanScenery(ZoneRadius)
        if Debug then BASE:E({FileVer,Zone=ZoneName,Radius=ZoneRadius,Objects=#SceneryObjects}) end
        for _, SceneryObject in pairs(SceneryObjects) do
            local SceneryName = SceneryObject['SceneryName']
            local SceneryCoord = SceneryObject:GetCoordinate()
            local SceneryType = SceneryObject:GetTypeName()
            if SceneryIDs[SceneryName] ~= nil then
                local Flag = SceneryIDs[SceneryName][1]
                local Force = SceneryIDs[SceneryName][2]
                local FlagValue = trigger.misc.getUserFlag(Flag)
                if FlagValue >= 1 then
                    SceneryCoord:Explosion(Force)
                    BurningSmoke(SceneryCoord, false)
                else
                    if not Debug then
                        local MarkerText = 'Target:\n'..SceneryIDs[SceneryName][3]
                        SceneryMarkers[SceneryName] = MARKER:New(SceneryCoord, SceneryName)
                        SceneryMarkers[SceneryName]:ReadOnly()
                        SceneryMarkers[SceneryName]:SetText(MarkerText)
                        SceneryMarkers[SceneryName]:ToBlue()
                    end
                end
                if Debug then
                    SceneryCoord:MarkToAll(SceneryType..'\nZone: '..ZoneName..'\nSceneryID: '..SceneryName..'\nFlag: '..SceneryIDs[SceneryName][1]..' ExplodeForce: '..SceneryIDs[SceneryName][2]..'\nDescription: '..SceneryIDs[SceneryName][3])
                    SceneryCoord:SmokeBlue()
                end
            else
                if Debug then SceneryCoord:MarkToAll(SceneryType..'\nZone: '..ZoneName..'\nSceneryID: '..SceneryName) end
            end
        end
    else
        local ErrorMsg = 'ERROR: '..FileVer..' Cannot find zone: '..ZoneName
        MESSAGE:New(ErrorMsg, 300):ToAll()
        env.info(ErrorMsg)
    end
end

-- Dead event
function STNE.EventHandler.SceneryDestruction:OnEventDead(EventData)
    if Debug then BASE:E({FileVer,'OnEventDead'}) end
    if EventData.IniUnit ~= nil and EventData.IniObjectCategory ~= nil and EventData.IniObjectCategory == Object.Category.SCENERY then
        if EventData.IniUnit.SceneryName ~= nil then
            local SceneryName = EventData.IniUnit.SceneryName
            if Debug then BASE:E({FileVer,'OnEventDead',SceneryName=SceneryName}) end
            for _, SceneryIDs in pairs(SceneryData) do
                if SceneryIDs[SceneryName] ~= nil then
                    local Flag = SceneryIDs[SceneryName][1]
                    local Force = SceneryIDs[SceneryName][2]
                    local Description = SceneryIDs[SceneryName][3]
                    local SceneryCoord = EventData.IniUnit:GetCoordinate()
                    SceneryCoord:Explosion(Force)
                    BurningSmoke(SceneryCoord, true)
                    trigger.action.setUserFlag(Flag, 1)
                    if SceneryMarkers[SceneryName] ~= nil then
                        SceneryMarkers[SceneryName]:Remove(0)
                    end
                    if Debug then BASE:E({FileVer,'OnEventDead',SceneryName=SceneryName,SetFlag=Flag,ExplodeForce=Force,Description=Description}) end
                end
            end
        end
    end
end

-- EOF
env.info('FILE: '..FileVer..' END')
