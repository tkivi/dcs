local Cfg = {
--#################################################################################################
--
--  SlingloadLogistic
--
--  Slingload cargo logistic with flag values.
--
--  CargoZone flag values:
--      1 = Spawn RED cargo when mission start
--      2 = Spawn BLUE cargo when mission start
--      3 = Request RED cargo and set value to 1 when cargo has delivered
--      4 = Request BLUE cargo and set value to 2 when cargo has delivered
--      5 = Request RED and BLUE cargo and set value to 1 or 2 when cargo has delivered
--     11 = Spawn RED cargo now and set flag value to 1
--     12 = Spawn BLUE cargo now and set flag value to 2
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                          -- Debug mode, true/false
    CargoTypes = {
        ['CARGO_FUEL_SMALL'] = {            -- STATIC cargo name
            ['Cargo'] = 'FUEL',             -- Cargo type text
            ['Spawn'] = 2,                  -- Spawn count for each zone
            ['Value'] = 1,                  -- Cargo value
        },
        ['CARGO_FUEL_LARGE'] = {    ['Cargo']='FUEL',     ['Spawn']=1,   ['Value']=2,   },
        ['CARGO_AMMO_SMALL'] = {    ['Cargo']='AMMO',     ['Spawn']=2,   ['Value']=1,   },
        ['CARGO_AMMO_LARGE'] = {    ['Cargo']='AMMO',     ['Spawn']=1,   ['Value']=2,   },
        ['CARGO_REPAIR_SMALL'] = {  ['Cargo']='REPAIR',   ['Spawn']=2,   ['Value']=1,   },
        ['CARGO_REPAIR_LARGE'] = {  ['Cargo']='REPAIR',   ['Spawn']=1,   ['Value']=2,   },
    },
    CargoZones = {
        ['SlingZone1'] = {                  -- ZONE name
            ['Flag'] = 10001,               -- Flag, see possible values from description
            ['Request'] = {
                [1] = {                     -- Request SIDE, 1 = Red
                    ['REPAIR'] = 2,         -- Request cargo type text and value
                    ['FUEL'] = 2,           -- Request cargo type text and value
                },
                [2] = {                     -- Request SIDE, 2 = Blue
                    ['FUEL'] = 2,           -- Request cargo type text and value
                    ['AMMO'] = 2,           -- Request cargo type text and value
                },
            },
        },
        ['SlingZone2'] = {   ['Flag']=10002,   ['Request']={   [1]={   ['REPAIR']=2,   ['FUEL']=2,},   [2]={   ['FUEL']=2,   ['AMMO']=2,   },},},
        ['SlingZone3'] = {   ['Flag']=10003,   ['Request']={   [1]={   ['REPAIR']=2,   ['FUEL']=2,},   [2]={   ['FUEL']=2,   ['AMMO']=2,   },},},
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SlingloadLogistic.lua'
local Version = '201103'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SlingloadLogistic then
    for key, value in pairs(STNE_Config_SlingloadLogistic) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local CargoTypes = Cfg.CargoTypes
local CargoZones = Cfg.CargoZones

-- Local variables
local Debug2 = false
local SlingloadMarkers = {}
local CachedCargo = {}

-- Set static for spawned cargo
local Cargo_Prefix = {}
for CargoName, _ in pairs(CargoTypes) do
    table.insert(Cargo_Prefix, CargoName..'#')
end
local Cargo_Set_Static = SET_STATIC:New()
Cargo_Set_Static:FilterPrefixes(Cargo_Prefix)
Cargo_Set_Static:FilterStart()

--- Count spawnable cargo from config
--- @param Coalition number
local function CountConfigCargo(Coalition)
    local CargoCount = 0
    for CargoName, CargoData in pairs(CargoTypes) do
        local CargoObj = STATIC:FindByName(CargoName, false)
        if CargoObj ~= nil then
            local CargoCoalition = CargoObj:GetCoalition()
            if Coalition == CargoCoalition then
                CargoCount = CargoCount + CargoData['Spawn']
            end
        else
            local ErrorMsg = 'ERROR: '..FileVer..' Cannot find cargo: '..CargoName
            MESSAGE:New(ErrorMsg, 300):ToAll()
            env.info(ErrorMsg)
        end
    end
    if Debug then BASE:E({FileVer,CountConfigCargo=CargoCount}) end
    return CargoCount
end

--- Find safe spawn name
--- @param CargoName string
local function FindSafeName(CargoName)
    local NewNameIndex = 1
    while STATIC:FindByName(CargoName..'#'..NewNameIndex, false) ~= nil do
        if Debug then BASE:E({FileVer,'FindSafeName',AlreadyExist=CargoName..'#'..NewNameIndex}) end
        NewNameIndex = NewNameIndex + 1
    end
    local NewName = CargoName..'#'..NewNameIndex
    return NewName
end

--- Spawn cargo crates in zone
--- @param ZoneName string
--- @param Coalition number
local function SpawnCargoInZone(ZoneName, Coalition)
    SCHEDULER:New(nil, function() -- Delay spawn for 10 sec to fix cargo stacking
        if Debug then BASE:E({FileVer,'SpawnCargoInZone',Zone=ZoneName}) end
        local ZoneObj = ZONE:FindByName(ZoneName)
        local ZoneCoord = ZoneObj:GetCoordinate()
        local ZoneRadius = ZoneObj:GetRadius()
        local MinRadius = 4.8
        if ZoneRadius > 50 then ZoneRadius = 50 end
        if ZoneRadius > 10 then MinRadius = 10 end
        local CargoCount = CountConfigCargo(Coalition)
        local CargoIndex = 0
        local SpawnTable = {}
        for CargoName, CargoData in pairs(CargoTypes) do
            local CargoObj = STATIC:FindByName(CargoName, false)
            if CargoObj ~= nil then
                local CargoCoalition = CargoObj:GetCoalition()
                if Coalition == CargoCoalition then
                    local SpawnCount = CargoData.Spawn
                    for i = 1, SpawnCount, 1 do
                        table.insert(SpawnTable, CargoName)
                    end
                end
            end
        end
        for _, CargoName in UTILS.rpairs(SpawnTable) do
            CargoIndex = CargoIndex + 1
            local NewName = FindSafeName(CargoName)
            local SpawnSector = (360 / CargoCount) * CargoIndex
            local NewCoord = ZoneCoord:Translate(math.random(MinRadius,ZoneRadius), SpawnSector)
            local NewHdg = math.random(0,359)
            local StaticObj = SPAWNSTATIC:NewFromStatic(CargoName):SpawnFromCoordinate(NewCoord, NewHdg, NewName)
            if Debug then
                local DCSObj = StaticObj:GetDCSObject()
                local Category = Object.getCategory(DCSObj)
                local Mass = StaticObject.getCargoWeight(DCSObj)
                local DisplayName = StaticObj:GetDesc()['displayName']
                local TypeName = StaticObj:GetTypeName()
                BASE:E({FileVer,ZoneName=ZoneName,CargoName=CargoName,SpawnName=NewName,Category=Category,Mass=Mass,DisplayName=DisplayName,TypeName=TypeName})
            end
        end
    end, {}, 10)
end

--- Get static name without #index
--- @param StaticName string
local function GetStaticName(StaticName)
    local ReturnName = StaticName
    if string.find(StaticName, '#') ~= nil then
        ReturnName = UTILS.Split(StaticName, '#')[1]
    end
    if Debug then BASE:E({FileVer,'GetStaticName',StaticName=StaticName,ReturnName=ReturnName}) end
    return ReturnName
end

--- Add zone cached cargo values to counted cargo
--- @param CargoTable table
local function AddCachedCargo(CountedCargo, ZoneName)
    if CachedCargo[ZoneName] ~= nil then
        if Debug then BASE:E({FileVer,'AddCachedCargo',CountedCargo=CountedCargo,CachedCargo=CachedCargo[ZoneName]}) end
        for Cargo, Value in pairs(CachedCargo[ZoneName]) do
            if CountedCargo[Cargo] == nil then
                CountedCargo[Cargo] = Value
            else
                CountedCargo[Cargo] = CountedCargo[Cargo] + Value
            end
        end
    end
    return CountedCargo
end

--- Count cargo values
--- @param CargoTable table
local function CountCargo(CargoTable)
    local CountedCargo = {}
    for _, CargoObj in pairs(CargoTable) do
        local CargoName = CargoObj:GetName()
        CargoName = GetStaticName(CargoName)
        local Cargo = CargoTypes[CargoName].Cargo
        local Value = CargoTypes[CargoName].Value
        if CountedCargo[Cargo] == nil then
            CountedCargo[Cargo] = Value
        else
            CountedCargo[Cargo] = CountedCargo[Cargo] + Value
        end
    end
    if Debug then BASE:E({FileVer,'CountCargo',CountedCargo=CountedCargo}) end
    return CountedCargo
end

--- Check if table is empty
--- @param Tbl table
local function IsEmptyTable(Tbl)
    if Debug then BASE:E({FileVer,'IsEmptyTable'}) end
    for key, value in pairs(Tbl) do
        return false
    end
    return true
end

--- Create marker text
--- @param CountedCargo table
--- @param ZoneName string
--- @param Request boolean
--- @param Coalition number
local function CreateMarkerText(CountedCargo, ZoneName, Request, Coalition)
    if Debug then BASE:E({FileVer,'CreateMarkerText'}) end
    local MarkerText = 'Available slingload cargo:'
    if Request then
        MarkerText = 'Request slingload cargo:'
        for ZCargo, ZValue in pairs(CargoZones[ZoneName]['Request'][Coalition]) do
            if CountedCargo[ZCargo] ~= nil then
                MarkerText = MarkerText..'\n'..tostring(ZCargo)..' = '..tostring(CountedCargo[ZCargo])..' / '..ZValue
            else
                MarkerText = MarkerText..'\n'..tostring(ZCargo)..' = 0 / '..ZValue
            end
        end
    else
        if IsEmptyTable(CountedCargo) then
            MarkerText = MarkerText..'\nnone'
        else
            for Cargo, Value in pairs(CountedCargo) do
                MarkerText = MarkerText..'\n'..tostring(Cargo)..' = '..tostring(Value)
            end
        end
    end
    return MarkerText
end

--- Check if zone has enough cargo to complete request
--- @param CountedCargo table
--- @param ZoneName string
--- @param Coalition number
local function IsZoneCargoCompleted(CountedCargo, ZoneName, Coalition)
    for ZCargo, ZValue in pairs(CargoZones[ZoneName]['Request'][Coalition]) do
        if CountedCargo[ZCargo] ~= nil and CountedCargo[ZCargo] >= ZValue then
            -- Zone has enough cargo
        else
            if Debug then BASE:E({FileVer,IsZoneCargoCompleted='false',Zone=ZoneName,CountedCargo=CountedCargo}) end
            return false
        end
    end
    if Debug then BASE:E({FileVer,IsZoneCargoCompleted='true',Zone=ZoneName,CountedCargo=CountedCargo}) end
    return true
end

--- Remove cargo and update cargo cache
--- @param CargoTable table
--- @param ZoneName string
--- @param Cache boolean
local function RemoveCargo(CargoTable, ZoneName, Cache)
    local ToCache = Cache or false
    for _, CargoObj in pairs(CargoTable) do
        local CargoName = CargoObj:GetName()
        if Debug then BASE:E({FileVer,RemoveCargo=CargoName,Cache=ToCache}) end
        if ToCache == true then
            CargoName = GetStaticName(CargoName)
            local Cargo = CargoTypes[CargoName].Cargo
            local Value = CargoTypes[CargoName].Value
            if CachedCargo[ZoneName] == nil then
                CachedCargo[ZoneName] = {}
            end
            if CachedCargo[ZoneName][Cargo] == nil then
                CachedCargo[ZoneName][Cargo] = Value
            else
                CachedCargo[ZoneName][Cargo] = CachedCargo[ZoneName][Cargo] + Value
            end
        end
        CargoObj:Destroy()
    end
    if ToCache == false then
        if CachedCargo[ZoneName] ~= nil then
            CachedCargo[ZoneName] = nil
        end
    end
end

--- Create zone cargo table
--- @param ZoneName string
local CargoCoords = {}
local function CreateZoneCargoTable(ZoneName)
    if Debug then BASE:E({FileVer,'CreateZoneCargoTable',Zone=ZoneName}) end
    local ZoneObj = ZONE:FindByName(ZoneName)
    local CargoTable = {}
    Cargo_Set_Static:ForEachStaticCompletelyInZone(
        ZoneObj,
        function(CargoObj)
            if CargoObj ~= nil and CargoObj:IsAlive() then
                local CargoName = CargoObj:GetName()
                local CargoCoord = CargoObj:GetCoordinate()
                local CargoHeight = CargoCoord.y
                local CargoX = math.floor(CargoCoord.x)
                local CargoY = math.floor(CargoCoord.y)
                local CargoZ = math.floor(CargoCoord.z)
                local LandHeight = CargoCoord:GetLandHeight()
                local AboveGround = CargoHeight - LandHeight
                if CargoCoords[CargoName] == nil then
                    CargoCoords[CargoName] = {}
                    CargoCoords[CargoName]['x'] = CargoX
                    CargoCoords[CargoName]['y'] = CargoY
                    CargoCoords[CargoName]['z'] = CargoZ
                end
                if CargoCoords[CargoName]['x'] == CargoX and CargoCoords[CargoName]['y'] == CargoY and CargoCoords[CargoName]['z'] == CargoZ then
                    if Debug then BASE:E({FileVer,ZoneName=ZoneName,x=CargoX==CargoCoords[CargoName]['x'],y=CargoY==CargoCoords[CargoName]['y'],z=CargoZ==CargoCoords[CargoName]['z'],CargoName=CargoName}) end
                    table.insert(CargoTable, CargoObj)
                else
                    if Debug then BASE:E({FileVer,ZoneName=ZoneName,x=CargoX==CargoCoords[CargoName]['x'],y=CargoY==CargoCoords[CargoName]['y'],z=CargoZ==CargoCoords[CargoName]['z'],CargoName=CargoName}) end
                    CargoCoords[CargoName]['x'] = CargoX
                    CargoCoords[CargoName]['y'] = CargoY
                    CargoCoords[CargoName]['z'] = CargoZ
                end
            end
        end
    )
    return CargoTable
end

-- Mission start, spawn cargo in zones
for ZoneName, ZoneData in pairs(CargoZones) do
    local ZoneObj = ZONE:FindByName(ZoneName)
    if ZoneObj ~= nil then
        local FlagValue = trigger.misc.getUserFlag(ZoneData.Flag)
        if FlagValue == 1 or FlagValue == 2 then
            local CargoTable = CreateZoneCargoTable(ZoneName)
            RemoveCargo(CargoTable, ZoneName)
            SpawnCargoInZone(ZoneName, FlagValue)
        end
        if Debug2 then ZoneObj:MarkZone(8) end
    else
        local ErrorMsg = 'ERROR: '..FileVer..' Cannot find zone: '..ZoneName
        MESSAGE:New(ErrorMsg, 300):ToAll()
        env.info(ErrorMsg)
    end
end

--- Create/refresh zone marker
--- @param CountedCargo table
--- @param ZoneName string
--- @param Request boolean
--- @param Coalition number
local function RefreshMarker(CountedCargo, ZoneName, Request, Coalition)
    if Debug then BASE:E({FileVer,RefreshMarker=ZoneName,CountedCargo=CountedCargo,Request=Request,Coalition=Coalition}) end
    if Coalition == 1 or Coalition == 2 then
        local ZoneObj = ZONE:FindByName(ZoneName)
        local ZoneCoord = ZoneObj:GetCoordinate()
        local MarkerName = ZoneName..Coalition
        local MarkerText = CreateMarkerText(CountedCargo, ZoneName, Request, Coalition)
        if SlingloadMarkers[MarkerName] == nil then
            SlingloadMarkers[MarkerName] = MARKER:New(ZoneCoord, MarkerName)
            SlingloadMarkers[MarkerName]:ReadOnly()
            SlingloadMarkers[MarkerName]:SetText(MarkerText)
            if Coalition == 1 then
                SlingloadMarkers[MarkerName]:ToRed()
            elseif Coalition == 2 then
                SlingloadMarkers[MarkerName]:ToBlue()
            end
        else
            SlingloadMarkers[MarkerName]:SetText(MarkerText)
            SlingloadMarkers[MarkerName]:Refresh(0)
        end
    else
        if SlingloadMarkers[ZoneName..'1'] ~= nil then
            SlingloadMarkers[ZoneName..'1']:Remove(0)
        end
        if SlingloadMarkers[ZoneName..'2'] ~= nil then
            SlingloadMarkers[ZoneName..'2']:Remove(0)
        end
    end
end

-- Cargo scheduler
SCHEDULER:New(nil, function()
    if Debug then BASE:E({FileVer,'CargoScheduler',CargoCount=Cargo_Set_Static:Count()}) end
    for ZoneName, ZoneData in pairs(CargoZones) do
        local FlagValue = trigger.misc.getUserFlag(ZoneData.Flag)
        local CargoTable = {}
        local CountedCargo = {}
        if FlagValue > 0 then
            CargoTable = CreateZoneCargoTable(ZoneName)
            CountedCargo = CountCargo(CargoTable)
        end
        if FlagValue == 1 or FlagValue == 2 then -- Red or Blue coalition have cargo available
            RefreshMarker(CountedCargo, ZoneName, false, FlagValue)
        elseif FlagValue == 3 or FlagValue == 4 then -- Red or Blue coalition request cargo
            CountedCargo = AddCachedCargo(CountedCargo, ZoneName)
            RemoveCargo(CargoTable, ZoneName, true)
            if FlagValue == 3 then FlagValue = 1 end
            if FlagValue == 4 then FlagValue = 2 end
            if IsZoneCargoCompleted(CountedCargo, ZoneName, FlagValue) then
                trigger.action.setUserFlag(ZoneData.Flag, FlagValue)
                RefreshMarker({}, ZoneName, false, 0)
                RemoveCargo(CargoTable, ZoneName)
            else
                RefreshMarker(CountedCargo, ZoneName, true, FlagValue)
            end
        elseif FlagValue == 5 then -- Both coalitions request cargo
            CountedCargo = AddCachedCargo(CountedCargo, ZoneName)
            RemoveCargo(CargoTable, ZoneName, true)
            local RedDone = IsZoneCargoCompleted(CountedCargo, ZoneName, 1)
            local BlueDone = IsZoneCargoCompleted(CountedCargo, ZoneName, 2)
            if RedDone or BlueDone then
                if RedDone then
                    trigger.action.setUserFlag(ZoneData.Flag, 1)
                elseif BlueDone then
                    trigger.action.setUserFlag(ZoneData.Flag, 2)
                end
                RefreshMarker({}, ZoneName, false, 0)
                RemoveCargo(CargoTable, ZoneName)
            else
                RefreshMarker(CountedCargo, ZoneName, true, 1)
                RefreshMarker(CountedCargo, ZoneName, true, 2)
            end
        elseif FlagValue == 11 or FlagValue == 12 then -- Red or Blue force spawn now
            RefreshMarker({}, ZoneName, false, 0)
            RemoveCargo(CargoTable, ZoneName)
            if FlagValue == 11 then
                SpawnCargoInZone(ZoneName, 1)
                trigger.action.setUserFlag(ZoneData.Flag, 1)
            end
            if FlagValue == 12 then
                SpawnCargoInZone(ZoneName, 2)
                trigger.action.setUserFlag(ZoneData.Flag, 2)
            end
        else
            RefreshMarker({}, ZoneName, false, 0)
        end
    end
end, {}, 60, 60)

-- EOF
env.info('FILE: '..FileVer..' END')
