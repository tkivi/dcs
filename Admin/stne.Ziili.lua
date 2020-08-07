local Cfg = {
--#################################################################################################
--
--  Ziili
--
--  Admin/debug tools via F10 map markers. (Zeus)
--
--  Currently supported commands: ADD, DEL, FLAG, CODE, STNE, ONELINE,
--                                EXPORTGROUP, EXPORTTABLE, EXPORTSTNE,
--                                REQUEST, ADDASSET, CHANGEMIN
--
--  Examples:
--
--      -ziili          -ziili          -ziili          -ziili
--      add             del             del             del
--      GroupName       last            all             GroupName
--
--      -ziili          -ziili          -ziili          -ziili
--      add             flag            flag            code
--      GroupName       666             666             env.info('Run Code')
--      300             1
--      15000
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Command = '-ziili',                         -- Ziili command
    Separator = '\n',                           -- Ziili command separator character, \n = enter
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.Ziili.lua'
local Version = '200805'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_Ziili then
    for key, value in pairs(STNE_Config_Ziili) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Cmd = Cfg.Command
local Sep = Cfg.Separator

-- Table to save all Ziili spawned groups
local All_Spawned_Groups = {}

-- Create new eventhandler
STNE_Ziili_EventHandler = EVENTHANDLER:New()
STNE_Ziili_EventHandler:HandleEvent(world.event.S_EVENT_MARK_REMOVED)

--- Spawn group
--- @param Object string
--- @param Coordinates table
--- @param Text_Table table
local function Spawn_Group(Object, Coordinates, Text_Table)
    BASE:E({FileVer,'Spawn',Object=Object,Coordinates=Coordinates,Text_Table=Text_Table})
    local Alias = 'Z_'..string.format("%d",timer.getAbsTime())
    local CurSpawn = SPAWN:NewWithAlias(Object, Alias)
    -- Height parameter
    if Text_Table[5] ~= nil then
        Coordinates.y = UTILS.FeetToMeters(tonumber(Text_Table[5]))
    end
    CurSpawn:OnSpawnGroup(
        function(Spawned_Group)
            table.insert(All_Spawned_Groups, Spawned_Group)
            if Text_Table[4] ~= nil and Spawned_Group:InAir() then
                Spawned_Group:RouteAirTo(Coordinates:Translate(UTILS.NMToMeters(50), Spawned_Group:GetHeading()), true)
            end
            if Spawned_Group:InAir() then
                BASE:E({FileVer,'Air'})
            else
                BASE:E({FileVer,'Ground'})
            end
            -- Minimal support for save
            if Spawned_Group.stne == nil then Spawned_Group.stne = {} end
            if Spawned_Group.stne.Save == nil then Spawned_Group.stne.Save = {} end
            Spawned_Group.stne.Save.Group = Object
            Spawned_Group.stne.Save.Alias = Alias
            Spawned_Group.stne.Units = Spawned_Group:GetUnits()
        end
    )
    -- Heading parameter
    if Text_Table[4] ~= nil then
        CurSpawn:InitHeading(tonumber(Text_Table[4]))
    end
    -- Actual spawn
    if Text_Table[5] ~= nil then
        local Spawn_Height = UTILS.FeetToMeters(tonumber(Text_Table[5]))
        CurSpawn:SpawnFromVec2(Coordinates:GetVec2(), Spawn_Height, Spawn_Height)
    else
        CurSpawn:SpawnFromVec2(Coordinates:GetVec2())
    end
end

--- Remove group(s)
--- @param Object string
local function Remove_Group(Object)
    BASE:E({FileVer,Object=Object})
    local Group_To_Destroy = ""
    if Object == "all" then
        for i = 1, #All_Spawned_Groups, 1 do
            Group_To_Destroy = All_Spawned_Groups[i]
            Group_To_Destroy:Destroy(false)
        end
        All_Spawned_Groups = {}
    elseif Object == "last" then
        if #All_Spawned_Groups >= 1 then
            Group_To_Destroy = All_Spawned_Groups[#All_Spawned_Groups]
            Group_To_Destroy:Destroy(false)
            table.remove(All_Spawned_Groups)
        end
    else
        Group_To_Destroy = GROUP:FindByName(Object)
        if Group_To_Destroy ~= nil then
            Group_To_Destroy:Destroy(false)
            All_Spawned_Groups[Group_To_Destroy] = nil
            for i = 1, #All_Spawned_Groups, 1 do
                if All_Spawned_Groups[i] == nil then
                    table.remove(All_Spawned_Groups, i)
                end
            end
        end
    end
end

--- Get/Set flag
--- @param Object string
--- @param Text_Table table
local function GetSetFlag(Object, Text_Table)
    BASE:E({FileVer,Object=Object,Text_Table=Text_Table})
    if Text_Table[4] ~= nil then
        local Flag_Value = Text_Table[4]
        if Flag_Value == "true" then
            Flag_Value = 1
        end
        if Flag_Value == "false" then
            Flag_Value = 0
        end
        Flag_Value = tonumber(Flag_Value)
        if type(Flag_Value) == "number" then
            trigger.action.setUserFlag(Object, Flag_Value)
            BASE:E({FileVer,'SET Flag: '..Object..' Value: '..trigger.misc.getUserFlag(Object)})
        else
            BASE:E({FileVer,'Flag not set'})
        end
    else
        BASE:E({FileVer,'READ Flag: '..Object..' Value: '..trigger.misc.getUserFlag(Object)})
    end
end

--- Read group stne values
--- @param Object string
local function ReadSTNE(Object)
    BASE:E({FileVer,Object=Object})
    local Grp = GROUP:FindByName(Object)
    local Zon = ZONE:FindByName(Object)
    if Grp ~= nil and Grp.stne ~= nil then
        BASE:E({FileVer,'STNE VALUES FOR GROUP',Grp:GetName()})
        BASE:E({FileVer,Grp.stne})
        return true
    elseif Zon ~= nil and Zon.stne ~= nil then
        BASE:E({FileVer,'STNE VALUES FOR ZONE',Zon:GetName()})
        BASE:E({FileVer,'ZONE',Zon.stne})
        return true
    else
        BASE:E({FileVer,'STNE VALUES NOT FOUND',Object})
    end
    return false
end

--- Oneline serialize to dcs.log and message
--- @param Object string
local function stne_Oneline(Object)
    BASE:E({FileVer,'stne_Oneline'})
    local Text = UTILS.OneLineSerialize(Object)
    env.info(Text)
    MESSAGE:New(Text, 60):ToAll()    
end

--- Handle Ziili command
--- @param Text string
--- @param Coordinates table
local function ProcessCommand(Text, Coordinates)
    BASE:E({FileVer,Text=Text,Coordinates=Coordinates})
    local Text_Table = UTILS.Split(Text, Sep)
    if Text_Table[1] == Cmd then
        local Action = Text_Table[2]
        local Object = Text_Table[3]
        BASE:E({FileVer,'Ziili command',Action=Action,Object=Object})
        -- ACTION: Add group
        if Action == "add" then
            local Object_Group = GROUP:FindByName(Object)
            if Object_Group ~= nil then
                Spawn_Group(Object, Coordinates, Text_Table)
            end
        end
        -- ACTION: Remove group
        if Action == "del" then
            Remove_Group(Object)
        end
        -- ACTION: Flag
        if Action == "flag" then
            if type(Object) == "string" then
                GetSetFlag(Object, Text_Table)
            end
        end
        -- ACTION: Code
        if Action == "code" then
            BASE:E({FileVer,'RUN LUA CODE START'})
            UTILS.DoString(Object)
            BASE:E({FileVer,'RUN LUA CODE END'})
        end
        -- ACTION: Read object stne
        if Action == "stne" then
            ReadSTNE(Object)
        end
        -- ACTION: Oneline serialize
        if Action == "oneline" then
            stne_Oneline(Object)
        end
        -- ACTION: Export group to save file
        if Action == "exportgroup" then
            local ExportGrp = GROUP:FindByName(Object)
            if ExportGrp ~= nil then
                STNE.API.SaveTableToFile(ExportGrp, true)
            end
        end
        -- ACTION: Export table to save file
        if Action == "exporttable" then
            UTILS.DoString('STNE_Ziili_TempTable = '..Object)
            STNE.API.SaveTableToFile(STNE_Ziili_TempTable, true)
            STNE_Ziili_TempTable = nil
        end
        -- ACTION: Export global STNE to save file
        if Action == "exportstne" then
            STNE.API.SaveTableToFile(STNE, true)
        end
        -- ACTION: Request asset from warehouse
        if Action == "request" then
            if Text_Table[3] ~= nil and Text_Table[4] ~= nil then
                UTILS.DoString('STNE_Ziili_TempAttribute = WAREHOUSE.Attribute.'..Text_Table[3])
                if Text_Table[5] ~= nil then
                    STNE.API.RequestAssetFromWHToWH(Text_Table[4], Text_Table[5], STNE_Ziili_TempAttribute, 1)
                else
                    STNE.API.SelfRequestAssetFromWH(Text_Table[4], STNE_Ziili_TempAttribute, 1)
                end
                STNE_Ziili_TempAttribute = nil
            end
        end
        -- ACTION: Add asset to warehouse
        if Action == "addasset" then
            local Object_Group = GROUP:FindByName(Object)
            if Object_Group ~= nil and Text_Table[4] ~= nil and Text_Table[5] ~= nil then
                UTILS.DoString('STNE_Ziili_TempAddAssetCount = '..Text_Table[5])
                STNE.API.AddAssetToWH(Object, Text_Table[4], STNE_Ziili_TempAddAssetCount)
                STNE_Ziili_TempAddAssetCount = nil
            end
        end
        -- ACTION: Change warehouse min asset value
        if Action == "changemin" then
            if Text_Table[3] ~= nil and Text_Table[4] ~= nil and Text_Table[5] then
                UTILS.DoString('STNE_Ziili_TempAttribute = WAREHOUSE.Attribute.'..Text_Table[3])
                UTILS.DoString('STNE_Ziili_TempAttributeValue = '..Text_Table[5])
                STNE.API.ChangeWHMinAsset(Text_Table[4], STNE_Ziili_TempAttribute, STNE_Ziili_TempAttributeValue)
                STNE_Ziili_TempAttribute = nil
                STNE_Ziili_TempAttributeValue = nil
            end
        end
    end
end

--- Remove F10 map marker event
--- @param EventData table
function STNE_Ziili_EventHandler:OnEventMarkRemoved(EventData)
    if EventData.text ~= nil and EventData.text:find(Cmd) then
        BASE:E({FileVer,EventData=EventData})
        local Text = EventData.text
        local Vec3 = {
            y = EventData.pos.y,
            --x = Event.pos.z,
            x = EventData.pos.x,
            --z = Event.pos.x,
            z = EventData.pos.z
        }
        local Coordinates = COORDINATE:NewFromVec3(Vec3)
        Coordinates.y = Coordinates:GetLandHeight()
        ProcessCommand(Text, Coordinates)
    end
end

-- EOF
env.info('FILE: '..FileVer..' END')
