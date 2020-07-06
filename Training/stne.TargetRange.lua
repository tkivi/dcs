local Cfg = {
--#################################################################################################
--
--  TargetRange
--
--  Strafe pit and bomb target practice. Optional JTAC laser designate on bomb target.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Range.html
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                              -- Debug mode, true/false
    Name = 'Goldwater Range',                   -- Target range name
    StrafePit = {                               -- Strafe pit
        'Strafe_Target',                        -- Target, STATIC or UNIT
        3000,                                   -- Length, meters
        300,                                    -- Width, meters
        90,                                     -- Approach radial, degrees
        20,                                     -- Number of hits for a "good" strafing pass
        275,                                    -- Foul line distance (0 = disable), meters
    },
    BombTarget = {                              -- Bomb target
        'Bomb_Target',                          -- Target, STATIC or UNIT
        25,                                     -- Good hit distance, meters
    },
    JTAC_Enable = true,                         -- JTAC enable, true/false
    JTAC_Unit = 'JTAC_Unit',                    -- JTAC UNIT
    JTAC_LaserCode = 1688,                      -- JTAC laser code
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local FileNme = 'stne.TargetRange.lua'
local Version = '1.0.0'
local FileMsg = FileNme..'/'..Version
env.info('FILE: '..FileMsg..' START')

-- Override configuration
if STNE_Config_TargetRange then
    for key, value in pairs(STNE_Config_TargetRange) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileMsg,Cfg=Cfg})
local Debug = Cfg.Debug
local RangeName = Cfg.Name
local StrafePit = Cfg.StrafePit
local BombTarget = Cfg.BombTarget
local JTAC_Enable = Cfg.JTAC_Enable
local JTAC_Unit = Cfg.JTAC_Unit
local JTAC_Code = Cfg.JTAC_LaserCode

-- Create target range
local TargetRange = RANGE:New(RangeName)
TargetRange:AddStrafePit(StrafePit[1], StrafePit[2], StrafePit[3], StrafePit[4], false, StrafePit[5], StrafePit[6])
TargetRange:AddBombingTargets(BombTarget[1], BombTarget[2])
TargetRange:SetDefaultPlayerSmokeBomb(false)
if Debug then TargetRange:DebugON() end
TargetRange:Start()

-- JTAC laser designation
if JTAC_Enable then
    local Spotter = SPOT:New(UNIT:FindByName(JTAC_Unit))
    local Target = UNIT:FindByName(BombTarget[1])
    if Target == nil then
        Target = STATIC:FindByName(BombTarget[1])
    end
    Spotter:LaseOn(Target, JTAC_Code) --, Duration
end

-- EOF
env.info('FILE: '..FileMsg..' END')
