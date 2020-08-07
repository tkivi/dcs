local Cfg = {
--#################################################################################################
--
--  Utils
--
--  Utils functions etc...
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                          -- Debug mode, true/false
    Folder = 'C:\\Folder',                                  -- Save folder, drive:\\folder\\folder
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.Utils.lua'
local Version = '200807'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_Utils then
    for key, value in pairs(STNE_Config_Utils) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder

-- Prepare globals
if STNE == nil then
    STNE = {}
end
if STNE.API == nil then
    STNE.API = {}
end

-- Filename for save
local FileName = 'Export.SaveTableToFile.lua'

--- Convert table to string for save
--- @param Tbl table
--- @param WithFunc boolean
local function stne_TableToSave(Tbl, WithFunc)
    if Debug then BASE:E({FileVer,'stne_TableToSave'}) end
    local Func = WithFunc or false
    local ReT = ''
    if WithFunc then
        ReT = '-- Export table with functions\nlocal function f() end\nlocal ExportedTable = {'
    else
        ReT = '-- Export table without functions\nlocal ExportedTable = {'
    end
    --- Sub function for convert table to string for save
    --- @param Tbl table
    --- @param WithFunc boolean
    --- @param Indx number
    local function stne_SubTableToSave(Tbl, Func, Indx)
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
            elseif type(value) == 'function' and Func then
                    value = 'f(),'
            elseif type(value) == 'table' then
                value = '{'..tostring(stne_SubTableToSave(value, Func, Tabs + 1))..'\n'..Tab..'},'
            else
                value = nil
            end
            if value ~= nil then
                SubReT = SubReT..key..tostring(value)
            end
        end
        return tostring(SubReT)
    end
    local SubReT = stne_SubTableToSave(Tbl, Func)
    ReT = ReT..SubReT..'\n}'
    return tostring(ReT)
end

--- API: stne.Utils.lua: Save table to file
--- @param Tbl table
--- @param WithFunc boolean
function STNE.API.SaveTableToFile(Tbl, WithFunc)
    if Debug then BASE:E({FileVer,'STNE.API.SaveTableToFile'}) end
    if io then
        local SaveTable = stne_TableToSave(Tbl, WithFunc)
        local Save_File = assert(io.open(SaveFolder..'\\'..FileName, "w"))
        if Save_File then
            Save_File:write(SaveTable)
            Save_File:close()
            if Debug then BASE:E({FileVer,'Utils table save success'}) end
            return true
        else
            if Debug then BASE:E({FileVer,'Utils table save failed'}) end
            return false
        end
    else
        MESSAGE:New('INFO: CANNOT SAVE TABLE TO FILE\nYou need to enable IO command in MissionScripting.lua to enable save.', 60):ToAll()
        return false
    end
end

-- EOF
env.info('FILE: '..FileVer..' END')
