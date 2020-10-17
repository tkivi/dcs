local Cfg = {
--#################################################################################################
--
--  CSAR
--
--  Combat Search And Rescue.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                              -- Debug mode, true/false
    Assets = {                                  -- CSAR assets
        [1] = {                                 -- 1 = Red coalition
            Pilot = 'CSAR_PILOT_R',             -- Pilot template, GROUP
            Enemy = {                           -- Enemy infantry templates, GROUP
                'CSAR_INF_B_1',
                --'CSAR_INF_B_2',
                --'CSAR_INF_B_3',
            },
        },
        [2] = {                                 -- 2 = Blue coalition
            Pilot = 'CSAR_PILOT_B',             -- Pilot template, GROUP
            Enemy = {                           -- Enemy infantry templates, GROUP
                'CSAR_INF_R_1',
                --'CSAR_INF_R_2',
                --'CSAR_INF_R_3',
            },
        },
    },
    Clients_Only = true,                        -- Activate eject event only for human players
    Sound_Folder = 'Sounds/',                   -- Sounds folder, in .miz file
    Sound_Guard = 'Emergency_Beacon.ogg',       -- Guard beacon sound file, in sounds folder
    Sound_Nav = 'beaconsilent.ogg',             -- Navigation beacon sound file, in sounds folder
    Sound_Message = 'Digibeep.ogg',             -- Info message sound file, in sounds folder
    Beacon_Duration_Guard = 120,                -- Guard beacon duration after eject, in seconds
    Beacon_Duration_Nav = 1800,                 -- Navigation beacon duration after parachute land, in seconds
    Pilot_Prefix = 'Rescue_',                   -- GROUP prefix for CSAR pilot on ground (for late activated and spawned pilots)
    Rescue_Prefix = 'CSAR_',                    -- GROUP prefix for CSAR rescue aircraft
    Recover_Prefix = '_PRC',                    -- GROUP prefix for CSAR recover unit
    Pilot_Hypothermia = 1800,                   -- Pilot in water dies to hypothermia, in seconds
    Pilot_UnderAttack = 3600,                   -- Pilot under attack, in seconds
    Random_Enemy = 100,                         -- Random enemy probability, in percent
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.CSAR.lua'
local Version = '201017'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_CSAR then
    for key, value in pairs(STNE_Config_CSAR) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local Assets = Cfg.Assets
local Clients_Only = Cfg.Clients_Only
local Sound_Folder = Cfg.Sound_Folder
local BcnTimerGuard = Cfg.Beacon_Duration_Guard
local BcnTimerNav = Cfg.Beacon_Duration_Nav
local PrefixPilot = Cfg.Pilot_Prefix
local PrefixRescue = Cfg.Rescue_Prefix
local PrefixRecover = Cfg.Recover_Prefix
local Hypothermia = Cfg.Pilot_Hypothermia
local UnderAttack = Cfg.Pilot_UnderAttack
local RndEnemy = Cfg.Random_Enemy
local SoundGrd = Cfg.Sound_Guard
local SoundNav = Cfg.Sound_Nav
local SoundMsg = Cfg.Sound_Message

-- Messages
local CSAR_Msg_Unload_Pilot = {
    ["Header"] = "Rescued Pilot",
    ["Text"] = {
        "This is my stop.",
        "I'm out. Thanks!",
        "Thanks for the ride.",
        "I'm jumping out!",
        "Finally home.",
    },
}
local CSAR_Msg_Unload_Pilot_Good = {
    ["Header"] = "Rescued Pilot",
    ["Text"] = {
        "Nice flying buddy, I'm out.",
        "That was a short flight, Thanks!",
        "Thanks for the ride!",
        "Smooth ride. I'll by the drinks later.",
        "You guys have done this before! Much appreciated.",
    },
}
local CSAR_Msg_Unload_Pilot_Bad = {
    ["Header"] = "Rescued Pilot",
    ["Text"] = {
        "You could have landed a bit closer...",
        "Do I need to walk form here?",
        "Man, I got a busted leg and you are making me walk?",
        "This is fine. I could use a walk... I'm out!",
        "A nice walk will calm my nerves. I'm out!",
    },
}
local CSAR_Msg_Unload_Pilot_Failed = {
    ["Header"] = "Rescued Pilot",
    ["Text"] = {
        "Hold still. I'm trying to get out!",
        "Keep it still so I can get out!",
        "Whoa! I'm not out yet!",
        "I can't get out!",
        "Could you land? I already jumped once.",
    },
}
local CSAR_Msg_GetIn_Pilot = {
    ["Header"] = "Pilot entering aircraft",
    ["Text"] = {
        "Damn, am I glad to see you guys. Let's get out of here!",
        "I'm in. Let's go!",
        "I think I got a broken arm. You got any painkillers here?",
        "Nice landing! Think you could take me back to base?",
        "I'm in. let's RTB!",
        "What the hell happened? I thought I was dead for sure.",
        "Are you my Uber?",
        "I ordered a black Mercedes.",
        "Glad to see you guys. Let's get out of here!",
    },
}
local CSAR_Msg_Cargo_Full = {
    ["Header"] = "Pilot outside",
    ["Text"] = {
        "Looks like you are full. Take these guys back first.",
        "What the hell! I can't fit in there.",
        "Damn! Your aircraft is full. Any other CSAR flights nearby?",
        "I can't fit in. Take the others back first.",
        "There is no room! I could ride on top but I just got a haircut.",
    },
}

-- Rescue air types and available seats
local CSAR_Rescue_Air_Types = {
    ["UH-1H"] = 5,      -- 3 with weapons ?
    ["Mi-8MT"] = 10,
    ["SA342M"] = 1,
    ["SA342Mistral"] = 2,
    ["Yak-52"] = 1,
    ["TF-51D"] = 1,
    ["L-39C"] = 1,
    ["L-39ZA"] = 1,
    ["C-101EB"] = 1,
    ["C-101CC"] = 1,
    ["Christen Eagle II"] = 1,
}

-- Rescue air types, exit/enter vehicle angles
local CSAR_Rescue_Air_Type_Angles = {
    ["UH-1H"] = 70,
    ["Mi-8MT"] = 40,
    ["SA342M"] = 70,
    ["SA342Mistral"] = 70,
    ["Yak-52"] = 140,
    ["TF-51D"] = 140,
    ["L-39C"] = 40,
    ["L-39ZA"] = 40,
    ["C-101EB"] = 40,
    ["C-101CC"] = 40,
    ["Christen Eagle II"] = 140,
}

-- Variables
local CSAR_Pilot_Counter = 0
local CSAR_Enemy_Counter = 0
local CSAR_Return_Counter = 0
local CSAR_Pilot_LastSpawn = 0
local CSAR_Beacon_Counter = 0
local CSAR_CleanUp_Timer = 300
local CSAR_Recover_Pilot_Distance = 500
local CSAR_Move_Pilot_Distance = 250
local CSAR_FlareSmoke_Distance = 3000
local CSAR_Rescue_Rope_Length = 25
local CSAR_Beacon_Guard_Sound = Sound_Folder .. SoundGrd
local CSAR_Beacon_Nav_Sound = Sound_Folder .. SoundNav
local CSAR_Message_Sound = Sound_Folder .. SoundMsg
local CSAR_Schedule_Timer = 10

-- Eventhandler
STNE_CSAR_EventHandler = EVENTHANDLER:New()
STNE_CSAR_EventHandler:HandleEvent(world.event.S_EVENT_EJECTION)
STNE_CSAR_EventHandler:HandleEvent(world.event.S_EVENT_BIRTH)

-- Recover set group
local CSAR_Recover_Set_Group = SET_GROUP:New()
CSAR_Recover_Set_Group:FilterActive()
CSAR_Recover_Set_Group:FilterPrefixes(PrefixRecover)
CSAR_Recover_Set_Group:FilterStart()

-- Rescue set group
local CSAR_Rescue_Set_Group = SET_GROUP:New()
CSAR_Rescue_Set_Group:FilterActive()
CSAR_Rescue_Set_Group:FilterPrefixes(PrefixRescue)
CSAR_Rescue_Set_Group:FilterStart()

-- Pilot set group
local CSAR_Pilot_Set_Group = SET_GROUP:New()
CSAR_Pilot_Set_Group:FilterActive()
CSAR_Pilot_Set_Group:FilterPrefixes(PrefixPilot)
CSAR_Pilot_Set_Group:FilterStart()

-- Random message to group
local function Random_Message_To_Group(CurGroup, MessageTable, CargoPilots, Header)
    if CurGroup ~= nil and MessageTable ~= nil then
        local CurMsg = ""
        if CargoPilots then
            CurMsg = CurMsg .. tostring(CurGroup.stneCSAR.PilotCargo) .. "/" .. tostring(CurGroup.stneCSAR.PilotCargoMax) .. " Onboard.\n"
        end
        if Header then
            CurMsg = CurMsg .. tostring(MessageTable.Header) .. ": "
        end
        CurMsg = CurMsg .. MessageTable.Text[math.random(1, #MessageTable.Text)]
        MESSAGE:New(CurMsg, 10):ToGroup(CurGroup)
        -- Sound
        trigger.action.outSoundForGroup(CurGroup:GetID(), CSAR_Message_Sound)
    end
end

-- Calculate parachute position
local function CalculateLandingPos(Coord, HeightToDecrease)
    local InAir = true
    local StartHeight = Coord.y
    local EndHeight = StartHeight - HeightToDecrease

    local Direction, Strength = Coord:GetWind(StartHeight)

    if Direction >= 180 then
        Direction = Direction - 180
    else
        Direction = Direction + 180
    end

    local LandingTime = HeightToDecrease / 4.11556
    local Distance = LandingTime * Strength
    Coord.y = EndHeight
    local CoordNew = Coord:Translate(Distance, Direction)

    if EndHeight > UTILS.FeetToMeters(16000) then
        LandingTime = 0
        CoordNew = Coord
    end

    if EndHeight <= CoordNew:GetLandHeight() then
        InAir = false
    end

    return InAir, CoordNew, LandingTime
end

-- Calculate parachute landing position
local function LandingPosWithTime(Coord)
    local Height = Coord.y
    local InAir = true
    local LandingTime = 0
    local AltHigh = UTILS.FeetToMeters(26000)
    local AltMed = UTILS.FeetToMeters(6600)
    local AltLow = UTILS.FeetToMeters(1600)
    local AltLand = UTILS.FeetToMeters(33)

    local DecreaseHeight = 50
    while (InAir) do
        if Height > AltHigh then
            DecreaseHeight = 250
        elseif Height > AltMed then
            DecreaseHeight = 150
        elseif Height > AltLow then
            DecreaseHeight = 50
        elseif Height > AltLand then
            DecreaseHeight = 3
        else
            DecreaseHeight = 1
        end

        InAir, Coord, AddLandingTime = CalculateLandingPos(Coord, DecreaseHeight)
        Height = Coord.y
        LandingTime = LandingTime + AddLandingTime
    end

    if Debug then
        BASE:E(LandingTime)
        Coord:MarkToAll("Parachute landing spot")
    end

    return Coord, LandingTime
end

-- Stop beacon
local function StopBeacon(CurGroup, Beacons)
    if CurGroup ~= nil then
        local CurBeaconsGuard = CurGroup.stneCSAR.BeaconsGuard
        local CurBeaconsNav = CurGroup.stneCSAR.BeaconsNav
        if CurBeaconsGuard ~= nil then
            for i = 1, #CurBeaconsGuard, 1 do
                if Debug then MESSAGE:New("DEBUG: CSAR: Guard beacon OFF ID: " .. CurBeaconsGuard[i] .. " Group: " .. CurGroup:GetName(), 10):ToAll() end
                trigger.action.stopRadioTransmission(tostring(CurBeaconsGuard[i]))
            end
            CurGroup.stneCSAR.BeaconsGuard = {}
        end
        if CurBeaconsNav ~= nil then
            for i = 1, #CurBeaconsNav, 1 do
                if Debug then MESSAGE:New("DEBUG: CSAR: Nav beacon OFF ID: " .. CurBeaconsNav[i] .. " Group: " .. CurGroup:GetName(), 10):ToAll() end
                trigger.action.stopRadioTransmission(tostring(CurBeaconsNav[i]))
            end
            CurGroup.stneCSAR.BeaconsNav = {}
        end
    elseif Beacons then
        local CurBeacons = Beacons
        for i = 1, #CurBeacons, 1 do
            if Debug then MESSAGE:New("DEBUG: CSAR: Timed beacon OFF ID: " .. CurBeacons[i], 10):ToAll() end
            trigger.action.stopRadioTransmission(tostring(CurBeacons[i]))
        end
    end
end

-- Cleanup group instantly or after some time
local function CleanUpTimer(CurGroup, Instant, CustomTimer)
    if CurGroup ~= nil then
        if CurGroup.stneCSAR.Enemy ~= nil then
            local CurEnemyGroup = CurGroup.stneCSAR.Enemy
            CleanUpTimer(CurEnemyGroup)
        end
        if Instant then
            if Debug then MESSAGE:New("DEBUG: CSAR: Destroy: " .. CurGroup:GetName(), 10):ToAll() end
            StopBeacon(CurGroup)
            CurGroup:Destroy()
        else
            if CustomTimer then
                SCHEDULER:New(nil, function()
                    if Debug then MESSAGE:New("DEBUG: CSAR: Custom delayed destroy: " .. CurGroup:GetName(), 10):ToAll() end
                    CleanUpTimer(CurGroup, true)
                end, {}, CustomTimer)
            else
                SCHEDULER:New(nil, function()
                    if Debug then MESSAGE:New("DEBUG: CSAR: Delayed destroy: " .. CurGroup:GetName(), 10):ToAll() end
                    CleanUpTimer(CurGroup, true)
                end, {}, CSAR_CleanUp_Timer)
            end
        end
    end
end

-- Move enemy to pilot position
local function PilotUnderAttack(CurPilotGroup)
    SCHEDULER:New(nil, function()
        if CurPilotGroup ~= nil and CurPilotGroup:IsAlive() then
            local PilotCoord = CurPilotGroup:GetCoordinate()
            -- Move enemy
            if CurPilotGroup.stneCSAR.Enemy ~= nil and CurPilotGroup.stneCSAR.Enemy:IsAlive() then
                local CurEnemyGroup = CurPilotGroup.stneCSAR.Enemy
                CurEnemyGroup:RouteGroundTo(PilotCoord, CurEnemyGroup:GetSpeedMax(), "Diamond", 0)
                if Debug then MESSAGE:New("DEBUG: CSAR: Route enemy: " .. CurEnemyGroup:GetName(), 10):ToAll() end
            end
        end
    end, {}, UnderAttack)
end

-- Spawn beacon
local function SpawnBeacon(Coord, BeaconGuard, BeaconNav, Coalition) --(CurGroup, BeaconGuard, BeaconNav, CurUnit)
    local CSAR_Beacons_Guard = {}
    local CSAR_Beacons_Nav = {}

    local CurTime = timer.getAbsTime()
    if CurTime > CSAR_Pilot_LastSpawn then

        local PointVec3 = Coord --:PointVec3()
        local CSAR_Beacons_Guard1_Hz = 243000000
        local CSAR_Beacons_Guard2_Hz = 121500000
        local CSAR_Beacons_Nav_Hz = 700000

        if Coalition == 2 then
            CSAR_Beacons_Nav_Hz = 600000
        end

        if Coalition == 2 and BeaconGuard then
            -- Guard 243
            CSAR_Beacon_Counter = CSAR_Beacon_Counter + 1
            trigger.action.radioTransmission(CSAR_Beacon_Guard_Sound, PointVec3, radio.modulation.AM, true, CSAR_Beacons_Guard1_Hz, 1, tostring(CSAR_Beacon_Counter))
            table.insert(CSAR_Beacons_Guard, CSAR_Beacon_Counter)
            if Debug then MESSAGE:New("DEBUG: CSAR: GUARD Beacon ON ID: " .. CSAR_Beacon_Counter, 10):ToAll() end
            -- Guard 121,5
            CSAR_Beacon_Counter = CSAR_Beacon_Counter + 1
            trigger.action.radioTransmission(CSAR_Beacon_Guard_Sound, PointVec3, radio.modulation.AM, true, CSAR_Beacons_Guard2_Hz, 1, tostring(CSAR_Beacon_Counter))
            table.insert(CSAR_Beacons_Guard, CSAR_Beacon_Counter)
            if Debug then MESSAGE:New("DEBUG: CSAR: GUARD Beacon ON ID: " .. CSAR_Beacon_Counter, 10):ToAll() end
            -- Timeout scheduler
            SCHEDULER:New(nil, function()
                StopBeacon(nil, CSAR_Beacons_Guard)
            end, {}, BcnTimerGuard)
        end

        if BeaconNav then
            CSAR_Beacon_Counter = CSAR_Beacon_Counter + 1
            trigger.action.radioTransmission(CSAR_Beacon_Nav_Sound, PointVec3, radio.modulation.AM, true, CSAR_Beacons_Nav_Hz, 1, tostring(CSAR_Beacon_Counter))
            table.insert(CSAR_Beacons_Nav, CSAR_Beacon_Counter)
            if Debug then MESSAGE:New("DEBUG: CSAR: NAV Beacon ON ID: " .. CSAR_Beacon_Counter, 10):ToAll() end
            -- Timeout scheduler
            SCHEDULER:New(nil, function()
                StopBeacon(nil, CSAR_Beacons_Nav)
            end, {}, BcnTimerNav)
        end

        CSAR_Pilot_LastSpawn = CurTime + 1

    end

    return CSAR_Beacons_Guard, CSAR_Beacons_Nav
end

-- Check if coord is in water
local function CoordInWater(Coord)
    if Coord:IsSurfaceTypeShallowWater() or Coord:IsSurfaceTypeWater() then
        return true
    else
        return false
    end
end

-- Spawn enemy near pilot
local function SpawnEnemy(Coord, Coalition, PilotGroup)
    CSAR_Enemy_Counter = CSAR_Enemy_Counter + 1
    local Heading = math.random(0, 359)
    local Distance = math.random(1000, 1500)
    local CoordNew = Coord:Translate(Distance, Heading)
    local InWater = CoordInWater(CoordNew)
    if not InWater then
        local CurEnemies = Assets[Coalition].Enemy
        local CurEnemy = CurEnemies[math.random(1, #CurEnemies)]
        local CurAlias = "E" .. string.format("%d",timer.getAbsTime()) .. "_" .. CSAR_Enemy_Counter
        local CurSpawn = SPAWN:NewWithAlias(CurEnemy, CurAlias)
        CurSpawn:OnSpawnGroup(
            function(SpwnGroup)
                PilotGroup.stneCSAR.Enemy = SpwnGroup
                PilotUnderAttack(PilotGroup)
                if Debug then MESSAGE:New("DEBUG: CSAR: Spawn enemy: " .. SpwnGroup:GetName() .. " for: " .. PilotGroup:GetName(), 10):ToAll() end
            end
        )
        if Heading >= 0 and Heading < 180 then
            Heading = Heading + 180
        else
            Heading = Heading - 180
        end
        CurSpawn:InitHeading(Heading)
        CurSpawn:SpawnFromVec2(CoordNew:GetVec2())
    else
        if Debug then MESSAGE:New("DEBUG: CSAR: Enemy coord is in water, skip spawn", 10):ToAll() end
    end
end

-- Spawn pilot after eject
local function SpawnPilot(Coord, Coalition, EnemyNear, SpawnDelay, ActBeaconsGuard, ActBeaconsNav)
    SCHEDULER:New(nil, function()
        CSAR_Pilot_Counter = CSAR_Pilot_Counter + 1
        local PilotTemplate = Assets[Coalition].Pilot
        local CurAlias = PrefixPilot .. string.format("%d",timer.getAbsTime()) .. "_" .. CSAR_Pilot_Counter
        local CurSpawn = SPAWN:NewWithAlias(PilotTemplate, CurAlias)
        CurSpawn:OnSpawnGroup(
            function(SpwnGroup)
                local InWater = CoordInWater(Coord)
                if Debug then MESSAGE:New("DEBUG: CSAR: Spawn pilot: " .. SpwnGroup:GetName(), 10):ToAll() end
                local CurBeaconsGuard, CurBeaconsNav = SpawnBeacon(Coord, false, true, Coalition)
                if SpwnGroup.stneCSAR == nil then
                    SpwnGroup.stneCSAR = {}
                end

                SpwnGroup.stneCSAR.BeaconsGuard = CurBeaconsGuard
                SpwnGroup.stneCSAR.BeaconsNav = CurBeaconsNav
                SpwnGroup.stneCSAR.BeaconActivated = true

                if #ActBeaconsGuard >= 1 then
                    for i = 1, #ActBeaconsGuard, 1 do
                        table.insert(SpwnGroup.stneCSAR.BeaconsGuard, ActBeaconsGuard[i])
                    end
                end
                if #ActBeaconsNav >= 1 then
                    for i = 1, #ActBeaconsNav, 1 do
                        table.insert(SpwnGroup.stneCSAR.BeaconsNav, ActBeaconsNav[i])
                    end
                end
                if EnemyNear then
                    local RandomEnemy = math.random(1, 100)
                    if RandomEnemy <= RndEnemy then
                        SpawnEnemy(Coord, Coalition, SpwnGroup)
                    end
                end
                if InWater then
                    CleanUpTimer(SpwnGroup, false, Hypothermia)
                end
            end
        )
        CurSpawn:InitHeading(math.random(0, 359))
        CurSpawn:SpawnFromVec2(Coord:Translate(math.random(5,10), math.random(0, 359)):GetVec2())
        --CurSpawn:SpawnFromVec2(Coord:GetVec2())
    end, {}, SpawnDelay)
end

-- Closest recover group from rescue group
local function ClosestRecover(CurRescueGroup, RescueCoord)
    local ClosestGroup = nil
    local DistanceMin = nil
    local RescueCoalition = CurRescueGroup:GetCoalition()
    CSAR_Recover_Set_Group:ForEachGroupAlive(
        function(CurRecoverGroup)
            local RecoverCoalition = CurRecoverGroup:GetCoalition()
            if RecoverCoalition == RescueCoalition then
                local RecoverCoord = CurRecoverGroup:GetCoordinate()
                local Distance = math.floor(routines.utils.get2DDist(RescueCoord, RecoverCoord))
                if ClosestGroup == nil then
                    ClosestGroup = CurRecoverGroup
                    DistanceMin = Distance
                else
                    if Distance < DistanceMin then
                        ClosestGroup = CurRecoverGroup
                        DistanceMin = Distance
                    end
                end
            end
        end
    )
    return ClosestGroup, DistanceMin
end

-- Closest ground group from unit
local function ClosestGround(CurUnit)
    local ClosestGroup = nil
    local DistanceMin = nil
    local EnemyGroup = nil

    local CurUnitCoalition = CurUnit:GetCoalition()
    local CurUnitCoord = CurUnit:GetCoordinate()

    local CurSetGroupCoalition = CurUnitCoalition
    local CurSetGroupCoord = CurUnitCoord

    local ClosestGroup_Set_Group = SET_GROUP:New()
    ClosestGroup_Set_Group:FilterCategoryGround()
    ClosestGroup_Set_Group:FilterActive()
    ClosestGroup_Set_Group:FilterOnce()

    ClosestGroup_Set_Group:ForEachGroupAlive(
        function(CurSetGroup)

            CurSetGroupCoalition = CurSetGroup:GetCoalition()
            CurSetGroupCoord = CurSetGroup:GetCoordinate()

            local Distance = math.floor(routines.utils.get2DDist(CurUnitCoord, CurSetGroupCoord))
            if ClosestGroup == nil then
                ClosestGroup = CurSetGroup
                DistanceMin = Distance
                if CurUnitCoalition == CurSetGroupCoalition then
                    EnemyGroup = false
                else
                    EnemyGroup = true
                end
            else
                if Distance < DistanceMin then
                    ClosestGroup = CurSetGroup
                    DistanceMin = Distance
                    if CurUnitCoalition == CurSetGroupCoalition then
                        EnemyGroup = false
                    else
                        EnemyGroup = true
                    end
                end
            end
        end
    )
    return ClosestGroup, DistanceMin, EnemyGroup
end

-- Birth event
function STNE_CSAR_EventHandler:OnEventBirth(EventData)
    local CurUnit = EventData.IniUnit
    local CurGroup = EventData.IniGroup
    if CurUnit ~= nil and CurGroup ~= nil then
        local CurType = CurUnit:GetTypeName()
        CurGroup.stneCSAR = {}
        CurGroup.stneCSAR.PilotCargo = 0
        if CSAR_Rescue_Air_Types[CurType] ~= nil then
            CurGroup.stneCSAR.PilotCargoMax = CSAR_Rescue_Air_Types[CurType]
        else
            CurGroup.stneCSAR.PilotCargoMax = 0
        end
        if Debug then MESSAGE:New("DEBUG: CSAR: EVENT: Birth type: " .. CurType, 10):ToAll() end
    end
end

-- Eject event
function STNE_CSAR_EventHandler:OnEventEjection(EventData)
    if Debug then MESSAGE:New("DEBUG: CSAR: EVENT: Eject", 10):ToAll() end
    local CurUnit = EventData.IniUnit
    local CurGroup = EventData.IniGroup
    if CurUnit ~= nil and CurGroup ~= nil then
        if CurGroup.stneCSAR == nil then
            CurGroup.stneCSAR = {}
        end
        CurGroup.stneCSAR.Ejected = true
        local IsPlayer = CurUnit:IsPlayer()
        if Clients_Only and IsPlayer or not Clients_Only then
            local Coord = CurUnit:GetCoordinate()
            local InAir = CurUnit:InAir() --CurGroup:InAir()
            local SpawnDelay = 1

            if InAir then
                Coord, SpawnDelay = LandingPosWithTime(Coord)
            end

            local InWater = CoordInWater(Coord)
            local FriendlyCoalition = EventData.IniCoalition
            local EnemyCoalition = 0
            if FriendlyCoalition == 1 then
                EnemyCoalition = 2
            end
            if FriendlyCoalition == 2 then
                EnemyCoalition = 1
            end

            local CurBeaconsGuard, CurBeaconsNav = SpawnBeacon(Coord, true, false, FriendlyCoalition)

            local FriendlyAirbase, FriendlyDistance = Coord:GetClosestAirbase2(nil, FriendlyCoalition)
            local EnemyAirbase, EnemyDistance = Coord:GetClosestAirbase2(nil, EnemyCoalition)
            local GroundGroup, GroundDistance, GroundEnemy = ClosestGround(CurUnit)

            local RecoverGroup, RecoverDistance = ClosestRecover(CurGroup, Coord)

            if RecoverGroup == nil or RecoverDistance > CSAR_Recover_Pilot_Distance or RecoverGroup:IsShip() then
                Coord.y = Coord:GetLandHeight()
                -- Check if close to friend or enemy and spawn pilot
                if FriendlyDistance > EnemyDistance and not InWater or GroundEnemy and not InWater then
                    SpawnPilot(Coord, FriendlyCoalition, true, SpawnDelay, CurBeaconsGuard, CurBeaconsNav)
                    if CurGroup.stneCSAR.PilotCargo ~= nil and InAir == false then
                        for i = 1, CurGroup.stneCSAR.PilotCargo, 1 do
                            SpawnPilot(Coord, FriendlyCoalition, true, SpawnDelay, CurBeaconsGuard, CurBeaconsNav)
                        end
                        CurGroup.stneCSAR.PilotCargo = 0
                    end
                else
                    SpawnPilot(Coord, FriendlyCoalition, false, SpawnDelay, CurBeaconsGuard, CurBeaconsNav)
                    if CurGroup.stneCSAR.PilotCargo ~= nil and InAir == false then
                        for i = 1, CurGroup.stneCSAR.PilotCargo, 1 do
                            SpawnPilot(Coord, FriendlyCoalition, false, SpawnDelay, CurBeaconsGuard, CurBeaconsNav)
                        end
                        CurGroup.stneCSAR.PilotCargo = 0
                    end
                end
            else
                if Debug then MESSAGE:New("DEBUG: CSAR: Eject too close from own recover group", 10):ToAll() end
            end
        end
    end
end

-- Get spawn coord for pilot and heading
local function GetSpawnCoordHdg(RescueGroup, RecoverGroup)
    local RescueCoord = RescueGroup:GetCoordinate()
    if RecoverGroup ~= nil then
        local ExitAngle = 90
        local ExitDistance = 3
        local RescueUnit = RescueGroup:GetUnit(1)
        if RescueUnit ~= nil and RescueUnit:IsAlive() then
            local RescueType = RescueUnit:GetTypeName()
            if CSAR_Rescue_Air_Type_Angles[RescueType] ~= nil then
                ExitAngle = CSAR_Rescue_Air_Type_Angles[RescueType]
            end
        end
        local RecoverCoord = RecoverGroup:GetCoordinate()
        local Heading = RescueGroup:GetHeading()
        local HeadingLeft = Heading - 90
        local HeadingRight = Heading + 90
        local LeftCoord = RescueCoord:Translate(ExitDistance, HeadingLeft)
        local RightCoord = RescueCoord:Translate(ExitDistance, HeadingRight)
        local Distance2DLeft = routines.utils.get2DDist(LeftCoord, RecoverCoord)
        local Distance2DRight = routines.utils.get2DDist(RightCoord, RecoverCoord)
        if Distance2DLeft < Distance2DRight then
            ExitAngle = Heading - ExitAngle
            return LeftCoord, ExitAngle
        else
            ExitAngle = Heading + ExitAngle
            return RightCoord, ExitAngle
        end
    else
        local RandomHeading = math.random(0,359)
        local RandomCoord = RescueCoord:Translate(math.random(5,10), RandomHeading)
        return RandomCoord, RandomHeading
    end
end

-- Set waypoints for unloaded pilot
local function ExitVehicleCoord(RescueGroup, PilotGroup, RecoverGroup)
    local RescueUnit = RescueGroup:GetUnit(1)
    local ExitAngle = 90
    local ExitDistance = 3
    if RescueUnit ~= nil and RescueUnit:IsAlive() then
        local RescueType = RescueUnit:GetTypeName()
        if CSAR_Rescue_Air_Type_Angles[RescueType] ~= nil then
            ExitAngle = CSAR_Rescue_Air_Type_Angles[RescueType]
        end
    end
    local Heading = RescueGroup:GetHeading()
    local RescueCoord = RescueGroup:GetCoordinate()
    local Coord0 = PilotGroup:GetCoordinate()
    local Coord1
    local Coord2
    local Coord3 = RecoverGroup:GetCoordinate()
    local HeadingLeft = Heading - 90
    local HeadingRight = Heading + 90
    local LeftCoord = RescueCoord:Translate(ExitDistance, HeadingLeft)
    local RightCoord = RescueCoord:Translate(ExitDistance, HeadingRight)
    local Distance2DLeft = routines.utils.get2DDist(LeftCoord, Coord3)
    local Distance2DRight = routines.utils.get2DDist(RightCoord, Coord3)
    if Distance2DLeft < Distance2DRight then
        Coord1 = RescueCoord:Translate(10, Heading - ExitAngle)
        Coord2 = RescueCoord:Translate(20, Heading - 90)
    else
        Coord1 = RescueCoord:Translate(10, Heading + ExitAngle)
        Coord2 = RescueCoord:Translate(20, Heading + 90)
    end
    local Waypoints = {}
    table.insert(Waypoints, Coord0:WaypointGround(PilotGroup:GetSpeedMax(), 'Off Road'))
    table.insert(Waypoints, Coord1:WaypointGround(PilotGroup:GetSpeedMax(), 'Off Road'))
    table.insert(Waypoints, Coord2:WaypointGround(PilotGroup:GetSpeedMax(), 'Off Road'))
    table.insert(Waypoints, Coord3:WaypointGround(PilotGroup:GetSpeedMax(), 'Off Road'))
    PilotGroup:Route(Waypoints)
end

-- Guide pilot to rescue
local function EnterVehicleCoord(RescueGroup, PilotGroup)
    local RescueUnit = RescueGroup:GetUnit(1)
    local RescueCoord = RescueGroup:GetCoordinate()
    local PilotCoord = PilotGroup:GetCoordinate()
    if RescueUnit ~= nil and RescueUnit:IsAlive() and not CoordInWater(PilotCoord) then
        local RescueType = RescueUnit:GetTypeName()
        local EnterDistance = 3
        local EnterAngle = 90
        if CSAR_Rescue_Air_Type_Angles[RescueType] ~= nil then
            EnterAngle = CSAR_Rescue_Air_Type_Angles[RescueType]
        end
        local Distance2D = routines.utils.get2DDist(PilotCoord, RescueCoord)
        local Heading = RescueGroup:GetHeading()
        if Distance2D > 22 then
            EnterDistance = 20
            EnterAngle = 90
        elseif Distance2D > 12 and RescueGroup:IsAirPlane() then
            EnterDistance = 10
            EnterAngle = EnterAngle - 10
        end
        local HeadingLeft = Heading - EnterAngle
        local HeadingRight = Heading + EnterAngle
        local LeftCoord = RescueCoord:Translate(EnterDistance, HeadingLeft)
        local RightCoord = RescueCoord:Translate(EnterDistance, HeadingRight)
        local Distance2DLeft = routines.utils.get2DDist(LeftCoord, PilotCoord)
        local Distance2DRight = routines.utils.get2DDist(RightCoord, PilotCoord)
        if Distance2DLeft < Distance2DRight then
            if Debug then MESSAGE:New('EnterVehicleCoord = left\nEnterDistance = '..EnterDistance..'\nEnterAngle = '..EnterAngle, 10):ToAll() end
            return LeftCoord
        else
            if Debug then MESSAGE:New('EnterVehicleCoord = right\nEnterDistance = '..EnterDistance..'\nEnterAngle = '..EnterAngle, 10):ToAll() end
            return RightCoord
        end
    else
        return RescueCoord
    end
end

-- Unload pilots from plane/helicopter
local function UnloadAllPilots(CurRescueGroup, RecoverGroup) -- ToCoord
    if CurRescueGroup ~= nil and RecoverGroup ~= nil then
        if CurRescueGroup.stneCSAR.UnloadInProgress == nil then
            if Debug then MESSAGE:New("DEBUG: CSAR: Rescue: " .. CurRescueGroup:GetName() .. " start unload", 10):ToAll() end
            CurRescueGroup.stneCSAR.UnloadInProgress = true

            local PilotCount = CurRescueGroup.stneCSAR.PilotCargo
            local Coalition = CurRescueGroup:GetCoalition()
            local Coord = CurRescueGroup:GetCoordinate()
            for i = 1, PilotCount, 1 do
                SCHEDULER:New(nil, function()

                    if CurRescueGroup:IsAlive() and RecoverGroup:IsAlive() then

                        local RescueInAir = CurRescueGroup:InAir()
                        local RescueSpeed = CurRescueGroup:GetVelocityKMH()
                        local RecoverIsShip = false
                        if RecoverGroup:IsShip() then
                            RecoverIsShip = true
                        end

                        if RescueInAir == false and RescueSpeed < 1 or RescueInAir == false and RecoverIsShip then
                            if RecoverIsShip then
                                CurRescueGroup.stneCSAR.PilotCargo = CurRescueGroup.stneCSAR.PilotCargo - 1
                                local CurMsgTable = CSAR_Msg_Unload_Pilot
                                Random_Message_To_Group(CurRescueGroup, CurMsgTable, true, true)
                            else
                                local ToCoord = RecoverGroup:GetCoordinate()
                                local PilotTemplate = Assets[Coalition].Pilot
                                CSAR_Return_Counter = CSAR_Return_Counter + 1
                                local CurAlias = "R" .. string.format("%d",timer.getAbsTime()) .. "_" .. CSAR_Return_Counter --.. i
                                local CurSpawn = SPAWN:NewWithAlias(PilotTemplate, CurAlias)
                                --CurSpawn:InitHeading(CurRescueGroup:GetHeading())
                                CurSpawn:OnSpawnGroup(
                                    function(SpwnGroup)
                                        local CurMsgTable = CSAR_Msg_Unload_Pilot
                                        if ToCoord then
                                            local Distance2D = math.floor(routines.utils.get2DDist(Coord, ToCoord))
                                            local Distance_Good = CSAR_Recover_Pilot_Distance / 3
                                            local Distance_Bad = Distance_Good * 2
                                            if Distance2D < Distance_Good then
                                                CurMsgTable = CSAR_Msg_Unload_Pilot_Good
                                            end
                                            if Distance2D > Distance_Bad then
                                                CurMsgTable = CSAR_Msg_Unload_Pilot_Bad
                                            end
                                            ExitVehicleCoord(CurRescueGroup, SpwnGroup, RecoverGroup)
                                            --SpwnGroup:RouteGroundTo(ToCoord, SpwnGroup:GetSpeedMax(), "Off Road", 1)
                                        end
                                        Random_Message_To_Group(CurRescueGroup, CurMsgTable, true, true)
                                        CleanUpTimer(SpwnGroup)
                                    end
                                )
                                local NewCoord, NewHeading = GetSpawnCoordHdg(CurRescueGroup, RecoverGroup)
                                CurSpawn:InitHeading(NewHeading)
                                CurSpawn:SpawnFromVec2(NewCoord:GetVec2())
                                --CurSpawn:SpawnFromUnit(CurRescueGroup)
                                CurRescueGroup.stneCSAR.PilotCargo = CurRescueGroup.stneCSAR.PilotCargo - 1
                            end
                        else
                            local CurMsgTable = CSAR_Msg_Unload_Pilot_Failed
                            Random_Message_To_Group(CurRescueGroup, CurMsgTable, true, true)
                            if Debug then MESSAGE:New("DEBUG: CSAR: Rescue: " .. CurRescueGroup:GetName() .. " unload failed", 10):ToAll() end
                        end
                        if i >= PilotCount then
                            CurRescueGroup.stneCSAR.UnloadInProgress = nil
                        end
                    end
                end, {}, i*3)
            end
        else
            if Debug then MESSAGE:New("DEBUG: CSAR: Rescue: " .. CurRescueGroup:GetName() .. " unload in progress", 10):ToAll() end
        end
    end
end

-- Timer
SCHEDULER:New(nil, function()
    -- Rescue set group
    CSAR_Rescue_Set_Group:ForEachGroupAlive(
        function(CurRescueGroup)
            if CurRescueGroup.stneCSAR == nil then
                CurRescueGroup.stneCSAR = {}
            end
            if CurRescueGroup.stneCSAR.PilotCargo == nil then
                CurRescueGroup.stneCSAR.PilotCargo = 0
            end
            if CurRescueGroup.stneCSAR.PilotCargoMax == nil then
                CurRescueGroup.stneCSAR.PilotCargoMax = 0
            end
            local RescueCoalition = CurRescueGroup:GetCoalition()
            local RescueCoord = CurRescueGroup:GetCoordinate()
            local RescueInAir = CurRescueGroup:InAir()
            local RescueSpeed = CurRescueGroup:GetVelocityKMH()
            -- Pilot set group
            CSAR_Pilot_Set_Group:ForEachGroupAlive(
                function(CurPilotGroup)
                    if CurPilotGroup.stneCSAR == nil then
                        CurPilotGroup.stneCSAR = {}
                    end
                    if CurPilotGroup.stneCSAR.FlareSmokeTime == nil then
                        CurPilotGroup.stneCSAR.FlareSmokeTime = 0
                    end
                    local PilotCoalition = CurPilotGroup:GetCoalition()
                    -- Same coalition
                    if PilotCoalition == RescueCoalition then
                        local PilotCoord = CurPilotGroup:GetCoordinate()
                        local PilotInWater = CoordInWater(PilotCoord)
                        local DayTime = PilotCoord:IsDay()
                        if Debug then MESSAGE:New("DEBUG: CSAR: Daytime: " .. tostring(DayTime), 10):ToAll() end
                        local Distance2D = math.floor(routines.utils.get2DDist(PilotCoord, RescueCoord))
                        local Distance3D = math.floor(routines.utils.get3DDist(PilotCoord, RescueCoord))
                        local CurTime = timer.getAbsTime()
                        local CurRescueUnit = CurRescueGroup:GetUnit(1)

                        -- ME placed units
                        if CurPilotGroup.stneCSAR.BeaconActivated == nil then
                            local CurBeaconsGuard, CurBeaconsNav = SpawnBeacon(PilotCoord, true, true, PilotCoalition)
                            CurPilotGroup.stneCSAR.BeaconsGuard = CurBeaconsGuard
                            CurPilotGroup.stneCSAR.BeaconsNav = CurBeaconsNav
                            CurPilotGroup.stneCSAR.BeaconActivated = true
                        end

                        if CurPilotGroup.stneCSAR.BeaconActivated ~= nil and CurRescueGroup.stneCSAR.Ejected == nil then

                            if Debug then MESSAGE:New("DEBUG: CSAR:\nRescue: " .. CurRescueGroup:GetName() .. " Pilot: " .. CurPilotGroup:GetName() .. "\nInWater: " .. tostring(PilotInWater) .. " Distance2D: " .. Distance2D  .. " Distance3D: " .. Distance3D, 10):ToAll() end
                            -- Get in rescue
                            if Distance2D <= 5 and RescueInAir == false or Distance3D <= CSAR_Rescue_Rope_Length and PilotInWater then
                                if CurRescueGroup.stneCSAR.PilotCargo < CurRescueGroup.stneCSAR.PilotCargoMax then
                                    CurRescueGroup.stneCSAR.PilotCargo = CurRescueGroup.stneCSAR.PilotCargo + 1
                                    Random_Message_To_Group(CurRescueGroup, CSAR_Msg_GetIn_Pilot, true, true)
                                    CleanUpTimer(CurPilotGroup, true)
                                else
                                    Random_Message_To_Group(CurRescueGroup, CSAR_Msg_Cargo_Full, true, true)
                                end
                            -- Move closer
                            elseif Distance2D <= CSAR_Move_Pilot_Distance then
                                RescueCoord = EnterVehicleCoord(CurRescueGroup, CurPilotGroup)
                                RescueCoord.y = PilotCoord.y --0
                                CurPilotGroup:RouteGroundTo(RescueCoord, CurPilotGroup:GetSpeedMax(), "Off Road", 0)
                                if Debug then MESSAGE:New("DEBUG: CSAR: Move: " .. CurPilotGroup:GetName(), 10):ToAll() end
                            -- Smoke
                            elseif Distance2D <= CSAR_FlareSmoke_Distance and CurTime > CurPilotGroup.stneCSAR.FlareSmokeTime then
                                if PilotInWater then
                                    CurPilotGroup.stneCSAR.FlareSmokeTime = CurTime + 120
                                    PilotCoord:FlareYellow()
                                    if Debug then MESSAGE:New("DEBUG: CSAR: Flare location: " .. CurPilotGroup:GetName(), 10):ToAll() end
                                else
                                    if DayTime then
                                        CurPilotGroup.stneCSAR.FlareSmokeTime = CurTime + 300
                                        PilotCoord:SmokeOrange()
                                        if Debug then MESSAGE:New("DEBUG: CSAR: Smoke location: " .. CurPilotGroup:GetName(), 10):ToAll() end
                                    else
                                        CurPilotGroup.stneCSAR.FlareSmokeTime = CurTime + 120
                                        PilotCoord:FlareYellow()
                                        if Debug then MESSAGE:New("DEBUG: CSAR: Flare location: " .. CurPilotGroup:GetName(), 10):ToAll() end
                                    end
                                end
                                -- Move enemy
                                if CurPilotGroup.stneCSAR.Enemy ~= nil and CurPilotGroup.stneCSAR.Enemy:IsAlive() then
                                    local CurEnemyGroup = CurPilotGroup.stneCSAR.Enemy
                                    CurEnemyGroup:RouteGroundTo(PilotCoord, CurEnemyGroup:GetSpeedMax(), "Diamond", 0)
                                    if Debug then MESSAGE:New("DEBUG: CSAR: Route enemy: " .. CurEnemyGroup:GetName(), 10):ToAll() end
                                end
                            end
                        end
                    end
                end
            )
            -- Unload pilot cargo
            local RescueInWater = CoordInWater(RescueCoord)
            if CurRescueGroup.stneCSAR.PilotCargo >= 1 and RescueInAir == false and RescueSpeed <= 1 or CurRescueGroup.stneCSAR.PilotCargo >= 1 and RescueInAir == false and RescueInWater then
                if Debug then MESSAGE:New("DEBUG: CSAR: Rescue: " .. CurRescueGroup:GetName() .. " ready to unload", 10):ToAll() end
                local RecoverGroup, RecoverDistance = ClosestRecover(CurRescueGroup, RescueCoord)
                if RecoverGroup ~= nil and RecoverDistance <= CSAR_Recover_Pilot_Distance then
                    if Debug then MESSAGE:New("DEBUG: CSAR: Unload target: " .. RecoverGroup:GetName(), 10):ToAll() end
                    UnloadAllPilots(CurRescueGroup, RecoverGroup) -- RecoverGroup:GetCoordinate()
                end
            end
            if Debug then MESSAGE:New("DEBUG: CSAR: Rescue: " .. CurRescueGroup:GetName() .. " Pilots: " .. CurRescueGroup.stneCSAR.PilotCargo .. " Max: " .. CurRescueGroup.stneCSAR.PilotCargoMax, 10):ToAll() end
        end
    )
end, {}, CSAR_Schedule_Timer, CSAR_Schedule_Timer)

-- EOF
env.info('FILE: '..FileVer..' END')
