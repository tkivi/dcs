local Cfg = {
--#################################################################################################
--
--  MissileTrainer
--
--  Practice to evade missiles without being destroyed. Handles air-to-air and surface-to-air missiles.
--  F10 radio menu to adjust settings for each player.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.FOX.html
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                              -- Debug mode, true/false
    SetDefaultLaunchAlerts = false,             -- Default launch alert, true/false
    SetDefaultLaunchMarks = false,              -- Default map markers, true/false
    SetDefaultMissileDestruction = false,       -- Default missile destruction, true/false
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local FileNme = 'stne.MissileTrainer.lua'
local Version = '1.0.0'
local FileMsg = FileNme..'/'..Version
env.info('FILE: '..FileMsg..' START')

-- Override configuration
if STNE_Config_MissileTrainer then
    for key, value in pairs(STNE_Config_MissileTrainer) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileMsg,Cfg=Cfg})
local Debug = Cfg.Debug
local Alert = Cfg.SetDefaultLaunchAlerts
local Marks = Cfg.SetDefaultLaunchMarks
local Destr = Cfg.SetDefaultMissileDestruction

-- Moose FOX
local MissileTrainer = FOX:New()
MissileTrainer:SetDebugOnOff(Debug)
MissileTrainer:SetDefaultLaunchAlerts(Alert)
MissileTrainer:SetDefaultLaunchMarks(Marks)
MissileTrainer:SetDefaultMissileDestruction(Destr)
MissileTrainer:Start()

-- EOF
env.info('FILE: '..FileMsg..' END')
