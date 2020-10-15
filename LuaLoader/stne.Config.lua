local FileVer = 'stne.Config.lua/201015'
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

        --'GitHub/Mission/stne.EndMission.lua',

        --'GitHub/Operation/stne.CarrierRecovery.lua',
        --'GitHub/Operation/stne.CSAR.lua',
        'GitHub/Operation/stne.SceneryDestruction.lua',
        --'GitHub/Operation/stne.SimpleArtillery.lua',

        --'GitHub/Save/stne.SaveFlags.lua',
        --'GitHub/Save/stne.SaveGroups.lua',

        --'GitHub/Training/stne.MissileTrainer.lua',
        --'GitHub/Training/stne.TargetRange.lua',

        'GitHub/Utils/stne.Utils.lua',
        'GitHub/Utils/stne.Ziili.lua',

        --'SyriaTrap/stne.SyriaTrap.lua',
        --'SyriaTrap/stne.SyriaTrapFSM.lua',

        --'Test/TestCode.lua',

        --'Unfinished/stne.Warehouse.lua',
        --'Unfinished/stne.WarehouseLog.lua',
        --'Unfinished/stne.WarehouseCmd.lua',
        --'Unfinished/stne.WarehouseFSM.lua',
        --'Unfinished/stne.WarehouseAir.lua',
        --'Unfinished/stne.WarehouseGrpSave.lua', -- Check _AID in alias name error ? WAREHOUSE:_OnEventBirth
        --'Unfinished/stne.GroupCache.lua',
        --'Unfinished/stne.SlingloadLogistic.lua',

    },
}
--#################################################################################################
STNE_Config_MooseSettings = {                           -- stne.MooseSettings.lua
    DisablePlayerMenu = true,                           -- Disable Moose F10 settings menu, true/false
}
--#################################################################################################
STNE_Config_EndMission = {                              -- stne.EndMission.lua
    EndFlag = 666,                                      -- End mission flag
    MissionTime = 180,                                  -- Time to rise end mission flag, in seconds
    Warnings = {120, 90, 60, 30, 10},                   -- Warning timers before end mission, in seconds
}
--#################################################################################################
STNE_Config_CarrierRecovery = {                         -- stne.CarrierRecovery.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_CSAR = {                                    -- stne.CSAR.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SceneryDestruction = {                      -- stne.SceneryDestruction.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SimpleArtillery = {                         -- stne.SimpleArtillery.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SaveFlags = {                               -- stne.SaveFlags.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
    Timer = 0,                                          -- Save scheduler, in seconds. 0 = save only when mission end
    Flags = {
        Ignore = {                                      -- Flags to ignore when saving data, default none
            666,
        },
    },
    ResetSave = 667,                                    -- Reset save data flag
}
--#################################################################################################
STNE_Config_SaveGroups = {                              -- stne.SaveGroups.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
    Timer = 0,                                          -- Save scheduler, in seconds. 0 = save only when mission end
    Prefix = 'SaveGroup_',                              -- GROUP prefix, save only these groups
}
--#################################################################################################
STNE_Config_MissileTrainer = {                          -- stne.MissileTrainer.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_TargetRange = {                             -- stne.TargetRange.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Utils = {                                   -- stne.Utils.lua
    Debug = false,                                      -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_Ziili = {                                   -- stne.Ziili.lua
    Command = '-ziili',                                 -- Ziili command
    Separator = '\n',                                   -- Ziili command separator character, \n = enter
}
--#################################################################################################
STNE_Config_SyriaTrap = {                               -- stne.SyriaTrap.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SyriaTrapFSM = {                            -- stne.SyriaTrapFSM.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_Warehouse = {                               -- stne.Warehouse.lua
    Debug = true,                                       -- Debug mode, true/false
    EnableSave = false,                                 -- Enable save, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_WarehouseLog = {                            -- stne.WarehouseLog.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseCmd = {                            -- stne.WarehouseCmd.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseFSM = {                            -- stne.WarehouseFSM.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseAir = {                            -- stne.WarehouseAir.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_WarehouseGrpSave = {                        -- stne.WarehouseGrpSave.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:\\Varasto\\Scripts\\Lua\\SaveData',     -- Save folder
}
--#################################################################################################
STNE_Config_GroupCache = {                              -- stne.GroupCache.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
STNE_Config_SlingloadLogistic = {                       -- stne.SlingloadLogistic.lua
    Debug = true,                                       -- Debug mode, true/false
}
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
env.info('FILE: '..FileVer..' END')
