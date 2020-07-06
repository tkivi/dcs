env.info('FILE: stne.Config.lua/1.0.0 START')
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
STNE_Config_LuaLoader = {                       -- stne.LuaLoader.lua
    Folder = 'F:/Varasto/Scripts/Lua/',         -- Folder
    Scripts = {                                 -- Lua scripts, check proper loading order
        'Moose_dev.lua',
        'stne.MooseSettings.lua',
        'Carrier/stne.CarrierRecovery.lua',
        'Training/stne.MissileTrainer.lua',
        'Training/stne.TargetRange.lua',
        'Combat/stne.CSAR.lua',
    },
}
--#################################################################################################
STNE_Config_MooseSettings = {                   -- stne.MooseSettings.lua
    DisablePlayerMenu = true,                   -- Disable Moose F10 settings menu, true/false
}
--#################################################################################################
STNE_Config_MissileTrainer = {                  -- stne.MissileTrainer.lua
}
--#################################################################################################
STNE_Config_CarrierRecovery = {                 -- stne.CarrierRecovery.lua
}
--#################################################################################################
STNE_Config_TargetRange = {                     -- stne.TargetRange.lua
}
--#################################################################################################
STNE_Config_CSAR = {                            -- stne.CSAR.lua
}
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
env.info('FILE: stne.Config.lua/1.0.0 END')
