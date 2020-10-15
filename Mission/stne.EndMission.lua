local Cfg = {
--#################################################################################################
--
--  EndMission
--
--  End mission timer.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    EndFlag = 666,                                      -- End mission flag
    MissionTime = 18000,                                -- Time to rise end mission flag, in seconds
    Warnings = {1800, 900, 600, 300, 60, 30, 10},       -- Warning timers before end mission, in seconds
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.EndMission.lua'
local Version = '200828'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_EndMission then
    for key, value in pairs(STNE_Config_EndMission) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local EndFlag = Cfg.EndFlag
local MissionTime = Cfg.MissionTime
local WarningTimes = Cfg.Warnings

-- Prepare global variables
if STNE == nil then
    STNE = {}
end
if STNE.Flags == nil then
    STNE.Flags = {}
end
STNE.Flags.EndMission = EndFlag

-- Warning timer scheduler
for i = 1, #WarningTimes, 1 do
    local Timer = WarningTimes[i]
    if Timer > MissionTime then
        local ErrorMsg = 'ERROR: '..FileVer..' Warning timer value too high'
        MESSAGE:New(ErrorMsg, 300):ToAll()
        env.info(ErrorMsg)
    else
        SCHEDULER:New(nil, function()
            local Message = "END MISSION: Time left "
            if Timer > 60 then
                Timer = Timer / 60
                Message = Message..tostring(Timer).." minute(s)"
            else
                Message = Message..tostring(Timer).." second(s)"
            end
            MESSAGE:New(Message, 10):ToAll()
        end, {Timer}, MissionTime - Timer)
    end
end

-- End Mission timer scheduler
SCHEDULER:New(nil, function()
    MESSAGE:New("END MISSION: End mission", 10):ToAll()
    trigger.action.setUserFlag(STNE.Flags.EndMission, 1)
end, {}, MissionTime)

-- EOF
env.info('FILE: '..FileVer..' END')
