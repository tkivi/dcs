local Cfg = {
--#################################################################################################
--
--  SimpleArtillery
--
--  Simple artillery for ME placed static artillery groups or ships with dedicated ammo groups.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                               -- Debug mode, true/false
    PrefixArtillery = 'Mortar',                  -- Artillery GROUP prefixes
    PrefixAmmo = 'Ammo',                         -- Ammo GROUP prefixes
    TargetCoalition = 'blue',                    -- Target coalition, 'red', 'blue', 'neutral'
    MinFiringRange = 0.5,                        -- Min firing range, in km
    MaxFiringRange = 7,                          -- Max firing range, in km
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SimpleArtillery.lua'
local Version = '200723'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SimpleArtillery then
    for key, value in pairs(STNE_Config_SimpleArtillery) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local PrefixArtillery = Cfg.PrefixArtillery
local PrefixAmmo = Cfg.PrefixAmmo
local TargetCoalition = Cfg.TargetCoalition
local MinFiringRange = Cfg.MinFiringRange
local MaxFiringRange = Cfg.MaxFiringRange

-- Target set group
local Target_Set_Grp = SET_GROUP:New()
Target_Set_Grp:FilterActive()
Target_Set_Grp:FilterCategoryGround()
Target_Set_Grp:FilterCoalitions(TargetCoalition)
Target_Set_Grp:FilterStart()

-- Artillery set group
local Arty_Set_Grp = SET_GROUP:New()
Arty_Set_Grp:FilterActive()
--Arty_Set_Grp:FilterCategoryGround()
Arty_Set_Grp:FilterPrefixes(PrefixArtillery)
Arty_Set_Grp:FilterOnce()

-- Ammo set group
local Ammo_Set_Grp = SET_GROUP:New()
Ammo_Set_Grp:FilterActive()
Ammo_Set_Grp:FilterCategoryGround()
Ammo_Set_Grp:FilterPrefixes(PrefixAmmo)
Ammo_Set_Grp:FilterOnce()

-- Set artillery
Arty_Set_Grp:ForEachGroupAlive(
    function(CurArtyGrp)
        local CurArtyObj = ARTY:New(CurArtyGrp)
        CurArtyObj:SetMarkTargetsOff()
        CurArtyObj:SetMaxFiringRange(MaxFiringRange)
        CurArtyObj:SetMinFiringRange(MinFiringRange)
        --CurArtyObj:SetMissileTypes({'weapons.missiles'})
        -- Assign ammo group for artillery
        local CurAmmoGrp = Ammo_Set_Grp:FindNearestGroupFromPointVec2(CurArtyGrp:GetPointVec2())
        CurArtyObj:SetRearmingGroup(CurAmmoGrp)
        -- Debug
        if Debug then
            CurArtyObj:SetReportON()
        else
            CurArtyObj:SetReportOFF()
        end
        -- On enter combat event
        function CurArtyObj:OnEnterCombatReady(Controllable, From, Event, To)
            CurArtyObj:RemoveAllTargets()
            local CurTargetGrp = Target_Set_Grp:FindNearestGroupFromPointVec2(CurArtyGrp:GetPointVec2())
            if CurTargetGrp ~= nil and CurTargetGrp:IsAlive() then
                CurArtyObj:AssignTargetCoord(CurTargetGrp:GetCoordinate(), nil, nil, 5)
            end
        end
        CurArtyObj:Start()
    end
)

-- EOF
env.info('FILE: '..FileVer..' END')
