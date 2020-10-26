local Cfg = {
--#################################################################################################
--
--  RandomTraffic
--
--  Random air traffic.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Rat.html
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false (use debug to get traffic type names)
    DebugMarkers = false,                           -- Show airbase map markers when debug enabled, true/false
    GroupPrefixes = {                               -- GROUP template prefixes
        'Traffic_',
    },
    ZonePrefixes = {                                -- ZONE prefixes, limit traffic in these zones, empty = no limit
        --'Traffic_',
    },
    AirStart = true,                                -- Spawn/remove planes in air
    UseMilitary = true,                             -- Neutral planes use also military airbases
    TrafficCount = 50,                              -- Total active air traffic groups
    TrafficTypes = {                                -- Custom traffic types
        ['FA-18C_hornet'] = {                       -- (optional) Type name
            ['Percent'] = 10,                       -- (optional) How many groups are spawned at least, percent
            ['Ship'] = true,                        -- (optional) Add ships to available airbases
            ['Helipad'] = false,                    -- (optional) Add helipad to available airbases
            ['Neutral'] = true,                     -- (optional) Add neutral airbases to available airbases, use for military planes
            ['Livery'] = {                          -- (optional) Random liveries
                'VFA-113',
                'VFA-122',
                'VFA-131',
                'VFA-192',
            },
        },
        ['Yak-40'] = {
            ['Percent'] = 70,
            ['Livery'] = {
                --'Aeroflot',
                --'Algeria GLAM',
                --'Georgian Airlines',
                --'Olympic Airways',
                --'Ukranian',
                'Syrian Air (New)',
            },
        },
        ['UH-1H'] = {
            ['Percent'] = 10,
            ['Ship'] = true,
            ['Helipad'] = true,
            ['Livery'] = {
                'IRIAA Generic',
                'Israel Army',
            },
        },
        ['Su-27'] = {
            ['Percent'] = 10,
            ['Livery'] = {
                'Syrian Air Force Standard',
            },
        },
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.RandomTraffic.lua'
local Version = '201026'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_RandomTraffic then
    for key, value in pairs(STNE_Config_RandomTraffic) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local DebugMarkers = Cfg.DebugMarkers
local GroupPrefixes = Cfg.GroupPrefixes
local ZonePrefixes = Cfg.ZonePrefixes
local AirStart = Cfg.AirStart
local TrafficTypes = Cfg.TrafficTypes
local TrafficCount = Cfg.TrafficCount
local UseMilitary = Cfg.UseMilitary

-- Local variables
local TotalCount = 0

-- Get traffic templates
local Set_Group = SET_GROUP:New()
Set_Group:FilterPrefixes(GroupPrefixes)
Set_Group:FilterOnce()

-- Get limitation zones
local Set_Zone = SET_ZONE:New()
Set_Zone:FilterPrefixes(ZonePrefixes)
Set_Zone:FilterOnce()

--- Sort airbase table if limited by zones
--- @param AirbaseNameTable table
local function SortIfLimited(AirbaseNameTable)
    local ZoneCount = Set_Zone:Count()
    if ZoneCount > 0 then
        local SortedTable = {}
        for _, AirbaseName in pairs(AirbaseNameTable) do
            local AirbaseCoord = AIRBASE:FindByName(AirbaseName):GetCoordinate()
            if Set_Zone:IsCoordinateInZone(AirbaseCoord) then
                table.insert(SortedTable, AirbaseName)
            end
        end
        if Debug then BASE:E({FileVer,'SortIfLimited',LimitationZones=ZoneCount,AirbasesBefore=#AirbaseNameTable,AirbasesAfter=#SortedTable}) end
        return SortedTable
    else
        return AirbaseNameTable
    end
end

-- Get all airbases, helipads and ships from map
local AirbaseNames = {
    ['Airbase'] = {
        [0] = SortIfLimited(AIRBASE.GetAllAirbaseNames(0, Airbase.Category.AIRDROME)),
        [1] = SortIfLimited(AIRBASE.GetAllAirbaseNames(1, Airbase.Category.AIRDROME)),
        [2] = SortIfLimited(AIRBASE.GetAllAirbaseNames(2, Airbase.Category.AIRDROME)),
        [4] = SortIfLimited(AIRBASE.GetAllAirbaseNames(nil, Airbase.Category.AIRDROME)),
    },
    ['Helipad'] = {
        [0] = SortIfLimited(AIRBASE.GetAllAirbaseNames(0, Airbase.Category.HELIPAD)),
        [1] = SortIfLimited(AIRBASE.GetAllAirbaseNames(1, Airbase.Category.HELIPAD)),
        [2] = SortIfLimited(AIRBASE.GetAllAirbaseNames(2, Airbase.Category.HELIPAD)),
        [4] = SortIfLimited(AIRBASE.GetAllAirbaseNames(nil, Airbase.Category.HELIPAD)),
    },
    ['Ship'] = {
        [0] = SortIfLimited(AIRBASE.GetAllAirbaseNames(0, Airbase.Category.SHIP)),
        [1] = SortIfLimited(AIRBASE.GetAllAirbaseNames(1, Airbase.Category.SHIP)),
        [2] = SortIfLimited(AIRBASE.GetAllAirbaseNames(2, Airbase.Category.SHIP)),
        [4] = SortIfLimited(AIRBASE.GetAllAirbaseNames(nil, Airbase.Category.SHIP)),
    },
}
if Debug then
    for Type, TypeTable in pairs(AirbaseNames) do
        for Side, Names in pairs(TypeTable) do
            BASE:E({FileVer,Type=Type,Side=Side,Count=#Names,Names=Names})
        end
    end
end

--- Combine tables
--- @param Table1 table
--- @param Table2 table
local function CombineTables(Table1, Table2)
    local CombinedTable = {}
    if Table1 then
        for _, Value in pairs(Table1) do
            table.insert(CombinedTable, Value)
        end
    end
    if Table2 then
        for _, Value in pairs(Table2) do
            table.insert(CombinedTable, Value)
        end
    end
    if Debug then BASE:E({FileVer,'CombineTables',Table1=#Table1,Table2=#Table2,CombinedTable=#CombinedTable}) end
    return CombinedTable
end

-- Create random air traffic module and add groups
local TrafficManager = RATMANAGER:New(TrafficCount)
Set_Group:ForEachGroup(
    function(Grp)
        local GroupName = Grp:GetName()
        local GroupType = Grp:GetTypeName()
        local GroupCoalition = Grp:GetCoalition()
        local GroupCount = 1
        if GroupCoalition == 0 and UseMilitary then GroupCoalition = 4 end
        local UsableAirbases = AirbaseNames['Airbase'][GroupCoalition]
        local IsCustomType = false
        local HasLiveries = false
        local UseHelipad = false
        local UseShip = false
        local UseNeutral = false
        local TrafficObj = RAT:New(GroupName)
        TrafficObj:ATC_Messages(false)
        TrafficObj:StatusReports(false)
        if AirStart then
            TrafficObj:SetTakeoffAir()
            TrafficObj:DestinationZone()
        else
            TrafficObj:SetTakeoffCold()
            TrafficObj:RespawnInAirNotAllowed()
        end
        if TrafficTypes[GroupType] then
            IsCustomType = true
            if TrafficTypes[GroupType]['Livery'] then
                HasLiveries = true
                TrafficObj:Livery(TrafficTypes[GroupType]['Livery'])
            end
            if (GroupCoalition == 1 or GroupCoalition == 2) and TrafficTypes[GroupType]['Neutral'] then
                UseNeutral = true
                UsableAirbases = CombineTables(UsableAirbases, AirbaseNames['Airbase'][0])
            end
            if TrafficTypes[GroupType]['Helipad'] then
                UseHelipad = true
                UsableAirbases = CombineTables(UsableAirbases, AirbaseNames['Helipad'][GroupCoalition])
                if UseNeutral then
                    UsableAirbases = CombineTables(UsableAirbases, AirbaseNames['Helipad'][0])
                end
            end
            if TrafficTypes[GroupType]['Ship'] then
                UseShip = true
                UsableAirbases = CombineTables(UsableAirbases, AirbaseNames['Ship'][GroupCoalition])
                if UseNeutral then
                    UsableAirbases = CombineTables(UsableAirbases, AirbaseNames['Ship'][0])
                end
            end
            if TrafficTypes[GroupType]['Percent'] then
                GroupCount = math.floor((TrafficCount / 100) * TrafficTypes[GroupType]['Percent'])
            end
        end
        if GroupCoalition == 1 or GroupCoalition == 2 then
            TrafficObj:SetROE('return')
            TrafficObj:SetROT('passive')
            if UseNeutral then
                TrafficObj:SetCoalition('same')
            else
                TrafficObj:SetCoalition('sameonly')
            end
        else
            TrafficObj:SetROE('hold')
            TrafficObj:SetROT('noreaction')
            UseNeutral = true
        end
        local RNumber = math.random(0, 9)
        if RNumber == 4 then RNumber = RNumber + 1 end
        TrafficObj:SetOnboardNum(tostring(math.random(0, 9)), RNumber)
        TrafficObj:SetDeparture(UsableAirbases)
        TrafficObj:SetDestination(UsableAirbases)
        --TrafficObj:SetParkingScanSceneryON()
        TrafficManager:Add(TrafficObj, GroupCount)
        if Debug then
            BASE:E({FileVer,Name=GroupName,Type=GroupType,Count=GroupCount,Side=GroupCoalition,AirStart=AirStart,IsCustomType=IsCustomType,HasLiveries=HasLiveries,UseHelipad=UseHelipad,UseShip=UseShip,UseNeutral=UseNeutral,UsableAirbases=#UsableAirbases})
            MESSAGE:New('DEBUG: Name: '..GroupName..' Type: '..GroupType, 10):ToAll()
            if DebugMarkers then
                for _, AirbaseName in pairs(UsableAirbases) do
                    MARKER:New(AIRBASE:FindByName(AirbaseName):GetCoordinate(), AirbaseName):SetText(AirbaseName):ToAll()
                end
            end
        end
        TotalCount = TotalCount + GroupCount
    end
)
if TotalCount > TrafficCount then
    local ErrorMsg = 'WARNING: '..FileVer..'\nCheck configuration! Trying to spawn too many planes: '..TotalCount..'/'..TrafficCount
    MESSAGE:New(ErrorMsg, 300):ToAll()
    env.info(ErrorMsg)
end
TrafficManager:Start()

-- EOF
env.info('FILE: '..FileVer..' END')