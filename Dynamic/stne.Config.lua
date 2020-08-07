local FileVer = 'stne.Config.lua/200806'
env.info('FILE: '..FileVer..' START')
--#################################################################################################
--
--  Config
--
--  Override local configuration settings.
--
--  Usage: (check drive:/folder, load before other lua files)
--
--      MISSION EDITOR -> TRIGGERS -> MISSION START -> DO SCRIPT ->
--
--          assert(loadfile('C:/Folder/stne.Config.lua'))()
--
--  or copy global variables of your choice with your custom settings: (load before lua file)
--
--      MISSION EDITOR -> TRIGGERS -> MISSION START -> DO SCRIPT ->
--
--          STNE_Config_EndMission = {
--              End_Flag = 666,
--              Mission_Time = 3600,
--              Warnings = {900, 600, 300, 60, 30},
--          }
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
STNE_Config_LuaLoader = {                               -- stne.LuaLoader.lua
    Folder = 'F:/Varasto/Scripts/Lua/',                 -- Folder
    Scripts = {                                         -- Lua scripts, check proper loading order
        'Moose_dev.lua',

        --'GitHub/Moose/stne.MooseSettings.lua',
        --'GitHub/Carrier/stne.CarrierRecovery.lua',
        --'GitHub/Training/stne.MissileTrainer.lua',
        --'GitHub/Training/stne.TargetRange.lua',
        --'GitHub/Combat/stne.CSAR.lua',
        --'GitHub/Combat/stne.SimpleArtillery.lua',
        --'GitHub/Admin/stne.EndMission.lua',
        'GitHub/Admin/stne.Ziili.lua',
        --'GitHub/Save/stne.SaveFlags.lua',
        --'GitHub/Save/stne.SaveGroups.lua',
        --'GitHub/Save/stne.SaveZones.lua',

        'Unfinished/stne.Utils.lua',
        --'Unfinished/stne.Zones.lua',
        --'Unfinished/stne.Artillery.lua',
        'Unfinished/stne.Warehouse.lua',
        'Unfinished/stne.WarehouseLog.lua',
        --'Unfinished/stne.WarehouseCmd.lua',
        --'Unfinished/stne.WarehouseFSM.lua',
        --'Unfinished/stne.WarehouseAir.lua',
        --'Unfinished/stne.WarehouseGrpSave.lua', -- Check _AID in alias name error ? WAREHOUSE:_OnEventBirth

        --'Test/TestCode.lua',
    },
}
--#################################################################################################
STNE_Config_MooseSettings = {                           -- stne.MooseSettings.lua
    DisablePlayerMenu = true,                           -- Disable Moose F10 settings menu, true/false
}
--#################################################################################################
STNE_Config_MissileTrainer = {                          -- stne.MissileTrainer.lua
}
--#################################################################################################
STNE_Config_CarrierRecovery = {                         -- stne.CarrierRecovery.lua
}
--#################################################################################################
STNE_Config_TargetRange = {                             -- stne.TargetRange.lua
}
--#################################################################################################
STNE_Config_CSAR = {                                    -- stne.CSAR.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Ziili = {                                   -- stne.Ziili.lua
}
--#################################################################################################
STNE_Config_EndMission = {                              -- stne.EndMission.lua
--    End_Flag = 666,                                     -- End mission flag
--    Mission_Time = 180,                                 -- Time to rise end mission flag, in seconds
--    Warnings = {120, 60, 30, 10},                       -- Warning timers before end mission, in seconds
}
--#################################################################################################
STNE_Config_SaveFlags = {                               -- stne.SaveFlags.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:/Varasto/Scripts/Lua/SaveData/',        -- Save folder
}
--#################################################################################################
STNE_Config_SaveGroups = {                              -- stne.SaveGroups.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:/Varasto/Scripts/Lua/SaveData/',        -- Save folder
    Prefix = '_AID',                                    -- GROUP prefix to save pSv_
    Timer = 60,                                         -- Save data scheduler timer, in seconds
}
--#################################################################################################
STNE_Config_SaveZones = {                               -- stne.SaveZones.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:/Varasto/Scripts/Lua/SaveData/',        -- Save folder
    Timer = 60,                                         -- Save data scheduler timer, in seconds
}
--#################################################################################################
STNE_Config_Zones = {                                   -- stne.Zones.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SimpleArtillery = {                         -- stne.SimpleArtillery.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Artillery = {                               -- stne.Artillery.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Warehouse = {                               -- stne.Warehouse.lua
    Debug = true,                                       -- Debug mode, true/false
    EnableSave = true,                                 -- Enable save, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_WarehouseLog = {
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseGrpSave = {
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_WarehouseAir = {
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Utils = {
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_WarehouseFSM = {
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseCmd = {
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
env.info('FILE: '..FileVer..' END')
