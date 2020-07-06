local Cfg = {
--#################################################################################################
--
--  Ziili
--
--  Admin/debug tools via F10 map markers. (Zeus)
--
--  Currently supported commands: ADD, DEL, FLAG, CODE
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
local FileNme = 'stne.Ziili.lua'
local Version = '1.0.0'
local FileMsg = FileNme..'/'..Version
env.info('FILE: '..FileMsg..' START')

-- Override configuration
if STNE_Config_Ziili then
    for key, value in pairs(STNE_Config_Ziili) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileMsg,Cfg=Cfg})
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
    BASE:E({FileMsg,'Spawn',Object=Object,Coordinates=Coordinates,Text_Table=Text_Table})
    local CurSpawn = SPAWN:NewWithAlias(Object, string.format("%d",timer.getAbsTime()))
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
                BASE:E({FileMsg,'Air'})
            else
                BASE:E({FileMsg,'Ground'})
            end
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
    BASE:E({FileMsg,Object=Object})
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
            BASE:E({FileMsg,'SET Flag: '..Object..' Value: '..trigger.misc.getUserFlag(Object)})
        else
            BASE:E({FileMsg,'Flag not set'})
        end
    else
        BASE:E({FileMsg,'READ Flag: '..Object..' Value: '..trigger.misc.getUserFlag(Object)})
    end
end

--- Handle Ziili command
--- @param Text string
--- @param Coordinates table
local function ProcessCommand(Text, Coordinates)
    BASE:E({FileMsg,Text=Text,Coordinates=Coordinates})
    local Text_Table = UTILS.Split(Text, Sep)
    if Text_Table[1] == Cmd then
        local Action = Text_Table[2]
        local Object = Text_Table[3]
        BASE:E({FileMsg,'Ziili command',Action=Action,Object=Object})
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
            BASE:E({FileMsg,'RUN LUA CODE START'})
            UTILS.DoString(Object)
            BASE:E({FileMsg,'RUN LUA CODE END'})
        end
        --[[ ACTION: Task
        if Action == "task" then
            local TaskGroup = GROUP:FindByName(Object)
            if TaskGroup ~= nil then
                if TaskGroup.stneSave ~= nil then
                    if TaskGroup.stneSave.Task ~= nil then
                        local CurrentTask = TaskGroup.stneSave.Task
                        if Text_Table[4] ~= nil then
                            local NewTask = Text_Table[4]
                            TaskGroup.stneSave.Task = NewTask
                            BASE:E({FileMsg,CurrentTask=CurrentTask,NewTask=NewTask})
                        end
                    end
                end
            end
        end ]]
        --[[ ACTION: Supply
        if Action == "supply" then
            local SupplyZone = ZONE:FindByName(Object)
            if SupplyZone ~= nil then
                if SupplyZone.stneZones ~= nil then
                    if SupplyZone.stneZones.Supply ~= nil then
                        local CurrentSupply = SupplyZone.stneZones.Supply
                        if Text_Table[4] ~= nil then
                            local NewSupply = Text_Table[4]
                            SupplyZone.stneZones.Supply = tonumber(NewSupply)
                            BASE:E({FileMsg,CurrentSupply=CurrentSupply,NewSupply=NewSupply})
                        end
                    end
                end
            end
        end ]]
    end
end

--- Remove F10 map marker event
--- @param EventData table
function STNE_Ziili_EventHandler:OnEventMarkRemoved(EventData)
    if EventData.text ~= nil and EventData.text:find(Cmd) then
        BASE:E({FileMsg,EventData=EventData})
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
env.info('FILE: '..FileMsg..' END')