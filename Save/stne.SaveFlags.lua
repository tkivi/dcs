local Cfg = {
--#################################################################################################
--
--  SaveFlags
--
--  Persistent save for trigger flags in mission.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                              -- Debug mode, true/false
    Folder = 'C:/Folder/',                      -- Save folder
    Flags = {'100','200','300','400','500'},    -- Flags to save
    Timer = 60,                                 -- Save data scheduler timer, in seconds
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveFlags.lua'
local Version = '200708'
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
local SaveFlags = Cfg.Flags
local SaveTimer = Cfg.Timer

-- Define save file
local SaveFile = 'SaveData.Flags.lua'

-- Define save data table
STNE_Save_All_Flags = {}

-- Load saved data if exists
local Load_Data = loadfile(SaveFolder .. SaveFile)
if Load_Data then
    Load_Data()
    if Debug then BASE:E({FileVer,'Flags loaded: '..tostring(#STNE_Save_All_Flags)}) end
else
    if Debug then BASE:E({FileVer,'No flags loaded'}) end
end

-- Set loaded flags
for i = 1, #STNE_Save_All_Flags, 1 do
    local CurFlag = STNE_Save_All_Flags[i].Flag
    local CurValue = STNE_Save_All_Flags[i].Value
    trigger.action.setUserFlag(CurFlag, CurValue)
end

-- Enable save scheduler if IO available
if not io then
    MESSAGE:New("INFO: SAVE OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.\nLoading previously saved data is still allowed.", 60):ToAll()
else
    -- Save data scheduler
    SCHEDULER:New(nil, function()
        if Debug then BASE:E({FileVer,'Save START'}) end
        -- Start save data
        local Current_Index = 0
        local Save_Data = "STNE_Save_All_Flags = {"
        for i = 1, #SaveFlags, 1 do
            local CurFlag = SaveFlags[i]
            local CurValue = trigger.misc.getUserFlag(CurFlag)
            -- Create data for save
            Current_Index = Current_Index + 1
            Save_Data = Save_Data .. "\n    {"
            Save_Data = Save_Data .. "\n        Flag = '" .. tostring(CurFlag) .. "',"
            Save_Data = Save_Data .. "\n        Value = " .. tostring(CurValue) .. ","
            Save_Data = Save_Data .. "\n    },"
        end
        Save_Data = Save_Data .. "\n}"
        -- Save data to file
        local Save_File = assert(io.open(SaveFolder .. SaveFile, "w"))
        if Save_File then
            Save_File:write(Save_Data)
            Save_File:close()
        end
        if Debug then BASE:E({FileVer,'Save END count: '..tostring(#SaveFlags)}) end
    end, {}, SaveTimer, SaveTimer)
end

-- EOF
env.info('FILE: '..FileVer..' END')
