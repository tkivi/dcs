local Cfg = {
--#################################################################################################
--
--  SlingloadLogistic
--
--  Slingload and internal cargo logistic with flag values.
--
--  Use with stne.SaveFlags.lua and stne.SaveTables.lua for persistent save.
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
    CargoTypes = {                          -- Default slingload cargo types
        ['CARGO_FUEL_SMALL'] = {            -- STATIC cargo name
            Cargo = 'FUEL',                 -- Cargo type text
            Spawn = 4,                      -- Spawn count for each zone
            Value = 1,                      -- Cargo value
        },
        ['CARGO_FUEL_LARGE'] = {    Cargo='FUEL',     Spawn=2,   Value=2,   },
        ['CARGO_AMMO_SMALL'] = {    Cargo='AMMO',     Spawn=4,   Value=1,   },
        ['CARGO_AMMO_LARGE'] = {    Cargo='AMMO',     Spawn=2,   Value=2,   },
        ['CARGO_REPAIR_SMALL'] = {  Cargo='REPAIR',   Spawn=4,   Value=1,   },
        ['CARGO_REPAIR_LARGE'] = {  Cargo='REPAIR',   Spawn=2,   Value=2,   },
    },
    InternalCargoTypes = {                  -- Default internal cargo types
        [1] = {                             -- Cargo SIDE, 1 = Red
            ['FUEL'] = 10,                  -- ['Cargo type text'] = cargo value
            ['AMMO'] = 10,
            ['REPAIR'] = 10,
        },
        [2] = {                             -- Cargo SIDE, 2 = Blue
            ['FUEL'] = 10,                  -- ['Cargo type text'] = cargo value
            ['AMMO'] = 10,
            ['REPAIR'] = 10,
        },
    },
    CargoZones = {
        ['CARGO TURKEYFARP'] = {            -- ZONE name
            Flag = 7001,                    -- Flag, see possible values from description
            --[[
            InternalCargo = {               -- Override default internal cargo
                [1] = {                     -- Override SIDE, 1 = Red
                    ['REPAIR'] = 20,        -- Override ['Cargo type text'] = cargo value
                },
                [2] = {                     -- Override SIDE, 2 = Blue
                    ['FUEL'] = 40,          -- Override ['Cargo type text'] = cargo value
                    ['TOOLS'] = 30,         -- Override ['Cargo type text'] = cargo value
                },
            },
            SlingloadCargo = {              -- Override default slingload cargo
                ['CARGO_FUEL_LARGE'] = 4,   -- Override ['STATIC cargo name'] = Spawn count for zone
            },
            ]]
            Request = {
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
        ['CARGO LEBANONFARP'] = {     Flag=7002,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
        ['CARGO ISRAELFARP'] = {      Flag=7003,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['CARGO KING HUSSEIN'] = {    Flag=7004,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['CARGO INCIRLIK'] = {        Flag=7005,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['CARGO RAMAT DAVID'] = {     Flag=7006,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO MINAKH'] = {      Flag=1001,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO ALEPPO'] = {      Flag=1002,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO KUWEIRES'] = {    Flag=1003,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO JIRAH'] = {       Flag=1004,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO ABUDUHUR'] = {    Flag=1005,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO1 CARGO PATRIOT'] = {     Flag=1006,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=3,   ['REPAIR']=6,  },},},
		['AO1 CARGO HAWK'] = {        Flag=1007,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=2,   ['REPAIR']=4,  },},},
		['AO3 CARGO BASSELASSAD'] = { Flag=3001,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO3 CARGO PATRIOT'] = {     Flag=3002,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=3,   ['REPAIR']=6,  },},},
		['AO3 CARGO HAWK'] = {        Flag=3003,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=2,   ['REPAIR']=4,  },},},
		['AO4 CARGO HAMA'] = {        Flag=4001,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO4 CARGO ALQUSAYR'] = {    Flag=4002,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO4 CARGO ROADBASE'] = {    Flag=4003,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO5 CARGO ROADBASE'] = {    Flag=5001,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO6 CARGO KHALKHALAH'] = {  Flag=6001,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO6 CARGO DAMASCUS'] = {    Flag=6002,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO6 CARGO MEZZEH'] = {      Flag=6003,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['FUEL']=2,   ['AMMO']=2,    },},},
		['AO6 CARGO PATRIOT'] = {     Flag=6004,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=3,   ['REPAIR']=6,  },},},
		['AO6 CARGO HAWK'] = {        Flag=6005,   Request={   [1]={   ['REPAIR']=2,   ['FUEL']=2,  },   [2]={   ['AMMO']=2,   ['REPAIR']=4,  },},},
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SlingloadLogistic.lua'
local Version = '201214'
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
local InternalCargoTypes = Cfg.InternalCargoTypes
local CargoZones = Cfg.CargoZones

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Save == nil then STNE.Save = {} end
if STNE.Save.Tables == nil then STNE.Save.Tables = {} end
if STNE.Save.Tables.SlingloadLogistic == nil then STNE.Save.Tables.SlingloadLogistic = {} end

-- Eventhandler
if STNE == nil then STNE = {} end
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.SlingloadLogistic == nil then STNE.EventHandler.SlingloadLogistic = {} end
STNE.EventHandler.SlingloadLogistic = EVENTHANDLER:New()
STNE.EventHandler.SlingloadLogistic:HandleEvent(world.event.S_EVENT_TAKEOFF)

-- Local variables
local Debug2 = false
local SlingloadMarkers = {}
local InternalCargoCapacity = {
    ['UH-1H'] = 1,
    ['Mi-8MT'] = 2,
    ['Yak-52'] = 1,
    ['TF-51D'] = 1,
    ['L-39C'] = 1,
    ['L-39ZA'] = 1,
    ['C-101EB'] = 1,
    ['C-101CC'] = 1,
}

-- Combine config tables
for ZoneName, _ in pairs(CargoZones) do
    if CargoZones[ZoneName]['InternalCargo'] == nil then
        CargoZones[ZoneName]['InternalCargo'] = UTILS.DeepCopy(InternalCargoTypes)
    end
end

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
                    if CargoZones[ZoneName]['SlingloadCargo'] ~= nil then
                        SpawnCount = 0
                        if CargoZones[ZoneName]['SlingloadCargo'][CargoName] ~= nil then
                            SpawnCount = CargoZones[ZoneName]['SlingloadCargo'][CargoName]
                        end
                    end
                    if SpawnCount > 0 then
                        for i = 1, SpawnCount, 1 do
                            table.insert(SpawnTable, CargoName)
                        end
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
--- @param CountedCargo table
--- @param ZoneName string
local function AddCachedCargo(CountedCargo, ZoneName)
    if STNE.Save.Tables.SlingloadLogistic[ZoneName] ~= nil then
        if Debug then BASE:E({FileVer,'AddCachedCargo',CountedCargo=CountedCargo,CachedCargo=STNE.Save.Tables.SlingloadLogistic[ZoneName]}) end
        for Cargo, Value in pairs(STNE.Save.Tables.SlingloadLogistic[ZoneName]) do
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
    local MarkerText = 'Available slingload cargo / internal cargo:'
    if Request then
        MarkerText = 'Request cargo:'
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
                local InternalCargo = 0
                if CargoZones[ZoneName]['InternalCargo'] ~= nil and CargoZones[ZoneName]['InternalCargo'][Coalition] ~= nil and CargoZones[ZoneName]['InternalCargo'][Coalition][Cargo] ~= nil then
                    InternalCargo = CargoZones[ZoneName]['InternalCargo'][Coalition][Cargo]
                end
                MarkerText = MarkerText..'\n'..tostring(Cargo)..' = '..tostring(Value)..' / '..tostring(InternalCargo)
            end
            if CargoZones[ZoneName]['InternalCargo'] ~= nil and CargoZones[ZoneName]['InternalCargo'][Coalition] ~= nil then
                for Cargo, Value in pairs(CargoZones[ZoneName]['InternalCargo'][Coalition]) do
                    if CountedCargo[Cargo] == nil then
                        MarkerText = MarkerText..'\n'..tostring(Cargo)..' = '..tostring(0)..' / '..tostring(Value)
                    end
                end
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
            if STNE.Save.Tables.SlingloadLogistic[ZoneName] == nil then
                STNE.Save.Tables.SlingloadLogistic[ZoneName] = {}
            end
            if STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] == nil then
                STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] = Value
            else
                STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] = STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] + Value
            end
        end
        CargoObj:Destroy()
    end
    if ToCache == false then
        if STNE.Save.Tables.SlingloadLogistic[ZoneName] ~= nil then
            STNE.Save.Tables.SlingloadLogistic[ZoneName] = nil
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
                local CargoX = math.floor(CargoCoord.x)
                local CargoY = math.floor(CargoCoord.y)
                local CargoZ = math.floor(CargoCoord.z)
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

--- Is cargo plane ready to load/unload
--- @param Client table
local function IsReadyToLoadInternalCargo(Client)
    local IsReady = false
    if Client ~= nil and Client:IsAlive() and Client:InAir() == false and Client:GetVelocityKNOTS() < 1 then
        IsReady = true
    end
    if Debug then BASE:E({FileVer,IsReadyToLoad=IsReady,Client=Client:GetPlayerName()}) end
    return IsReady
end

--- Get internal cargo zone for client
--- @param Client table
--- @param LoadCargo boolean
local function GetInternalCargoZone(Client, LoadCargo)
    local IsClientReady = IsReadyToLoadInternalCargo(Client)
    if Debug then BASE:E({FileVer,'GetInternalCargoZone',IsClientReady=IsClientReady,LoadCargo=LoadCargo,Client=Client:GetPlayerName()}) end
    local CargoZoneName = nil
    if IsClientReady then
        for ZoneName, ZoneData in pairs(CargoZones) do
            local ZoneObj = ZONE:FindByName(ZoneName)
            if ZoneObj then
                if Client:IsInZone(ZoneObj) then
                    local FlagValue = trigger.misc.getUserFlag(ZoneData.Flag)
                    local Coalition = Client:GetCoalition()
                    if Coalition == 1 then
                        if (LoadCargo and FlagValue == 1) or (not LoadCargo and FlagValue > 0) then
                            CargoZoneName = ZoneName
                        end
                    elseif Coalition == 2 then
                        if (LoadCargo and FlagValue == 2) or (not LoadCargo and FlagValue > 0) then
                            CargoZoneName = ZoneName
                        end
                    end
                end
            end
        end
    end
    return CargoZoneName
end

--- Can client load internal cargo
--- @param Client table
local function CanLoadCargo(Client)
    if Debug then BASE:E({FileVer,'CanLoadCargo',Client=Client:GetPlayerName()}) end
    local PlaneType = Client:GetTypeName()
    local LoadedCargoSpace = 0
    local CargoSpace = 0
    if Client.InternalCargo == nil then
        Client.InternalCargo = {}
    end
    for _, Value in pairs(Client.InternalCargo) do
        LoadedCargoSpace = LoadedCargoSpace + Value
    end
    if InternalCargoCapacity[PlaneType] ~= nil then
        CargoSpace = InternalCargoCapacity[PlaneType]
    end
    if CargoSpace > LoadedCargoSpace then
        return true
    end
    return false
end

--- Unload internal cargo
--- @param Client table
local function UnloadInternalCargo(Client)
    local ZoneName = GetInternalCargoZone(Client, false)
    if ZoneName ~= nil then
        if Debug then BASE:E({FileVer,UnloadInternalCargo=ZoneName,Client=Client:GetPlayerName()}) end
        if Client.InternalCargo ~= nil and not IsEmptyTable(Client.InternalCargo) then
            local FlagValue = trigger.misc.getUserFlag(CargoZones[ZoneName]['Flag'])
            local MessageText = 'UNLOAD INTERNAL CARGO:\n'
            if FlagValue == 1 or FlagValue == 2 then
                if CargoZones[ZoneName]['InternalCargo'] == nil then
                    CargoZones[ZoneName]['InternalCargo'] = {}
                end
                if CargoZones[ZoneName]['InternalCargo'][FlagValue] == nil then
                    CargoZones[ZoneName]['InternalCargo'][FlagValue] = {}
                end
                for Cargo, Value in pairs(Client.InternalCargo) do
                    if CargoZones[ZoneName]['InternalCargo'][FlagValue][Cargo] == nil then
                        CargoZones[ZoneName]['InternalCargo'][FlagValue][Cargo] = Value
                    else
                        CargoZones[ZoneName]['InternalCargo'][FlagValue][Cargo] = CargoZones[ZoneName]['InternalCargo'][FlagValue][Cargo] + Value
                    end
                    MessageText = MessageText..'\n'..Cargo..' = '..Value
                end
            else
                if STNE.Save.Tables.SlingloadLogistic[ZoneName] == nil then
                    STNE.Save.Tables.SlingloadLogistic[ZoneName] = {}
                end
                for Cargo, Value in pairs(Client.InternalCargo) do
                    if STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] == nil then
                        STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] = Value
                    else
                        STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] = STNE.Save.Tables.SlingloadLogistic[ZoneName][Cargo] + Value
                    end
                    MessageText = MessageText..'\n'..Cargo..' = '..Value
                end
            end
            MessageText = MessageText..'\n '
            MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
            Client.InternalCargo = {}
            Client.InternalCargoMenuUnload:Remove()
            if Client.InternalCargoMenuLoad ~= nil then
                for Cargo, _ in pairs(Client.InternalCargoMenuLoad) do
                    Client.InternalCargoMenuLoad[Cargo]:Remove()
                end
            end
        end
    else
        local MessageText = 'CANNOT UNLOAD INTERNAL CARGO HERE'
        MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
    end
end

--- Load internal cargo
--- @param ClientData table
local function LoadInternalCargo(ClientData)
    local Client = ClientData[1]
    local LCargo = ClientData[2]
    local ZoneName = GetInternalCargoZone(Client, true)
    if ZoneName ~= nil then
        if Debug then BASE:E({FileVer,LoadInternalCargo=ZoneName,Client=Client:GetPlayerName()}) end
        local Coalition = Client:GetCoalition()
        if CanLoadCargo(Client) then
            if CargoZones[ZoneName]['InternalCargo'][Coalition][LCargo] >= 1 then
                CargoZones[ZoneName]['InternalCargo'][Coalition][LCargo] = CargoZones[ZoneName]['InternalCargo'][Coalition][LCargo] - 1
                if Client.InternalCargo[LCargo] == nil then
                    Client.InternalCargo[LCargo] = 0
                end
                Client.InternalCargo[LCargo] = Client.InternalCargo[LCargo] + 1
                local MessageText = 'INTERNAL CARGO LOADED:\n\n'..LCargo..' = '..tostring(1)..'\n '
                MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
                Client.InternalCargoMenuUnload = MENU_GROUP_COMMAND:New(Client:GetGroup(), 'Unload all cargo', Client.InternalCargoMenu, UnloadInternalCargo, Client)
            else
                local MessageText = 'NO INTERNAL CARGO TO LOAD: '..LCargo
                MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
            end
        else
            local MessageText = 'INTERNAL CARGO SPACE FULL'
            MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
            for Cargo, _ in pairs(Client.InternalCargoMenuLoad) do
                Client.InternalCargoMenuLoad[Cargo]:Remove()
            end
        end
    else
        local MessageText = 'CANNOT LOAD INTERNAL CARGO'
        MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
    end
end

--- Add load cargo menus for client
--- @param Client table
--- @param CargoOnGround table
local function AddLoadCargoMenus(Client, CargoOnGround)
    if Debug then BASE:E({FileVer,'AddLoadCargoMenus',Client=Client:GetPlayerName()}) end
    if Client.InternalCargoMenuLoad == nil then
        Client.InternalCargoMenuLoad = {}
    end
    for Cargo, _ in pairs(Client.InternalCargoMenuLoad) do
        Client.InternalCargoMenuLoad[Cargo]:Remove()
    end
    if CargoOnGround ~= nil and CanLoadCargo(Client) then
        for Cargo, _ in pairs(CargoOnGround) do
            Client.InternalCargoMenuLoad[Cargo] = MENU_GROUP_COMMAND:New(Client:GetGroup(), 'Load cargo: '..Cargo, Client.InternalCargoMenu, LoadInternalCargo, {Client,Cargo})
        end
    end
end

--- Get available internal cargo for client
--- @param Client table
local function GetAvailableInternalCargo(Client)
    if Debug then BASE:E({FileVer,'GetAvailableInternalCargo',Client=Client:GetPlayerName()}) end
    local CargoTable = {}
    local ZoneName = GetInternalCargoZone(Client, true)
    if ZoneName ~= nil then
        local Coalition = Client:GetCoalition()
        if CargoZones[ZoneName]['InternalCargo'] ~= nil and CargoZones[ZoneName]['InternalCargo'][Coalition] ~= nil then
            for Cargo, Value in pairs(CargoZones[ZoneName]['InternalCargo'][Coalition]) do
                if Value ~= nil and Value > 0 then
                    CargoTable[Cargo] = Value
                end
            end
        end
    end
    return CargoTable
end

--- Show internal cargo status message for client group
--- @param Client table
local function ShowInternalCargo(Client)
    if Debug then BASE:E({FileVer,'ShowInternalCargo',Client=Client:GetPlayerName()}) end
    local PlaneType = Client:GetTypeName()
    local CargoSpace = 0
    if InternalCargoCapacity[PlaneType] ~= nil then
        CargoSpace = InternalCargoCapacity[PlaneType]
    end
    local MessageText = '******************************\nINTERNAL CARGO SPACE: '..CargoSpace..'\n******************************\n'
    if Client.InternalCargo ~= nil and not IsEmptyTable(Client.InternalCargo) then
        for Cargo, Value in pairs(Client.InternalCargo) do
            MessageText = MessageText..'\n'..Cargo..' = '..Value
        end
    else
        MessageText = MessageText..'\nNo internal cargo'
    end
    local CargoOnGround = GetAvailableInternalCargo(Client)
    if not IsEmptyTable(CargoOnGround) then
        MessageText = MessageText..'\n\n******************************\nCARGO ON GROUND:\n******************************\n'
        for Cargo, Value in pairs(CargoOnGround) do
            MessageText = MessageText..'\n'..Cargo..' = '..Value
        end
        AddLoadCargoMenus(Client, CargoOnGround)
    end
    MessageText = MessageText..'\n '
    MESSAGE:New(MessageText, 15, nil, true):ToGroup(Client:GetGroup())
end

--- Add menus for client group
--- @param Client table
local function AddGroupMenus(Client)
    if Debug then BASE:E({FileVer,'AddGroupMenus',Client=Client:GetPlayerName()}) end
    Client.InternalCargo = {}
    Client.InternalCargoMenu = MENU_GROUP:New(Client:GetGroup(), 'Internal Cargo')
    Client.InternalCargoMenuStatus = MENU_GROUP_COMMAND:New(Client:GetGroup(), 'Internal cargo / Cargo on ground', Client.InternalCargoMenu, ShowInternalCargo, Client)
end

-- Client joins slot event
local Clients_Set = SET_CLIENT:New()
Clients_Set:FilterStart()
Clients_Set:ForEachClient(
    function(Client)
        Client:Alive(AddGroupMenus, Client)
    end
)

-- OnEventTakeoff event
function STNE.EventHandler.SlingloadLogistic:OnEventTakeoff(EventData)
    if Debug then BASE:E({FileVer,'OnEventTakeoff'}) end
    BASE:E(EventData)
    if EventData.IniUnitName ~= nil then
        local Client = CLIENT:FindByName(EventData.IniUnitName)
        if Client ~= nil then
            if Client.InternalCargoMenuLoad ~= nil then
                for Cargo, _ in pairs(Client.InternalCargoMenuLoad) do
                    Client.InternalCargoMenuLoad[Cargo]:Remove()
                end
            end
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
