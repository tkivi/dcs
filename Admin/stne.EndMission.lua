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
    End_Flag = 666,                                 -- End mission flag
    Mission_Time = 18000,                           -- Time to rise end mission flag, in seconds
    Warnings = {1800, 900, 600, 300, 60, 30, 10},   -- Warning timers before end mission, in seconds
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.EndMission.lua'
local Version = '200708'
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
local EndFlag = Cfg.End_Flag
local MissionTime = Cfg.Mission_Time
local WarningTimes = Cfg.Warnings

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
    trigger.action.setUserFlag(EndFlag, 1)
end, {}, MissionTime)

-- EOF
env.info('FILE: '..FileVer..' END')