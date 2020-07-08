env.info('FILE: stne.Config.lua/200708 START')
--#################################################################################################
--
--  Config
--
--  Override local configuration settings.
--
--  Usage: (check drive:/folder, load before other lua files)
--      MISSION EDITOR -> TRIGGERS -> MISSION START -> DO SCRIPT ->
--          assert(loadfile('C:/Folder/stne.Config.lua'))()
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
STNE_Config_LuaLoader = {                               -- stne.LuaLoader.lua
    Folder = 'F:/Varasto/Scripts/Lua/',                 -- Folder
    Scripts = {                                         -- Lua scripts, check proper loading order
        'Moose_dev.lua',
        'Moose/stne.MooseSettings.lua',
        'Carrier/stne.CarrierRecovery.lua',
        'Training/stne.MissileTrainer.lua',
        'Training/stne.TargetRange.lua',
        'Combat/stne.CSAR.lua',
        'Admin/stne.EndMission.lua',
        'Admin/stne.Ziili.lua',
        'Save/stne.SaveFlags.lua',
        'Save/stne.SaveGroups.lua',
        'Save/stne.SaveZones.lua',
        'Test/TestCode.lua',                            -- TEST CODE
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
    Debug = false,                                      -- Debug mode, true/false
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
    Folder = 'F:/Varasto/Scripts/Lua/Save/SaveData/',   -- Save folder
}
--#################################################################################################
STNE_Config_SaveGroups = {                              -- stne.SaveGroups.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:/Varasto/Scripts/Lua/Save/SaveData/',   -- Save folder
    Prefix = {'pSv_','Z_'},                             -- GROUP prefix to save
    Timer = 60,                                         -- Save data scheduler timer, in seconds
}
STNE_Config_SaveZones = {                               -- stne.SaveZones.lua
    Debug = true,                                       -- Debug mode, true/false
    Folder = 'F:/Varasto/Scripts/Lua/Save/SaveData/',   -- Save folder
    Prefix = 'Zone_',                                   -- ZONE prefix to save
    Timer = 60,                                         -- Save data scheduler timer, in seconds
}
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
env.info('FILE: stne.Config.lua/200708 END')
