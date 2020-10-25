local Cfg = {
--#################################################################################################
--
--  SaveStatics
--
--  Persistent save for statics.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    Folder = 'C:\\Folder',                          -- Save folder, drive:\\folder\\folder
    Timer = 0,                                      -- Save scheduler, in seconds. 0 = save only when mission end
    Prefix = {                                      -- STATIC prefixes, save only these statics
        'StaticPrefixOne',
        'StaticPrefixTwo',
    },
    ResetSave = 667,                                -- Flag to reset save data
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveStatics.lua'
local Version = '201025'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SaveStatics then
    for key, value in pairs(STNE_Config_SaveStatics) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder
local SaveTimer = Cfg.Timer
local PrefixStatic = Cfg.Prefix
local ResetSave = Cfg.ResetSave

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Save == nil then STNE.Save = {} end
if STNE.Flags == nil then STNE.Flags = {} end
STNE.Flags.ResetSaveStatics = ResetSave

-- Prepare local save variables
local SaveFile = 'SaveData.STNE.Save.Statics.lua'

-- Check if io enabled
if not io then
    MESSAGE:New('INFO: STATICS SAVE/LOAD OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.', 600):ToAll()
end

-- Load saved data if io enabled
if io then
    local Load_Data = loadfile(SaveFolder..'\\'..SaveFile)
    if Load_Data then
        -- Load saved data
        Load_Data()
        if Debug then BASE:E({FileVer,'STNE.Save.Statics savedata loaded'}) end
    end
end

-- Remove destroyed statics and spawn new ones if static save data exists
if STNE.Save.Statics ~= nil then
    if Debug then BASE:E({FileVer,'STNE.Save.Statics savedata found'}) end
    for StaticName, StaticData in pairs(STNE.Save.Statics) do
        local StaticObj = STATIC:FindByName(StaticName, false)
        if StaticObj ~= nil and StaticData.Alive == false then
            if Debug then BASE:E({FileVer,'Destroy',Static=StaticName}) end
            StaticObj:Destroy()
        elseif StaticObj == nil and StaticData.Alive == true then
            if Debug then BASE:E({FileVer,'Spawn',Static=StaticName}) end
            local TemplateName = StaticData.TemplateName
            local Coord = COORDINATE:New(StaticData.x, StaticData.y, StaticData.z)
            local Heading = StaticData.Heading
            SPAWNSTATIC:NewFromStatic(TemplateName):SpawnFromCoordinate(Coord, Heading, StaticName)
        elseif StaticObj ~= nil and StaticData.Alive == true then
            local SaveCoord = COORDINATE:New(StaticData.x, StaticData.y, StaticData.z)
            local StaticObjCoord = StaticObj:GetCoordinate()
            local Distance = SaveCoord:Get2DDistance(StaticObjCoord)
            if Distance >= 3 then
                if Debug then BASE:E({FileVer,'Move',Static=StaticName,Distance=math.floor(Distance)}) end
                local Heading = StaticData.Heading
                StaticObj:ReSpawnAt(SaveCoord, Heading, 0)
            end
        end
    end
else
    if Debug then BASE:E({FileVer,'STNE.Save.Statics savedata not found'}) end
end

--- Convert table to string for save, copy from stne.Utils.lua
--- @param Tbl table
local function TableToSave(Tbl)
    if Debug then BASE:E({FileVer,'TableToSave'}) end
    local ReT = '{'
    --- Sub function for convert table to string for save
    --- @param Tbl table
    --- @param Indx number
    local function SubTableToSave(Tbl, Indx)
        --local Func = WithFunc or false
        local Tabs = Indx or 1
        local Tab = ''
        local SubReT = ''
        for i = 1, Tabs, 1 do
            if i <= Tabs then
                Tab = Tab..'    '
            end
        end
        for key, value in pairs(Tbl) do
            -- Keys
            if type(key) == 'number' then
                key = '\n'..Tab..'['..tostring(key)..'] = '
            elseif type(key) == 'string' then
                key = "\n"..Tab.."['"..tostring(key).."'] = "
            end
            -- Values
            if type(value) == 'string' then
                value = "'"..tostring(value).."',"
            elseif type(value) == 'number' then
                value = tostring(value)..','
            elseif type(value) == 'boolean' then
                value = tostring(value)..','
            elseif type(value) == 'function' then
                    --value = 'f(),'
            elseif type(value) == 'table' then
                value = '{'..tostring(SubTableToSave(value, Tabs + 1))..'\n'..Tab..'},'
            else
                value = nil
            end
            if value ~= nil then
                SubReT = SubReT..key..tostring(value)
            end
        end
        return tostring(SubReT)
    end
    local SubReT = SubTableToSave(Tbl)
    ReT = ReT..SubReT..'\n}'
    return tostring(ReT)
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

--- Prepare statics data for save
STNE.Save.Statics = {}
local function PrepareStatics()
    if Debug then BASE:E({FileVer,'PrepareStatics'}) end
    STNE.Save.Statics = {}
    -- Get statics for save
    local Set_Static = SET_STATIC:New()
    Set_Static:FilterPrefixes(PrefixStatic)
    Set_Static:FilterOnce()
    Set_Static:ForEachStatic(
        function(StaticObj)
            local StaticName = StaticObj:GetName()
            if StaticObj ~= nil then
                if StaticObj:IsAlive() then
                    local StaticCoord = StaticObj:GetCoordinate()
                    local StaticHdg = StaticObj:GetHeading()
                    local TemplateName = GetStaticName(StaticName)
                    STNE.Save.Statics[StaticName] = {TemplateName=TemplateName, Alive=true, Heading=StaticHdg, z=StaticCoord.z, x=StaticCoord.x, y=StaticCoord.y}
                else
                    STNE.Save.Statics[StaticName] = {Alive=false}
                end
            end
        end
    )
end

--- Save data to file
local function SaveDataToFile()
    if Debug then BASE:E({FileVer,'SaveDataToFile'}) end
    -- Save data if io enabled
    if io then
        local SaveData = ''
        local ResetFlag = trigger.misc.getUserFlag(STNE.Flags.ResetSaveStatics)
        if ResetFlag == 0 then
            -- Prepare statics data for save
            PrepareStatics()
            -- Save data
            SaveData = "STNE.Save.Statics = "
            SaveData = SaveData..TableToSave(STNE.Save.Statics)
        else
            SaveData = '-- Reset save data, flag: '..STNE.Flags.ResetSaveStatics..' value: '..ResetFlag
            if Debug then BASE:E({FileVer,'STNE.Save.Statics reset savedata'}) end
        end
        local Save_File = assert(io.open(SaveFolder..'\\'..SaveFile, "w"))
        if Save_File then
            Save_File:write(SaveData)
            Save_File:close()
            if Debug then BASE:E({FileVer,'STNE.Save.Statics savedata save success'}) end
        else
            if Debug then BASE:E({FileVer,'STNE.Save.Statics savedata save failed'}) end
        end
    end
end

-- End mission eventhandler for save data
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.Save == nil then STNE.EventHandler.Save = {} end
STNE.EventHandler.Save.Statics = EVENTHANDLER:New()
STNE.EventHandler.Save.Statics:HandleEvent(world.event.S_EVENT_MISSION_END)
-- On mission end event
function STNE.EventHandler.Save.Statics:OnEventMissionEnd(EventData)
    SaveDataToFile()
end

-- Scheduler
if SaveTimer > 0 then
    if Debug then BASE:E({FileVer,Scheduler='enabled'}) end
    SCHEDULER:New(nil, function()
        SaveDataToFile()
    end, {}, SaveTimer, SaveTimer)
else
    if Debug then BASE:E({FileVer,Scheduler='disabled'}) end
end

-- EOF
env.info('FILE: '..FileVer..' END')