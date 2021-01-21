local Cfg = {
--#################################################################################################
--
--  SaveTables
--
--  Persistent save for lua tables under STNE.Save.Tables.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    Folder = 'C:\\Folder',                          -- Save folder, drive:\\folder\\folder
    Timer = 0,                                      -- Save scheduler, in seconds. 0 = save only when mission end
    ResetSave = 667,                                -- Flag to reset save data
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveTables.lua'
local Version = '210107'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SaveTables then
    for key, value in pairs(STNE_Config_SaveTables) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder
local SaveTimer = Cfg.Timer
local ResetSave = Cfg.ResetSave

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Save == nil then STNE.Save = {} end
if STNE.Save.Tables == nil then STNE.Save.Tables = {} end
if STNE.Flags == nil then STNE.Flags = {} end
STNE.Flags.ResetSaveTables = ResetSave

-- Prepare local save variables
local SaveFile = 'SaveData.STNE.Save.Tables.lua'

-- Check if io enabled
if not io then
    MESSAGE:New('INFO: TABLES SAVE/LOAD OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.', 600):ToAll()
end

-- Load saved data if io enabled
if io then
    local Load_Data = loadfile(SaveFolder..'\\'..SaveFile)
    if Load_Data then
        -- Load saved data
        Load_Data()
        if Debug then BASE:E({FileVer,'STNE.Save.Tables savedata loaded'}) end
    end
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

--- Save data to file
local function SaveDataToFile(ResetFlag)
    if Debug then BASE:E({FileVer,'SaveDataToFile'}) end
    -- Save data if io enabled
    if io then
        local SaveData = ''
        --local ResetFlag = trigger.misc.getUserFlag(STNE.Flags.ResetSaveTables)
        if ResetFlag == 0 then
            -- Save data
            SaveData = "STNE.Save.Tables = "
            SaveData = SaveData..TableToSave(STNE.Save.Tables)
        else
            SaveData = '-- Reset save data, flag: '..STNE.Flags.ResetSaveTables..' value: '..ResetFlag
            if Debug then BASE:E({FileVer,'STNE.Save.Tables reset savedata'}) end
        end
        local Save_File = assert(io.open(SaveFolder..'\\'..SaveFile, "w"))
        if Save_File then
            Save_File:write(SaveData)
            Save_File:close()
            if Debug then BASE:E({FileVer,'STNE.Save.Tables savedata save success'}) end
        else
            if Debug then BASE:E({FileVer,'STNE.Save.Tables savedata save failed'}) end
        end
    end
end

-- End mission eventhandler for save data
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.Save == nil then STNE.EventHandler.Save = {} end
STNE.EventHandler.Save.Tables = EVENTHANDLER:New()
STNE.EventHandler.Save.Tables:HandleEvent(world.event.S_EVENT_MISSION_END)
-- On mission end event
function STNE.EventHandler.Save.Tables:OnEventMissionEnd(EventData)
    local ResetFlag = trigger.misc.getUserFlag(STNE.Flags.ResetSaveTables)
    SaveDataToFile(ResetFlag)
end

-- Scheduler
if SaveTimer > 0 then
    if Debug then BASE:E({FileVer,Scheduler='enabled'}) end
    SCHEDULER:New(nil, function()
        SaveDataToFile(0)
    end, {}, SaveTimer, SaveTimer)
else
    if Debug then BASE:E({FileVer,Scheduler='disabled'}) end
end

-- EOF
env.info('FILE: '..FileVer..' END')
