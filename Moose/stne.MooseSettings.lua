local Cfg = {
--#################################################################################################
--
--  MooseSettings
--
--  Moose specific settings.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    DisablePlayerMenu = true,                   -- Disable Moose F10 settings menu, true/false
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.MooseSettings.lua'
local Version = '200708'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_MooseSettings then
    for key, value in pairs(STNE_Config_MooseSettings) do
        Cfg[key] = value
    end
end

-- Read config table
local DisablePlayerMenu = Cfg.DisablePlayerMenu

-- Detect Moose
if _DATABASE ~= nil then
    BASE:E({FileVer,Cfg=Cfg})
    if DisablePlayerMenu then
        _SETTINGS:SetPlayerMenuOff()    -- Disable Moose settings menu
    end
else
    local ErrorMsg = 'ERROR: '..FileVer..' Moose not loaded'
    MESSAGE:New(ErrorMsg, 300):ToAll()
    env.info(ErrorMsg)
end

-- EOF
env.info('FILE: '..FileVer..' END')
