local Cfg = {
--#################################################################################################
--
--  GroupCache
--
--  Cache idle groups when no clients around.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                -- Debug mode, true/false
    Prefixes = {                                  -- GROUP prefixes
        'AO1',
        'AO2',
        'AO3',
        --'Aerial',
    },
    SpawnDistance = 25000,                        -- Spawn group if client distance is lower than this, in meters
    CacheDistance = 35000,                        -- Cache group if client distance is higher than this, in meters
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.GroupCache.lua'
local Version = '201130'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_GroupCache then
    for key, value in pairs(STNE_Config_GroupCache) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local Prefixes = Cfg.Prefixes
local SpawnDistance = Cfg.SpawnDistance
local CacheDistance = Cfg.CacheDistance
local SchedulerTime = 10

local CachedGroups = {}

--- Cache group
--- @param GroupName string
local function CacheGroup(GroupName)
    local Grp = GROUP:FindByName(GroupName)
    if Grp ~= nil and Grp:IsAlive() and Grp:IsActive() then
        local Template = Grp:GetTemplate()
        local Units = Template.units
        local UnitCount = 0
        local TempTable = {}
        for UnitID, _ in UTILS.spairs(Units) do
            local Unit = UNIT:FindByName(Units[UnitID]['name'])
            if Unit ~= nil and Unit:IsAlive() then
                UnitCount = UnitCount + 1
                if Debug then BASE:E({FileVer,Group=GroupName,Unit=Unit:GetName(),UnitOldID=UnitID,UnitNewID=UnitCount}) end
                table.insert(TempTable, UnitCount, Units[UnitID])
            end
        end
        CachedGroups[GroupName].Units = TempTable
        CachedGroups[GroupName].Cache = true
        Grp:Destroy()
        if Debug then BASE:E({FileVer,CacheGroup=GroupName,Units=#TempTable}) end
    end
end

-- Get groups to cache
local PrefixSetGroup = SET_GROUP:New()
if #Prefixes > 0 then
    PrefixSetGroup:FilterPrefixes(Prefixes)
end
PrefixSetGroup:FilterOnce()
PrefixSetGroup:ForEachGroup(
    function(PrefixGrp)
        if PrefixGrp:IsActive() then
            local GroupName = PrefixGrp:GetName()
            local Coord = PrefixGrp:GetCoordinate()
            local Template = PrefixGrp:GetTemplate()
            local Units = Template.units
            CachedGroups[GroupName] = {}
            CachedGroups[GroupName].Coord = Coord
            CachedGroups[GroupName].Units = Units
            CachedGroups[GroupName].Cache = true
            if Debug then BASE:E({FileVer,Cache='true',Group=GroupName,Units=#Units}) end
            CacheGroup(GroupName)
        end
    end
)

--- Spawn group
--- @param GroupName string
local function SpawnGroup(GroupName)
    local Grp = GROUP:FindByName(GroupName)
    if Grp ~= nil and not Grp:IsAlive() then
        --local GroupName = Grp:GetName()
        local Template = Grp:GetTemplate()
        local Units = CachedGroups[GroupName].Units
        Template.units = Units
        CachedGroups[GroupName].Cache = false
        --_DATABASE:Spawn(Template)
        SPAWN:NewFromTemplate(Template, GroupName, GroupName):InitKeepUnitNames(true):Spawn()
        if Debug then BASE:E({FileVer,SpawnFromCache=GroupName,Units=#Units}) end
    end
end

--- Check group distance from client
--- @param Client table
--- @param GroupName string
local function CheckDistance(Client, GroupName)
    if Client ~= nil and CachedGroups[GroupName] ~= nil then
        local GroupCoord = CachedGroups[GroupName].Coord
        local ClientCoord = Client:GetCoordinate()
        local Distance = ClientCoord:Get2DDistance(GroupCoord)
        if Debug then BASE:E({FileVer,Client=Client:GetName(),Group=GroupName,Distance=math.floor(Distance)}) end
        if Distance <= SpawnDistance then
            return true
        elseif Distance >= CacheDistance then
            return false
        end
    else
        return nil
    end
end

-- Cache scheduler
SCHEDULER:New(nil, function()
    if Debug then BASE:E({FileVer,Scheduler=SchedulerTime}) end
    local ClientSet = SET_CLIENT:New()
    ClientSet:FilterActive()
    ClientSet:FilterOnce()
    for GroupName, _ in pairs(CachedGroups) do
        local InCache = CachedGroups[GroupName].Cache
        local InRange = false
        ClientSet:ForEachClient(
            function(Client)
                if Client ~= nil and Client:IsAlive() and InRange == false then
                    InRange = CheckDistance(Client, GroupName)
                end
            end
        )
        if InCache == false then
            local Grp = GROUP:FindByName(GroupName)
            if Grp ~= nil then
                if Grp:IsAlive() then
                    local Coord = CachedGroups[GroupName].Coord
                    local GrpCoord = Grp:GetCoordinate()
                    local Distance = Coord:Get2DDistance(GrpCoord)
                    if Distance > 5 then
                        if Debug then BASE:E({FileVer,RemoveFromCache=GroupName}) end
                        CachedGroups[GroupName] = nil
                        InRange = nil
                        InCache = nil
                    end
                else
                    if Debug then BASE:E({FileVer,RemoveFromCache=GroupName}) end
                    CachedGroups[GroupName] = nil
                    InRange = nil
                    InCache = nil
                end
            end
        end
        if InRange == true and InCache == true then
            SpawnGroup(GroupName)
        elseif InRange == false and InCache == false then
            CacheGroup(GroupName)
        end
    end
end, {}, SchedulerTime, SchedulerTime)

-- EOF
env.info('FILE: '..FileVer..' END')
