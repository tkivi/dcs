local Cfg = {
--#################################################################################################
--
--  SaveFlags
--
--  Persistent save for flag values.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    Folder = 'C:\\Folder',                          -- Save folder, drive:\\folder\\folder
    Timer = 0,                                      -- Save scheduler, in seconds. 0 = save only when mission end
    Flags = {                                       -- Flags to save
        Min = 400,                                  -- Min flag to save, default 1
        Max = 7000,                                 -- Max flag to save, default 100000
        Ignore = {                                  -- Flags to ignore when saving data, default none (ResetSave always ignored)
            500,
            600,
            700,
        },
    },
    ResetSave = 667,                                -- Reset save data flag
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveFlags.lua'
local Version = '200828'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SaveFlags then
    for key, value in pairs(STNE_Config_SaveFlags) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder
local SaveTimer = Cfg.Timer
local FlagsMin = Cfg.Flags.Min or 1
local FlagsMax = Cfg.Flags.Max or 100000
local FlagsIgnore = Cfg.Flags.Ignore or {}
local ResetSave = Cfg.ResetSave

-- Prepare global variables
if STNE == nil then
    STNE = {}
end
if STNE.Save == nil then
    STNE.Save = {}
end
if STNE.Flags == nil then
    STNE.Flags = {}
end
--STNE.Save.Flags = {}
STNE.Flags.ResetSaveFlags = ResetSave

-- Prepare local save variables
local SaveFile = 'SaveData.STNE.Save.Flags.lua'

-- Check if io enabled
if not io then
    MESSAGE:New('INFO: FLAGS SAVE/LOAD OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.', 600):ToAll()
end

-- Load saved data if io enabled
if io then
    local Load_Data = loadfile(SaveFolder..'\\'..SaveFile)
    if Load_Data then
        -- Load saved data
        Load_Data()
        if Debug then BASE:E({FileVer,'STNE.Save.Flags savedata loaded'}) end
    end
end

-- Set flag values from savedata
if STNE.Save.Flags ~= nil then
    if Debug then BASE:E({FileVer,'STNE.Save.Flags savedata found, set flags'}) end
    for Flag, Value in pairs(STNE.Save.Flags) do
        trigger.action.setUserFlag(Flag, Value)
        if Debug then BASE:E({FileVer,Flag=Flag,Value=Value}) end
    end
else
    if Debug then BASE:E({FileVer,'STNE.Save.Flags savedata not found'}) end
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

-- Prepare ignore table
local FlagsIgnoreTable = {}
FlagsIgnoreTable[ResetSave] = true
if Debug then BASE:E({FileVer,IgnoreFlag=ResetSave}) end
for _, Flag in pairs(FlagsIgnore) do
    FlagsIgnoreTable[Flag] = true
    if Debug then BASE:E({FileVer,IgnoreFlag=Flag}) end
end

--- Prepare flags data for save
if STNE.Save.Flags == nil then STNE.Save.Flags = {} end
local function PrepareFlags()
    if Debug then BASE:E({FileVer,'PrepareFlags',FlagsMin=FlagsMin,FlagsMax=FlagsMax}) end
    for i = FlagsMin, FlagsMax, 1 do
        local FlagValue = trigger.misc.getUserFlag(i)
        if FlagValue ~= 0 and FlagsIgnoreTable[i] == nil then
            STNE.Save.Flags[i] = FlagValue
            if Debug then BASE:E({FileVer,'PrepareFlags',Flag=i,Value=FlagValue}) end
        else
            STNE.Save.Flags[i] = nil
        end
    end
end

--- Save data to file
local function SaveDataToFile()
    if Debug then BASE:E({FileVer,'SaveDataToFile'}) end
    -- Save data if io enabled
    if io then
        local SaveData = ''
        local ResetFlag = trigger.misc.getUserFlag(STNE.Flags.ResetSaveFlags)
        if ResetFlag == 0 then
            -- Prepare flag data for save
            PrepareFlags()
            -- Save data
            SaveData = 'STNE.Save.Flags = '
            SaveData = SaveData..TableToSave(STNE.Save.Flags)
        else
            SaveData = '-- Reset save data, flag: '..STNE.Flags.ResetSaveFlags..' value: '..ResetFlag
            if Debug then BASE:E({FileVer,'STNE.Save.Flags reset savedata'}) end
        end
        local Save_File = assert(io.open(SaveFolder..'\\'..SaveFile, "w"))
        if Save_File then
            Save_File:write(SaveData)
            Save_File:close()
            if Debug then BASE:E({FileVer,'STNE.Save.Flags savedata save success'}) end
        else
            if Debug then BASE:E({FileVer,'STNE.Save.Flags savedata save failed'}) end
        end
    end
end

-- End mission eventhandler for save data
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.Save == nil then STNE.EventHandler.Save = {} end
STNE.EventHandler.Save.Flags = EVENTHANDLER:New()
STNE.EventHandler.Save.Flags:HandleEvent(world.event.S_EVENT_MISSION_END)
-- On mission end event
function STNE.EventHandler.Save.Flags:OnEventMissionEnd(EventData)
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