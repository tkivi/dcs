local Cfg = {
--#################################################################################################
--
--  SaveGroups
--
--  Persistent save for groups in mission.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                               -- Debug mode, true/false
    Folder = 'C:/Folder/',                       -- Save folder
    Prefix = {'pSv_'},                           -- GROUP prefixes to save
    Timer = 60,                                  -- Save data scheduler timer, in seconds
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveGroups.lua'
local Version = '200708'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_SaveGroups then
    for key, value in pairs(STNE_Config_SaveGroups) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local SaveFolder = Cfg.Folder
local SavePrefix = Cfg.Prefix
local SaveTimer = Cfg.Timer

-- Define save file
local SaveFile = 'SaveData.Groups.lua'

-- Define save data table
STNE_Save_All_Groups = {}

-- Save template
local SaveTemplate = {
    Group = '',
    Alias = '',
    Task = 'NONE',
    Follow = 'NONE',
    Value = 0,
    Supply = 0,
    Speed = 0,
    Heading = 0,
    Vec3 = {y = 0, x = 0, z = 0,},
    Units = {},
    Waypoint = 1,
    Route = {},
}

--- Convert table to string for save
--- @param Tbl table
local function stne_TableToSave(Tbl)
    if Debug then BASE:E({FileVer,'stne_TableToSave'}) end
    local ReT = '{'
    --- Sub function for convert table to string for save
    --- @param Tbl table
    --- @param SingleLine boolean
    local function stne_SubTableToSave(Tbl,SingleLine)
        local SubReT = ''
        for key, value in pairs(Tbl) do
            if type(key) == 'number' then
                if SingleLine then
                    key = ''
                else
                    key = '\n        '
                end
            else
                if SingleLine then
                    key = tostring(' '..key..' = ')
                else
                    key = tostring('\n        '..key..' = ')
                end
            end
            if type(value) == 'string' then value=tostring("'"..value.."'") end
            if type(value) == 'table' then
                value = '{'..tostring(stne_SubTableToSave(value,true))..'}'
            end
            SubReT = SubReT..key..tostring(value)..','
        end
        return tostring(SubReT)
    end
    local SubReT = stne_SubTableToSave(Tbl)
    ReT = ReT..SubReT..'\n    }'
    return tostring(ReT)
end

--- Remove old ME groups
local function Remove_ME_Groups()
    local ME_Set_Grp = SET_GROUP:New()
    ME_Set_Grp:FilterActive()
    ME_Set_Grp:FilterPrefixes(SavePrefix)
    ME_Set_Grp:FilterOnce()
    if Debug then BASE:E({FileVer,'Remove ME groups: '..tostring(ME_Set_Grp:Count())}) end
    ME_Set_Grp:ForEachGroup(
        function(CurGrp)
            CurGrp:Destroy()
        end
    )
end

-- Load saved data if exists
local Load_Data = loadfile(SaveFolder .. SaveFile)
if Load_Data then
    Load_Data()
    if Debug then BASE:E({FileVer,'Load data, groups: '..tostring(#STNE_Save_All_Groups)}) end
    Remove_ME_Groups()
else
    if Debug then BASE:E({FileVer,'Data not found'}) end
end

-- Set data from save
for key, value in pairs(STNE_Save_All_Groups) do
    local CurGrpGroup = STNE_Save_All_Groups[key].Group
    local CurGrpAlias = STNE_Save_All_Groups[key].Alias
    local CurGrpSpeed = STNE_Save_All_Groups[key].Speed
    local CurGrpHeading = STNE_Save_All_Groups[key].Heading
    local CurGrpVec3 = STNE_Save_All_Groups[key].Vec3
    if GROUP:FindByName(CurGrpGroup) == nil then
        local ErrorMsg = 'ERROR: '..FileVer..' SaveData no group: '..CurGrpGroup
        MESSAGE:New(ErrorMsg, 300):ToAll()
        env.info(ErrorMsg)
    else
        local SpwnObj = SPAWN:NewWithAlias(CurGrpGroup, CurGrpAlias)
        if CurGrpSpeed > 0 then
            SpwnObj:InitHeading(CurGrpHeading)
        else
            SpwnObj:InitGroupHeading(CurGrpHeading)
        end
        SpwnObj:OnSpawnGroup(
            function(SpwnGrp)
                local InitUnits = SpwnGrp:GetUnits()
                SpwnGrp.stne = {}
                SpwnGrp.stne.Save = value
                SpwnGrp.stne.Units = InitUnits
                for i = 1, #InitUnits, 1 do
                    if SpwnGrp.stne.Save.Units[i] == false then
                        InitUnits[i]:Destroy()
                    end
                end
                -- Air
                --if SpwnGrp:IsAir() then
                --    local LastWP = Cur_Route[Cur_Waypoint]
                --    local LastCoord = COORDINATE:New(LastWP.x, 500, LastWP.y)
                --    SpwnGrp:RouteAirTo(LastCoord, nil, nil, nil, Cur_Speed, nil)
                    --SpwnGrp:RouteAirTo(SpwnGrp:GetCoordinate():Translate(UTILS.NMToMeters(100), SpwnGrp:GetHeading()), nil, nil, nil, Cur_Speed, nil)
                --end
            end
        )
        SpwnObj:SpawnFromVec3(CurGrpVec3)
    end
end

-- Enable save scheduler if IO available
if not io then
    MESSAGE:New("INFO: SAVE OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.\nLoading previously saved data is still allowed.", 60):ToAll()
else
    -- Save data scheduler
    SCHEDULER:New(nil, function()
        if Debug then BASE:E({FileVer,'Save START'}) end
        -- Set group
        local Save_Set_Group = SET_GROUP:New()
        Save_Set_Group:FilterActive()
        Save_Set_Group:FilterPrefixes(SavePrefix)
        Save_Set_Group:FilterOnce()
        -- Start save data
        local Save_Data = "STNE_Save_All_Groups = {"
        Save_Set_Group:ForEachGroupAlive(
            function(CurGrp)
                local CurGrpName = UTILS.Split(CurGrp:GetName(), "#")[1]
                -- Check nil
                if CurGrp.stne == nil then
                    CurGrp.stne = {}
                end
                if CurGrp.stne.Save == nil then
                    CurGrp.stne.Save = SaveTemplate
                    CurGrp.stne.Save.Group = CurGrpName
                    CurGrp.stne.Save.Alias = CurGrpName
                    CurGrp.stne.Units = CurGrp:GetUnits()
                    -- Read ME template waypoints if any
                    local RoutePoints = CurGrp:GetTemplateRoutePoints()
                    if #RoutePoints > 0 then
                        for i = 1, #RoutePoints, 1 do
                            local RP = {x = RoutePoints[i].x, y = RoutePoints[i].y}
                            table.insert(CurGrp.stne.Save.Route, RP)
                        end
                    end
                end
                -- Set changing data for group table
                CurGrp.stne.Save.Speed = CurGrp:GetVelocityKMH()
                CurGrp.stne.Save.Heading = CurGrp:GetHeading()
                CurGrp.stne.Save.Vec3 = CurGrp:GetCoordinate():GetVec3()
                CurGrp.stne.Save.Units = {}
                for i = 1, #CurGrp.stne.Units, 1 do
                    if CurGrp.stne.Units[i] ~= nil and CurGrp.stne.Units[i]:IsAlive() == true then
                        table.insert(CurGrp.stne.Save.Units, true)
                    else
                        table.insert(CurGrp.stne.Save.Units, false)
                    end
                end
                -- Get data
                Save_Data = Save_Data .. "\n    " .. stne_TableToSave(CurGrp.stne.Save) .. ","
            end
        )
        Save_Data = Save_Data .. "\n}"
        -- Save data to file
        local Save_File = assert(io.open(SaveFolder .. SaveFile, "w"))
        if Save_File then
            Save_File:write(Save_Data)
            Save_File:close()
        end
        if Debug then BASE:E({FileVer,'Save END count: '..tostring(Save_Set_Group:Count())}) end
    end, {}, SaveTimer, SaveTimer)
end

-- EOF
env.info('FILE: '..FileVer..' END')