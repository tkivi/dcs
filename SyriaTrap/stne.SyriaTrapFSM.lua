local Cfg = {
--#################################################################################################
--
--  SyriaTrapFSM
--
--  Syria trap mission FSM for ground groups.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    Prefix = 'ASSAULT',                             -- GROUP prefix
    Sensors = {                                     -- Detection sensors, true/false
        true,                                       -- Visual
        true,                                       -- Optical
        false,                                      -- Radar
        false,                                      -- IRST
        false,                                      -- RWR
        false,                                      -- DLINK
    }
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SyriaTrapFSM.lua'
local Version = '200928'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SyriaTrapFSM then
    for key, value in pairs(STNE_Config_SyriaTrapFSM) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local Prefix = Cfg.Prefix
local Sensors = Cfg.Sensors

-- Offroad formations
local Formations = {'Off Road','Rank','Cone','Vee','Diamond','EchelonL','EchelonR'}

--- Check if coord is on ground
--- @param Coord table
local function CoordOnGround(Coord)
    if Coord:IsSurfaceTypeShallowWater() or Coord:IsSurfaceTypeWater() then
        return false
    else
        return true
    end
end

--- Get enemy group
--- @param Controllable table
local function GetEnemyGroup(Controllable)
    if Debug then BASE:E({FileVer,'GetEnemyGroup'}) end
    local EnemyGroup = nil
    local ControllablePointVec2 = Controllable:GetPointVec2()
    local DetectedUnitSet = Controllable:GetDetectedUnitSet(Sensors[1], Sensors[2], Sensors[3], Sensors[4], Sensors[5], Sensors[6])
    local NearestTarget = DetectedUnitSet:FindNearestObjectFromPointVec2(ControllablePointVec2)
    if Debug then BASE:E({Controllable=Controllable:GetName(),DetectedCount=DetectedUnitSet:Count()}) end
    if NearestTarget ~= nil and NearestTarget:IsAlive() and NearestTarget:IsGround() then
        local CoalitionControllable = Controllable:GetCoalition()
        local CoalitionNearestTarget = NearestTarget:GetCoalition()
        if CoalitionControllable ~= CoalitionNearestTarget and CoalitionNearestTarget ~= 0 then
            if Debug then BASE:E({Controllable=Controllable:GetName(),NearestTarget=NearestTarget:GetName()}) end
            EnemyGroup = NearestTarget
        end
    end
    return EnemyGroup
end

--- Attack enemy group
--- @param Controllable table
--- @param EnemyGroup table
local function AttackEnemyGroup(Controllable, EnemyGroup)
    if Debug then BASE:E({FileVer,'AttackEnemyGroup'}) end
    local EnemyGroupCoord = EnemyGroup:GetCoordinate()
    local EnemyGroupHeading = EnemyGroup:GetHeading()
    local SetSpeed = Controllable:GetSpeedMax() * 0.3
    if math.random(1,100) > 50 then
        EnemyGroupHeading = EnemyGroupHeading + 120
    else
        EnemyGroupHeading = EnemyGroupHeading - 120
    end
    local EnemyGroupCoordTranslated = EnemyGroupCoord:Translate(500, EnemyGroupHeading)
    local CoordOnGround = CoordOnGround(EnemyGroupCoordTranslated)
    local NewFormation = Formations[math.random(1,#Formations)]
    if CoordOnGround then
        Controllable:RouteGroundTo(EnemyGroupCoordTranslated, SetSpeed, NewFormation, 1)
    end
    if Debug then BASE:E({Controllable=Controllable:GetName(),Enemy=EnemyGroup:GetName(),CoordOnGround=CoordOnGround,Formation=NewFormation}) end
end

--- Update next waypoint
--- @param Controllable table
local function UpdateNextWaypoint(Controllable)
    if Debug then BASE:E({FileVer,'UpdateNextWaypoint'}) end
    if Controllable.STNE == nil then Controllable.STNE = {} end
    if Controllable.STNE.SyriaTrapFSM == nil then Controllable.STNE.SyriaTrapFSM = {} end
    if Controllable.STNE.SyriaTrapFSM.NextWP == nil then
        Controllable.STNE.SyriaTrapFSM.NextWP = 1
    end
    local RoutePoints = Controllable:GetTemplateRoutePoints()
    local ControllableCoord = Controllable:GetCoordinate()
    for Point, PointData in UTILS.spairs(RoutePoints) do
        if Point >= Controllable.STNE.SyriaTrapFSM.NextWP then
            local Coord = COORDINATE:New(PointData.x, 0, PointData.y)
            local Distance = Coord:Get2DDistance(ControllableCoord)
            if Distance <= 5000 and Point < #RoutePoints then
                Controllable.STNE.SyriaTrapFSM.NextWP = Point + 1
                break
            end
        end
    end
    if Debug then BASE:E({FileVer,Controllable=Controllable:GetName(),NextWP=Controllable.STNE.SyriaTrapFSM.NextWP}) end
end

--- Continue route
--- @param Controllable table
local function ContinueRoute(Controllable)
    if Debug then BASE:E({FileVer,'ContinueRoute'}) end
    local Waypoints = {}
    local RoutePoints = Controllable:GetTemplateRoutePoints()
    local ControllableCoord = Controllable:GetCoordinate()
    local SetSpeed = Controllable:GetSpeedMax() --0.7
    local NewFormation = Formations[math.random(1,#Formations)]
    local FirstWP = ControllableCoord:WaypointGround(SetSpeed, NewFormation)
    local WaypointID = 1
    table.insert(Waypoints, WaypointID, FirstWP)
    if Debug then BASE:E({FileVer,RoutePoint='CurrentLocation',NewRoutePoint=WaypointID}) end
    for i = 1, #RoutePoints, 1 do
        if i >= Controllable.STNE.SyriaTrapFSM.NextWP then
            local Waypoint = RoutePoints[i]
            if Waypoint.action == 'On Road' then
                local RoadStartWP = ControllableCoord:GetClosestPointToRoad(false)
                local RoadEndWP = COORDINATE:New(Waypoint.x, 0, Waypoint.y)
                local RouteRoadWP, CanRoad = Controllable:TaskGroundOnRoad(RoadEndWP, SetSpeed, 'Off Road', false, RoadStartWP)
                if CanRoad then
                    for _, RoadPoint in UTILS.spairs(RouteRoadWP) do
                        WaypointID = WaypointID + 1
                        table.insert(Waypoints, WaypointID, RoadPoint)
                        if Debug then BASE:E({FileVer,RoutePoint='OnRoad',NewRoutePoint=WaypointID}) end
                    end
                end
            end
            WaypointID = WaypointID + 1
            table.insert(Waypoints, WaypointID, Waypoint)
            if Debug then BASE:E({FileVer,RoutePoint=i,NewRoutePoint=WaypointID}) end
        else
            if Debug then BASE:E({FileVer,RoutePoint=i}) end
        end
    end
    Controllable:Route(Waypoints, 1)
end

-- Create class
STNE_SYRIA_TRAP_FSM = {
    ClassName = "STNE_SYRIA_TRAP_FSM",
}

-- Inherit Moose FSM_CONTROLLABLE for class
function STNE_SYRIA_TRAP_FSM:New(Controllable)
    local self = BASE:Inherit(self, FSM_CONTROLLABLE:New())
    self:SetControllable(Controllable)
    -- States
    self:SetStartState('Stopped')
    self:AddTransition('Stopped', 'Start', 'Active')
    self:AddTransition('*', 'Search', 'Searching')
    self:AddTransition('*', 'Attack', 'Attacking')
    self:AddTransition('*', 'Stop', 'Stopped')
    return self
end

-- After start event
function STNE_SYRIA_TRAP_FSM:OnAfterStart(Event, From, To)
    local Controllable = self:GetControllable()
    if Controllable ~= nil and Controllable:IsAlive() then
        if Debug then BASE:E({FileVer,Event='OnAfterStart',Controllable=Controllable:GetName(),From=From,To=To}) end
    end
    self:__Search(30)
end

-- After search event
function STNE_SYRIA_TRAP_FSM:OnAfterSearch(Event, From, To)
    local Controllable = self:GetControllable()
    if Controllable ~= nil and Controllable:IsAlive() then
        if Debug then BASE:E({FileVer,Event='OnAfterSearch',Controllable=Controllable:GetName(),From=From,To=To}) end
        if From == 'Attacking' then
            ContinueRoute(Controllable)
        end
        local EnemyGroup = GetEnemyGroup(Controllable)
        if EnemyGroup == nil then
            self:__Search(30)
        else
            self:__Attack(1)
        end
    else
        self:Stop()
    end
end

-- After attack event
function STNE_SYRIA_TRAP_FSM:OnAfterAttack(Event, From, To)
    local Controllable = self:GetControllable()
    if Controllable ~= nil and Controllable:IsAlive() then
        if Debug then BASE:E({FileVer,Event='OnAfterAttack',Controllable=Controllable:GetName(),From=From,To=To}) end
        local EnemyGroup = GetEnemyGroup(Controllable)
        if EnemyGroup == nil then
            self:__Search(30)
        else
            AttackEnemyGroup(Controllable, EnemyGroup)
            self:__Attack(30)
        end
    else
        self:Stop()
    end
end

-- Attach FSM to new groups scheduler
SCHEDULER:New(nil, function()
    if Debug then BASE:E({FileVer,'SyriaTrapFSM attach FSM to group scheduler'}) end
    local PrefixSetGroup = SET_GROUP:New()
    PrefixSetGroup:FilterPrefixes(Prefix)
    PrefixSetGroup:FilterCategoryGround()
    PrefixSetGroup:FilterActive()
    PrefixSetGroup:FilterOnce()
    PrefixSetGroup:ForEachGroupAlive(
        function(PrefixGrp)
            if PrefixGrp.STNE == nil then PrefixGrp.STNE = {} end
            if PrefixGrp.STNE.SyriaTrapFSM == nil then PrefixGrp.STNE.SyriaTrapFSM = {} end
            if PrefixGrp.STNE.SyriaTrapFSM.Enabled == nil then
                PrefixGrp.STNE.SyriaTrapFSM.Enabled = true
                if Debug then BASE:E({FileVer,Enabled=PrefixGrp.STNE.SyriaTrapFSM.Enabled,Controllable=PrefixGrp:GetName()}) end
                STNE_SYRIA_TRAP_FSM:New(PrefixGrp):Start()
            end
            if PrefixGrp.STNE.SyriaTrapFSM.Enabled then
                UpdateNextWaypoint(PrefixGrp)
            end
        end
    )
end, {}, 60, 60)

-- EOF
env.info('FILE: '..FileVer..' END')