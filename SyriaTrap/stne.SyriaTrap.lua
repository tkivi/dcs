local Cfg = {
--#################################################################################################
--
--  SyriaTrap
--
--  Syria trap mission flag sniffer. Create menus and spawn/destroy groups.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                              -- Debug mode, true/false
    FlagData = {                                                -- Flag data
    --  [flag] = {'GroupName', 'MainMenu', 'SubMenu', 'CompleteFlag', 'DestinationZone', 'AOFlag', 'AOZone', 'DestinationNameForMessage'}
        -- AO Aleppo
        [1300] = {'AO1 ASSAULT MINAKH', 'AO Aleppo', 'Order Attack Minakh', 1210, 'AO1 ASSAULT MINAKH', 130, 'AO1 ALEPPO', 'Minakh'},
        [1301] = {'AO1 ASSAULT ALEPPO', 'AO Aleppo', 'Order Attack Aleppo', 1211, 'AO1 ASSAULT ALEPPO', 131, 'AO1 ALEPPO', 'Aleppo'},
        [1302] = {'AO1 ASSAULT KUWEIRES', 'AO Aleppo', 'Order Attack Kuweires', 1212, 'AO1 ASSAULT KUWEIRES', 132, 'AO1 ALEPPO', 'Kuweires'},
        [1303] = {'AO1 ASSAULT JIRAH', 'AO Aleppo', 'Order Attack Jirah', 1213, 'AO1 ASSAULT JIRAH', 133, 'AO1 ALEPPO', 'Jirah'},
        [1310] = {'AO1 ASSAULT TAFTANAZ', 'AO Aleppo', 'Order Attack Taftanaz', 1214, 'AO1 ASSAULT TAFTANAZ', 134, 'AO1 ALEPPO', 'Taftanaz'},
        [1311] = {'AO1 ASSAULT ABU AL DUHUR', 'AO Aleppo', 'Order Attack, Abu Al Duhur', 1215, 'AO1 ASSAULT ABU AL DUHUR', 135, 'AO1 ALEPPO', 'Abu Al Duhur'},
        [1312] = {'AO1 ASSAULT AL SAFIRAH', 'AO Aleppo', 'Order Attack Al Safirah', 1216, 'AO1 ASSAULT AL SAFIRAH', 136, 'AO1 ALEPPO', 'Al Safirah'},
        -- AO Raqqa
        [2300] = {'AO2 ASSAULT TABQA', 'AO Raqqa', 'Order Attack Tabqa', 2210, 'AO2 ASSAULT TABQA', 230, 'AO2 RAQQA', 'Tabqa'},
        -- AO Latakia
        [3300] = {'AO3 ASSAULT TARTUS', 'AO Latakia', 'Order Attack Tartus', 3212, 'AO3 ASSAULT TARTUS', 330, 'AO3 LATAKIA', 'Tartus'},
        [3301] = {'AO3 ASSAULT JABLAH', 'AO Latakia', 'Order Attack Jablah', 3211, 'AO3 ASSAULT JABLAH', 331, 'AO3 LATAKIA', 'Jablah'},
        [3302] = {'AO3 ASSAULT BASSEL ASSAD', 'AO Latakia', 'Order Attack Bassel Assad', 3210, 'AO3 ASSAULT BASSEL ASSAD', 332, 'AO3 LATAKIA', 'Bassel Assad'},
        -- AO Hama
        [4300] = {'AO4 ASSAULT AL QUSAYR', 'AO Hama', 'Order Attack Al Qusayr', 4212, 'AO4 ASSAULT AL QUSAYR', 430, 'AO4 HAMA', 'Al Qusayr'},
        [4301] = {'AO4 ASSAULT ADA', 'AO Hama', 'Order Attack ADA Stronghold', 4211, 'AO4 ASSAULT ADA', 431, 'AO4 HAMA', 'Ada'},
        [4302] = {'AO4 ASSAULT HAMA', 'AO Hama', 'Order Attack Hama', 4210, 'AO4 ASSAULT HAMA', 432, 'AO4 HAMA', 'Hama'},
        [4303] = {'AO4 ASSAULT AN NASIRIYAH', 'AO Hama', 'Order Attack An Nasiriyah', 4213, 'AO4 ASSAULT AN NASIRIYAH', 433, 'AO4 HAMA', 'An Nasiriyah'},
        -- AO Palmyra
        [5300] = {'AO5 ASSAULT PALMYRA', 'AO Palmyra', 'Order Attack Palmyra', 5210, 'AO5 ASSAULT PALMYRA', 530, 'AO5 PALMYRA', 'Palmyra'},
        -- AO Damascus
        [6300] = {'AO6 ASSAULT MEZZEH', 'AO Damascus', 'Order Attack Mezzeh', 6212, 'AO6 ASSAULT MEZZEH', 630, 'AO6 DAMASCUS', 'Mezzeh'},
        [6301] = {'AO6 ASSAULT Qabr As Sitt', 'AO Damascus', 'Order Attack Qabr As Sitt', 6215, 'AO6 ASSAULT Qabr As Sitt', 631, 'AO6 DAMASCUS', 'Qabr As Sitt'},
        [6302] = {'AO6 ASSAULT MARJ AS SULTAN', 'AO Damascus', 'Order Attack Marj As Sultan', 6216, 'AO6 ASSAULT MARJ AS SULTAN', 632, 'AO6 DAMASCUS', 'Marj As Sultan'},
        [6303] = {'AO6 ASSAULT KHALKHALAH', 'AO Damascus', 'Order Attack Khalkhalah', 6214, 'AO6 ASSAULT KHALKHALAH', 633, 'AO6 DAMASCUS', 'Khalkhalah'},
        [6304] = {'AO6 ASSAULT MARJ RUHAYYIL', 'AO Damascus', 'Order Attack Marj Ruhayyil', 6213, 'AO6 ASSAULT MARJ RUHAYYIL', 634, 'AO6 DAMASCUS', 'Marj Ruhayyil'},
        [6305] = {'AO6 ASSAULT DAMASCUS', 'AO Damascus', 'Order Attack Damascus', 6211, 'AO6 ASSAULT DAMASCUS', 635, 'AO6 DAMASCUS', 'Damascus'},
        [6306] = {'AO6 ASSAULT AL DUMAYR', 'AO Damascus', 'Order Attack Al Dumayr', 6210, 'AO6 ASSAULT AL DUMAYR', 636, 'AO6 DAMASCUS', 'Al Dumayr'},
    },
    Objectives = {                                              -- Map markers
        ['AO Aleppo'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO1 OBJ EWR1', 'Early warning radar site 1'},
            {'AO1 OBJ EWR2', 'Early warning radar site 2'},
            {'AO1 OBJ EWR3', 'Early warning radar site 3'},
            {'AO1 OBJ COMS CENTER', 'Aleppo Communications Center'},
            {'AO1 OBJ IOC', 'Intercept Operations Center'},
            {'AO1 OBJ SOC', 'Sector Operations Center'},
        },
        ['AO Raqqa'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO2 OBJ EWR1', 'Early warning radar site 1'},
            {'AO2 OBJ EWR2', 'Early warning radar site 2'},
            {'AO2 OBJ COMS CENTER', 'Raqqa Communications Center'},
            {'AO2 OBJ POWER PLANT', 'Power Plant'},
            {'AO2 OBJ FUEL TANK1', 'Fuel Tank 1'},
            {'AO2 OBJ FUEL TANK2', 'Fuel Tank 2'},
            {'AO2 OBJ FUEL TANK3', 'Fuel Tank 3'},
            {'AO2 OBJ FUEL TANK4', 'Fuel Tank 4'},
            {'AO2 OBJ FUEL TANK5', 'Fuel Tank 5'},
            {'AO2 OBJ FUEL TANK6', 'Fuel Tank 6'},
        },
        ['AO Latakia'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO3 OBJ EWR1', 'Early warning radar site 1'},
            {'AO3 OBJ EWR2', 'Early warning radar site 2'},
            {'AO3 OBJ COMS CENTER', 'Jablah Communications Center'},
            {'AO3 OBJ SOC', 'Sector Operations Center'},
            {'AO3 OBJ IOC', 'Intercept Operations Center'},
            {'AO3 OBJ Neustrashimy-class frigate', 'Neustrashimy-class frigate'},
            {'AO3 OBJ Krivak-class frigate', 'Krivak-class frigate'},
            {'AO3 OBJ Tarantul-class corvette', 'Tarantul-class corvette'},
            {'AO3 OBJ SILKWORM1', 'Silkworm Site North'},
            {'AO3 OBJ SILKWORM2', 'Silkworm Site South'},
        },
        ['AO Hama'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO4 OBJ EWR1', 'Early warning radar site 1'},
            {'AO4 OBJ EWR2', 'Early warning radar site 2'},
            {'AO4 OBJ COMS CENTER', 'Hama Communications Center'},
            {'AO4 OBJ SOC', 'Sector Operations Center'},
            {'AO4 OBJ IOC', 'Intercept Operations Center'},
            {'AO4 OBJ ADOC', 'Air Defence Operations Center'},
            {'AO4 OBJ SCUD1', 'SCUD site'},
        },
        ['AO Palmyra'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO5 OBJ EWR1', 'Early warning radar site 1'},
            {'AO5 OBJ EWR2', 'Early warning radar site 2'},
            {'AO5 OBJ ADOC1', 'Air Defence Operations Center 1'},
            {'AO5 OBJ ADOC2', 'Air Defence Operations Center 2'},
            {'AO5 OBJ ADOC3', 'Air Defence Operations Center 3'},
            {'AO5 OBJ CHEMICAL PLANT', 'Chemical Plant'},
            {'AO5 OBJ CHEMICAL STORAGE1', 'Chemical Storage1'},
            {'AO5 OBJ CHEMICAL STORAGE2', 'Chemical Storage2'},
            {'AO5 OBJ TANK1', 'Chemical Tank 1'},
            {'AO5 OBJ TANK2', 'Chemical Tank 2'},
            {'AO5 OBJ TANK3', 'Chemical Tank 3'},
        },
        ['AO Damascus'] = {
        --  {'GroupOrStaticName', 'Description'}
            {'AO6 OBJ EWR1', 'Early warning radar site 1'},
            {'AO6 OBJ EWR2', 'Early warning radar site 2'},
            {'AO6 OBJ EWR3', 'Early warning radar site 3'},
            {'AO6 OBJ COMS CENTER', 'Damascus Communications Center'},
            {'AO6 OBJ SOC', 'Sector Operations Center'},
            {'AO6 OBJ IOC', 'Intercept Operations Center'},
            {'AO6 OBJ SCUD1', 'SCUD Site'},
            {'AO6 OBJ MLRS1', 'MLRS Site 1'},
            {'AO6 OBJ MLRS2', 'MLRS Site 2'},
            {'AO6 OBJ LADA SAMARA', 'Assads prized Lada Samara'},
        },
    },
    StatusMessages = {                                          -- Status message for coalition
        ['AO Aleppo'] = {                                       -- MainMenu
            ['OBJECTIVES'] = {                                  -- Header
                [1110] = 'Early Warning Radar West',            -- [flag] = description
                [1111] = 'Early Warning Radar Aleppo',
                [1112] = 'Early Warning Radar South-East',
                [1113] = 'Aleppo Communications Center',
                [1114] = 'Al Safirah Sector Operations Center',
                [1115] = 'Al Safirah Intercept Operations Center',
                [1116] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99101] = 'Minakh AB Fighters',
                [99121] = 'Minakh AB Helicopters',
                [99102] = 'Jirah AB Fighters',
                [99103] = 'Al Duhur AB Fighters',
                [99111] = 'Kuweires AB Attack Aircraft',
                [99122] = 'Taftanaz AB Helicopters',
            },
        },
        ['AO Raqqa'] = {
            ['OBJECTIVES'] = {
                [2110] = 'Early Warning Radar North-West',
                [2111] = 'Early Warning Radar Al Tabqah',
                [2113] = 'Raqqa Communications Center',
                [2114] = 'Al Tabqah Power Plant',
                [2115] = 'Resafa Fuel Reserve',
                [2116] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99201] = 'Raqqa AB Fighters',
                [99211] = 'Raqqa AB Attack Aircraft',
            },
        },
        ['AO Latakia'] = {
            ['OBJECTIVES'] = {
                [3110] = 'Early Warning Radar North',
                [3111] = 'Early Warning Radar South',
                [3113] = 'Jablah Communications Center',
                [3114] = 'Tartus Sector Operations Center',
                [3115] = 'Jablah Intercept Operations Center',
                [3116] = 'Neustrashimy-class frigate',
                [3117] = 'Krivak-class frigate',
                [3118] = 'Tarantul-class corvette',
                [3119] = 'Silkworm site North',
                [3120] = 'Silkworm site South',
                [3121] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99301] = 'Bassel Assad AB Fighters',
                [99311] = 'Bassel Assad AB Attack Aircraft',
                [99321] = 'Bassel Assad AB Helicopters',
            },
        },
        ['AO Hama'] = {
            ['OBJECTIVES'] = {
                [4110] = 'Early Warning Radar North',
                [4111] = 'Early Warning Radar South',
                [4113] = 'Hama Communications Center',
                [4114] = 'ADA Sector Operations Center',
                [4115] = 'ADA Intercept Operations Center',
                [4116] = 'ADA Air Defence Operations Center',
                [4117] = 'SCUD site',
                [4118] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99401] = 'Hama AB Fighters',
                [99421] = 'Hama AB Helicopters',
                [99402] = 'Al Qusayr AB Fighters',
                [99411] = 'Al Qusayr AB Attack Aircraft',
                [99403] = 'An Nasiriyah AB Fighters',
            },
        },
        ['AO Palmyra'] = {
            ['OBJECTIVES'] = {
                [5110] = 'Early Warning Radar North',
                [5111] = 'Early Warning Radar South',
                [5124] = 'Palmyra Air Defence Operations Center',
                [5130] = 'Chemical Weapons Plant',
                [5131] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99501] = 'Palmyra AB Fighters',
            },
        },
        ['AO Damascus'] = {
            ['OBJECTIVES'] = {
                [6110] = 'Early Warning Radar West',
                [6111] = 'Early Warning Radar South',
                [6112] = 'Early Warning Radar North-West',
                [6113] = 'Damascus Communications Center',
                [6114] = '150th Regiment Sector Operations Center',
                [6115] = '100th Regiment Intercept Operations Center',
                [6116] = 'SCUD site',
                [6117] = 'MLRS site 1',
                [6118] = 'MLRS site 2',
                [6119] = 'Assads Lada Samara',
                [6120] = 'Order attacks and support ground war',
            },
            ['ACTIVE ENEMY AIRFIELDS'] = {
                [99601] = 'Khalkhalah AB Fighters',
                [99602] = 'Marj Ruhayyil AB Fighters',
                [99603] = 'Mezzeh AB Fighters',
                [99623] = 'Mezzeh AB Helicopters',
                [99604] = 'Al Dumayr AB Fighters',
                [99612] = 'Al Dumayr AB Attack Aircraft',
                [99611] = 'Damascus AB Attack Aircraft',
                [99621] = 'Marj As Sultan AB Helicopters',
                [99622] = 'Qabr As Sitt AB Helicopters',
            },
        },
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SyriaTrap.lua'
local Version = '201001'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SyriaTrap then
    for key, value in pairs(STNE_Config_SyriaTrap) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local FlagData = Cfg.FlagData
local Objectives = Cfg.Objectives
local StatusMessages = Cfg.StatusMessages

-- Local tables
local Menus = {}
local MainMenus = {}
local Markers = {}

-- Get main menu names
for _, FlagData in pairs(FlagData) do
    local MainMenuName = FlagData[2]
    if MainMenus[MainMenuName] == nil then
        MainMenus[MainMenuName] = true
    end
end

-- Show status (Text and F10 markers)
local function ShowStatus(ObjectiveName)
    -- Map markers
    if Objectives[ObjectiveName] ~= nil then
        for _, ObjectiveData in pairs(Objectives[ObjectiveName]) do
            local Name = ObjectiveData[1]
            local Marker = Markers[Name]
            if Marker ~= nil then
                Marker:Remove()
            end
        end
        for _, ObjectiveData in pairs(Objectives[ObjectiveName]) do
            local Name = ObjectiveData[1]
            local Desc = ObjectiveData[2]
            if Debug then BASE:E({FileVer,'Marker name '..Name}) end
            local Obj = GROUP:FindByName(Name)
            local Coord = nil
            if Obj == nil then
                Obj = STATIC:FindByName(Name)
            end
            if Obj ~= nil and Obj:IsAlive() then
                Coord = Obj:GetCoordinate()
            end
            if Coord ~= nil then
                if Debug then BASE:E({FileVer,'Create marker'}) end
                local RandomCoord = Coord:Translate(math.random(100,1000), math.random(0,359))
                Markers[Name] = MARKER:New(RandomCoord, Name)
                Markers[Name]:SetText(Desc)
                Markers[Name]:ToBlue()
            end
        end
    end
    -- Message
    if StatusMessages[ObjectiveName] ~= nil then
        local AOData = StatusMessages[ObjectiveName]
        local MessageOutput = ''
        local Stars = '****************'
        local NextLine = '\n'
        local MessageH = Stars..NextLine..ObjectiveName..' STATUS'..NextLine..Stars..NextLine..NextLine
        local MessageT1 = ''
        for Header, HeaderData in pairs(AOData) do
            local MessageT2 = ''
            for Flag, _ in pairs(HeaderData) do
                local FlagValue = trigger.misc.getUserFlag(Flag)
                if FlagValue == 0 then
                    MessageT2 = MessageT2..HeaderData[Flag]..NextLine
                end
            end
            if MessageT2 ~= '' then
                MessageT1 = MessageT1..Header..NextLine..MessageT2..NextLine..NextLine
            end
        end
        if MessageT1 == '' then
            MessageT1 = 'ALL OBJECTIVES COMPLETED'..NextLine
        end
        MessageOutput = MessageH..MessageT1
        MESSAGE:New(MessageOutput, 30):ToBlue()
    end
end

-- Dummy function menu option
local function DummyFunction(Name)
    if Debug then BASE:E({FileVer,'DummyFunction'}) end
end

-- Add main menus
for Name, _ in pairs(MainMenus) do
    if Debug then BASE:E({FileVer,'AddMainMenu '..Name}) end
    Menus[Name] = {}
    Menus[Name].Main = MENU_COALITION:New(coalition.side.BLUE, Name)
    Menus[Name].Status = MENU_COALITION_COMMAND:New(coalition.side.BLUE, 'Show Status', Menus[Name].Main, ShowStatus, Name)
    for _, FlagData in pairs(FlagData) do
        local MainMenu = FlagData[2]
        local SubMenu = FlagData[3]
        if Name == MainMenu then
            Menus[MainMenu][SubMenu] = {}
            if Debug then BASE:E({FileVer,'Prepare table',MainMenu=MainMenu,SubMenu=SubMenu}) end
        end
    end
end

--[[ TEST TEST TEST
local Clients_Set = SET_CLIENT:New()
Clients_Set:FilterActive()
Clients_Set:FilterStart()
SCHEDULER:New(nil, function()
    Clients_Set:ForEachClient(
        function(CurClient)
            local ClientName = CurClient:GetName()
            for Name, _ in pairs(MainMenus) do
                if Menus[Name].Status == nil then
                    if Debug then BASE:E({FileVer,'AddGroupMenu '..Name..' for '..ClientName}) end
                    Menus[Name].Main = MENU_GROUP:New(CurClient, Name)
                    Menus[Name].Status = MENU_GROUP_COMMAND:New(CurClient, 'Show Status', Menus[Name].Main, ShowStatus, Name)
                end
            end
        end
    )
end, {}, 5, 5) ]]
-- TEST TEST TEST

-- Remove sub menus
local function RemoveSubMenus(FlagData)
    local MainMenu = FlagData[2]
    local SubMenu = FlagData[3]
    if Debug then BASE:E({FileVer,'RemoveSubMenus',MainMenu=MainMenu,SubMenu=SubMenu}) end
    if Menus[MainMenu][SubMenu].Assault ~= nil then
        Menus[MainMenu][SubMenu].Assault:Remove()
        Menus[MainMenu][SubMenu].Assault = nil
    end
    if Menus[MainMenu][SubMenu].Progress ~= nil then
        Menus[MainMenu][SubMenu].Progress:Remove()
        Menus[MainMenu][SubMenu].Progress = nil
    end
    if Menus[MainMenu][SubMenu].Complete ~= nil then
        Menus[MainMenu][SubMenu].Complete:Remove()
        Menus[MainMenu][SubMenu].Complete = nil
    end
end

-- Spawn group
local function SpawnGroup(FlagData)
    local GroupName = FlagData[1]
    local MainMenu = FlagData[2]
    local SubMenu = FlagData[3]
    if Debug then BASE:E({FileVer,SpawnGroup=GroupName}) end
    local Group = GROUP:FindByName(GroupName)
    if Group ~= nil then
        local Template = Group:GetTemplate()
        --Template.lateActivation = false
        --if Menus[MainMenu].Progress == nil then
        if Menus[MainMenu][SubMenu].Progress == nil then
            RemoveSubMenus(FlagData)
            --SubMenu = '[IN PROGRESS] '..SubMenu
            Menus[MainMenu][SubMenu].Progress = MENU_COALITION_COMMAND:New(coalition.side.BLUE, '[IN PROGRESS] '..SubMenu, Menus[MainMenu].Main, DummyFunction)
            if Debug then BASE:E({FileVer,FlagData=FlagData,'AddSubMenuProgress',MainMenu=MainMenu,SubMenu=SubMenu}) end
        end
        SPAWN:NewFromTemplate(Template, GroupName, GroupName):InitKeepUnitNames(true):Spawn()
        --_DATABASE:Spawn(Template)
        -- Message to reds
        MESSAGE:New('BLUE ground forces are on the move towards '..FlagData[8], 30):ToRed()
    end
end

-- Add sub menu assault
local function AddAssaultMenu(FlagData)
    local MainMenu = FlagData[2]
    local SubMenu = FlagData[3]
    if Menus[MainMenu][SubMenu].Assault == nil then
        RemoveSubMenus(FlagData)
        Menus[MainMenu][SubMenu].Assault = MENU_COALITION_COMMAND:New(coalition.side.BLUE, SubMenu, Menus[MainMenu].Main, SpawnGroup, FlagData)
        if Debug then BASE:E({FileVer,FlagData=FlagData,'AddSubMenuAssault',MainMenu=MainMenu,SubMenu=SubMenu}) end
    end
end

-- Add sub menu complete
local function AddCompleteMenu(FlagData)
    local MainMenu = FlagData[2]
    local SubMenu = FlagData[3]
    if Menus[MainMenu][SubMenu].Complete == nil then
        RemoveSubMenus(FlagData)
        --SubMenu = '[COMPLETE] '..SubMenu
        Menus[MainMenu][SubMenu].Complete = MENU_COALITION_COMMAND:New(coalition.side.BLUE, '[COMPLETE] '..SubMenu, Menus[MainMenu].Main, DummyFunction)
        if Debug then BASE:E({FileVer,FlagData=FlagData,'AddSubMenuComplete',MainMenu=MainMenu,SubMenu=SubMenu}) end
    end
end

--[[ Send message to all
local function SendMessageToAll(Message)
    if Message ~= nil then
        MESSAGE:New(Message, 30):ToAll()
    end
end

-- Send message to red
local function SendMessageToRed(Message)
    if Message ~= nil then
        MESSAGE:New(Message, 30):ToRed()
    end
end
]]

-- Flag sniffer
SCHEDULER:New(nil, function()
    for Flag, _ in pairs(FlagData) do
        local Value = trigger.misc.getUserFlag(Flag)
        if Value >= 1 then
            if FlagData[Flag] ~= nil then
                if Debug then BASE:E({FileVer,'FlagSniffer',Flag=Flag,Value=Value,FlagData=FlagData[Flag]}) end
                local PreventFlag = trigger.misc.getUserFlag(FlagData[Flag][4])
                local Group = GROUP:FindByName(FlagData[Flag][1])
                if PreventFlag == 0 then
                    if Group ~= nil and Group:IsAlive() ~= true then
                        AddAssaultMenu(FlagData[Flag])
                    end
                else
                    if Group ~= nil and Group:IsAlive() then
                        -- Send message to all
                        MESSAGE:New('BLUE ground forces have taken '..FlagData[Flag][8], 30):ToAll()
                        --SendMessageToAll()
                        Group:Destroy()
                    end
                    AddCompleteMenu(FlagData[Flag])
                end
            end
        end
    end
end, {}, 10, 10)

-- Group in zone sniffer
SCHEDULER:New(nil, function()
    for Flag, _ in pairs(FlagData) do
        if FlagData[Flag] ~= nil then
            local GroupName = (FlagData[Flag][1])
            local InZoneFlag = (FlagData[Flag][4])
            local ZoneName = (FlagData[Flag][5])
            local InAOZoneFlag = (FlagData[Flag][6])
            local AOZoneName = (FlagData[Flag][7])
            local InZoneFlagValue = trigger.misc.getUserFlag(InZoneFlag)
            local InAOZoneFlagValue = trigger.misc.getUserFlag(InAOZoneFlag)
            if Debug then BASE:E({FileVer,'GroupInZoneSniffer',Group=GroupName,InZoneFlag=InZoneFlag,InZoneFlagValue=InZoneFlagValue,DestinationZone=ZoneName,AOZone=AOZoneName,InAOZoneFlag=InAOZoneFlag,InAOZoneFlagValue=InAOZoneFlagValue}) end
            local Grp = GROUP:FindByName(GroupName)
            local ZoneObj = ZONE:FindByName(ZoneName)
            local AOZoneObj = ZONE:FindByName(AOZoneName)
            if ZoneObj == nil or AOZoneObj == nil then
                local ErrorMsg = 'ERROR: '..FileVer..' Invalid zone name'
                MESSAGE:New(ErrorMsg, 300):ToAll()
                env.info(ErrorMsg)
            end
            if Grp ~= nil and Grp:IsAlive() then
                if Grp:IsPartlyOrCompletelyInZone(ZoneObj) then
                    trigger.action.setUserFlag(InZoneFlag, 1)
                end
                if Grp:IsPartlyOrCompletelyInZone(AOZoneObj) then
                    trigger.action.setUserFlag(InAOZoneFlag, 1)
                else
                    trigger.action.setUserFlag(InAOZoneFlag, 0)
                end
            else
                trigger.action.setUserFlag(InAOZoneFlag, 0)
            end
        end
    end
end, {}, 60, 60)

-- EOF
env.info('FILE: '..FileVer..' END')
