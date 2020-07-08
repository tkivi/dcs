local Cfg = {
--#################################################################################################
--
--  SaveZones
--
--  Persistent save for zones in mission.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                               -- Debug mode, true/false
    Folder = 'C:/Folder/',                       -- Save folder
    Prefix = {'Zone_'},                          -- ZONE prefixes to save
    Timer = 60,                                  -- Save data scheduler timer, in seconds
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveZones.lua'
local Version = '200708'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SaveZones then
    for key, value in pairs(STNE_Config_SaveZones) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder
local SavePrefix = Cfg.Prefix
local SaveTimer = Cfg.Timer

-- Define save file
local SaveFile = 'SaveData.Zones.lua'

-- Define save data table
STNE_Save_All_Zones = {}

-- Save template
local SaveTemplate = {
    Zone = '',
    Coalition = 0,
    Supply = 0,
    Fortification = 'NONE',
    Defence = 'NONE',
    Logistic = {},
    Attack = {},
    Patrol = {},
}

--- Convert table to string for save
--- @param Tbl table
local function stne_TableToSave(Tbl)
    if Debug then BASE:E({FileVer,'stne_TableToSave'}) end
    local ReT = '{'
    --- Sub function for convert table to string for save
    --- @param Tbl table
    --- @param SingleLine boolean
    local function stne_SubTableToSave(Tbl,SingleLine)
        local SubReT = ''
        for key, value in pairs(Tbl) do
            if type(key) == 'number' then
                if SingleLine then
                    key = ''
                else
                    key = '\n        '
                end
            else
                if SingleLine then
                    key = tostring(' '..key..' = ')
                else
                    key = tostring('\n        '..key..' = ')
                end
            end
            if type(value) == 'string' then value=tostring("'"..value.."'") end
            if type(value) == 'table' then
                value = '{'..tostring(stne_SubTableToSave(value,true))..'}'
            end
            SubReT = SubReT..key..tostring(value)..','
        end
        return tostring(SubReT)
    end
    local SubReT = stne_SubTableToSave(Tbl)
    ReT = ReT..SubReT..'\n    }'
    return tostring(ReT)
end

-- Zone set
local Zone_Set_Zone = SET_ZONE:New()
Zone_Set_Zone:FilterPrefixes(SavePrefix)
Zone_Set_Zone:FilterOnce()

-- Load saved data if exists
local Load_Data = loadfile(SaveFolder .. SaveFile)
if Load_Data then
    Load_Data()
    if Debug then BASE:E({FileVer,'Load data, zones: '..tostring(#STNE_Save_All_Zones)}) end
else
    if Debug then BASE:E({FileVer,'Data not found'}) end
end

-- Set data from save
for key, value in pairs(STNE_Save_All_Zones) do
    local CurZoneName = STNE_Save_All_Zones[key].Zone
    local CurZone = ZONE:FindByName(CurZoneName)
    if CurZone.stne == nil then
        CurZone.stne = {}
    end
    CurZone.stne.Save = value
end

-- Enable save scheduler if IO available
if not io then
    MESSAGE:New("INFO: SAVE OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.\nLoading previously saved data is still allowed.", 60):ToAll()
else
    -- Save data scheduler
    SCHEDULER:New(nil, function()
        if Debug then BASE:E({FileVer,'Save START'}) end
        local Save_Data = "STNE_Save_All_Zones = {"
        Zone_Set_Zone:ForEachZone(
            function(CurZone)
                local CurZoneName = CurZone:GetName()
                -- Check nil
                if CurZone.stne == nil then
                    CurZone.stne = {}
                end
                if CurZone.stne.Save == nil then
                    CurZone.stne.Save = SaveTemplate
                    CurZone.stne.Save.Zone = CurZoneName
                end
                -- Get data
                Save_Data = Save_Data .. "\n    " .. stne_TableToSave(CurZone.stne.Save) .. ","
            end
        )
        Save_Data = Save_Data .. "\n}"
        -- Save data to file
        local Save_File = assert(io.open(SaveFolder .. SaveFile, "w"))
        if Save_File then
            Save_File:write(Save_Data)
            Save_File:close()
        end
        if Debug then BASE:E({FileVer,'Save END count: '..tostring(Zone_Set_Zone:Count())}) end
    end, {}, SaveTimer, SaveTimer)
end

-- EOF
env.info('FILE: '..FileVer..' END')