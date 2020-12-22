local Cfg = {
--#################################################################################################
--
--  OperationFlagsMarkers
--
--  Operation map markers and F10 menu info. Set flag true if defined object dies.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                                  -- Debug mode, true/false
    Markers = true,                                                 -- Show map markers, true/false
    F10Menu = true,                                                 -- Enable F10 menu, true/false
    Targets = {
        [1] = {                                                     -- Coalition number, 1 = Red
            [1001] = { Description = 'My little house', ObjectName = 'Static Armed house-1', },
        },
        [2] = {                                                     -- Coalition number, 2 = Blue
            [2001] = {                                              -- Flag, values: 0 = in progress, 1 = completed
                Description = 'Bandar Abbas International',         -- Description for F10 menu and map marker
                ObjectName = 'Bandar Abbas Intl',                   -- (optional) GROUP, UNIT, STATIC or AIRBASE object name
                Precision = 0,                                      -- (optional) Map marker precision, meters
                Area = 'AO Bandar Abbas',                           -- (optional) Area of operation name (= F10 submenu)
                Category = 'ACTIVE ENEMY AIRFIELDS',                -- (optional) Category name in show status message (= header in message)
                InvertMarker = true,                                -- (optional) Invert show map markers value for this entry, true/false
            },
            [2002] = { Description = 'Armored unit',        Area = 'AO Bandar Abbas', Category = 'OBJECTIVES', ObjectName = 'Ground-1', Precision = 500, },
            [2003] = { Description = 'Virual armored unit', Area = 'AO Something',    Category = 'BAD BOYS', },
            [2004] = { Description = 'Virual armored unit', },
            [2005] = { Description = 'Virual armored unit', },
        },
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.OperationFlagsMarkers.lua'
local Version = '201221'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_OperationFlagsMarkers then
    for key, value in pairs(STNE_Config_OperationFlagsMarkers) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local Targets = Cfg.Targets
local Markers = Cfg.Markers
local F10Menu = Cfg.F10Menu

-- Local variables
local OperationMarkers = {}

--- Remove map marker
--- @param ObjectName string
local function RemoveMapMarker(ObjectName)
    if OperationMarkers[ObjectName] ~= nil then
        if Debug then BASE:E({FileVer,'RemoveMapMarker',ObjectName=ObjectName}) end
        OperationMarkers[ObjectName]:Remove()
        OperationMarkers[ObjectName] = nil
    end
end

--- Find object and return coord if alive
--- @param ObjectName string
local function FindObjectByName(ObjectName)
    if ObjectName == nil then
        return true, nil
    end
    local Obj = nil
    local Coord = nil
    local ObjType = ''
    if GROUP:FindByName(ObjectName) then
        Obj = GROUP:FindByName(ObjectName)
        ObjType = 'GROUP'
    elseif UNIT:FindByName(ObjectName) then
        Obj = UNIT:FindByName(ObjectName)
        ObjType = 'UNIT'
    elseif AIRBASE:FindByName(ObjectName) then
        Obj = AIRBASE:FindByName(ObjectName)
        ObjType = 'AIRBASE'
    elseif STATIC:FindByName(ObjectName, false) then
        Obj = STATIC:FindByName(ObjectName, false)
        ObjType = 'STATIC'
    end
    if Obj ~= nil and Obj:IsAlive() then
        Coord = Obj:GetCoordinate()
    end
    if Coord == nil then
        if Debug then BASE:E({FileVer,'FindObjectByName',ObjectName=ObjectName,Alive='false'}) end
        return false, nil
    else
        if Debug then BASE:E({FileVer,'FindObjectByName',ObjectName=ObjectName,Alive='true',Type=ObjType}) end
        return true, Coord
    end
end

--- Add/refresh map marker
--- @param ObjectName string
--- @param MarkerText string
--- @param Precision number
--- @param Coalition number
--- @param Coord table
local function AddRefreshMapMarker(ObjectName, MarkerText, Precision, Coalition, Coord)
    local TranslatedCoord = Coord:Translate(Precision, math.random(0, 359))
    if OperationMarkers[ObjectName] == nil then
        OperationMarkers[ObjectName] = MARKER:New(TranslatedCoord, ObjectName)
        OperationMarkers[ObjectName]:ReadOnly()
        OperationMarkers[ObjectName]:SetText(MarkerText)
        OperationMarkers[ObjectName]:ToCoalition(Coalition)
        if Debug then BASE:E({FileVer,'AddMapMarker',ObjectName=ObjectName, MarkerText=MarkerText, Precision=Precision,Coalition=Coalition}) end
    else
        OperationMarkers[ObjectName]:UpdateCoordinate(TranslatedCoord)
        if Debug then BASE:E({FileVer,'RefreshMapMarker',ObjectName=ObjectName, MarkerText=MarkerText, Precision=Precision,Coalition=Coalition}) end
    end
end

-- Flag & Map marker scheduler
SCHEDULER:New(nil, function()
    for Coalition, TargetTable in pairs(Targets) do
        for Flag, TargetData in pairs(TargetTable) do
            local ObjectName = TargetData['ObjectName'] or nil
            local MarkerText = TargetData['Description'] or ''
            local Precision = TargetData['Precision'] or 0
            local InvertMarker = TargetData['InvertMarker'] or false
            if trigger.misc.getUserFlag(Flag) == 0 then
                local ObjectFound, Coord = FindObjectByName(ObjectName)
                if Markers == true and InvertMarker == false or Markers == false and InvertMarker == true then
                    if ObjectFound == true and Coord ~= nil then
                        AddRefreshMapMarker(ObjectName, MarkerText, Precision, Coalition, Coord)
                    else
                        RemoveMapMarker(ObjectName)
                    end
                end
                if ObjectFound == false and Coord == nil then
                    if Debug then BASE:E({FileVer,SetFlag=Flag,Value='true'}) end
                    trigger.action.setUserFlag(Flag, 1)
                end
            else
                RemoveMapMarker(ObjectName)
            end
        end
    end
end, {}, 60, 60)

--- Sort target table
--- @param Coalition number
local function SortTargetTable(Coalition)
    local SortedTable = {}
    if Debug then BASE:E({FileVer,'SortTargetTable',Coalition=Coalition}) end
    for Flag, TargetData in pairs(Targets[Coalition]) do
        if trigger.misc.getUserFlag(Flag) == 0 then
            local Area = TargetData['Area'] or 'OPERATION'
            local Category = TargetData['Category'] or 'GENERAL OBJECTIVES'
            if SortedTable[Area] == nil then
                SortedTable[Area] = {}
            end
            if SortedTable[Area][Category] == nil then
                SortedTable[Area][Category] = {}
            end
            table.insert(SortedTable[Area][Category], TargetData)
        end
    end
    return SortedTable
end

--- Show status message for client group
--- @param Client table
--- @param AreaName string
local function ShowStatus(Client, AreaName)
    local Header = AreaName or 'OPERATION'
    if Debug then BASE:E({FileVer,'ShowStatus',Client=Client:GetName(),Header=Header}) end
    local ClientCoalition = Client:GetCoalition()
    local MessageText = '******************************\n'..Header..' STATUS:\n******************************'
    local SortedTable = SortTargetTable(ClientCoalition)
    if SortedTable[Header] ~= nil then
        for Category, CategoryTable in pairs(SortedTable[Header]) do
            if #CategoryTable > 0 then
                MessageText = MessageText..'\n\n'..Category
                for _, TargetData in pairs(CategoryTable) do
                    MessageText = MessageText..'\n - '..TargetData['Description']
                end
            end
        end
    else
        MessageText = MessageText..'\n\nALL OBJECTIVES COMPLETED'
    end
    MessageText = MessageText..'\n '
    MESSAGE:New(MessageText, 60, nil, true):ToGroup(Client:GetGroup())
end

--- Add menus for client group
--- @param Client table
local function AddGroupMenus(Client)
    if Client.OperationMenu == nil then
        local Coalition = Client:GetCoalition()
        local AllInArea = true
        Client.OperationMenu = MENU_GROUP:New(Client:GetGroup(), 'Operation')
        for _, TargetData in pairs(Targets[Coalition]) do
            if TargetData['Area'] ~= nil then
                Client.AOMenu = MENU_GROUP:New(Client:GetGroup(), TargetData['Area'], Client.OperationMenu)
                MENU_GROUP_COMMAND:New(Client:GetGroup(), 'Show Status', Client.AOMenu, ShowStatus, Client, TargetData['Area'])
            else
                AllInArea = false
            end
        end
        if not AllInArea then
            MENU_GROUP_COMMAND:New(Client:GetGroup(), 'Show Status', Client.OperationMenu, ShowStatus, Client)
        end
        if Debug then BASE:E({FileVer,'AddGroupMenu',Client=Client:GetName()}) end
    end
end

-- Client joins slot event
if F10Menu == true then
    -- Eventhandler
    if STNE == nil then STNE = {} end
    if STNE.EventHandler == nil then STNE.EventHandler = {} end
    if STNE.EventHandler.OperationFlagsMarkers == nil then STNE.EventHandler.OperationFlagsMarkers = {} end
    STNE.EventHandler.OperationFlagsMarkers = EVENTHANDLER:New()
    STNE.EventHandler.OperationFlagsMarkers:HandleEvent(world.event.S_EVENT_BIRTH)
    -- OnEventBirth event
    function STNE.EventHandler.OperationFlagsMarkers:OnEventBirth(EventData)
        if Debug then BASE:E({FileVer,'OnEventBirth'}) end
        if EventData.IniUnit ~= nil and EventData.IniUnit:IsPlayer() then
            AddGroupMenus(EventData.IniUnit)
        end
    end
end

-- EOF
env.info('FILE: '..FileVer..' END')
