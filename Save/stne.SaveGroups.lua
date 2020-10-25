local Cfg = {
--#################################################################################################
--
--  SaveGroups
--
--  Persistent save for groups.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    Folder = 'C:\\Folder',                          -- Save folder, drive:\\folder\\folder
    Timer = 0,                                      -- Save scheduler, in seconds. 0 = save only when mission end
    Prefix = {                                      -- GROUP prefixes, save only these groups
        'GroupPrefixOne',
        'GroupPrefixTwo',
    },
    ResetSave = 667,                                -- Flag to reset save data
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SaveGroups.lua'
local Version = '201022'
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
local SaveTimer = Cfg.Timer
local PrefixGroup = Cfg.Prefix
local ResetSave = Cfg.ResetSave

-- Prepare global variables
if STNE == nil then STNE = {} end
if STNE.Save == nil then STNE.Save = {} end
if STNE.Flags == nil then STNE.Flags = {} end
STNE.Flags.ResetSaveGroups = ResetSave

-- Prepare local save variables
local SaveFile = 'SaveData.STNE.Save.Groups.lua'

-- Check if io enabled
if not io then
    MESSAGE:New('INFO: GROUPS SAVE/LOAD OPTION DISABLED\nYou need to enable IO command in MissionScripting.lua to enable persistent save.', 600):ToAll()
end

-- Load saved data if io enabled
if io then
    local Load_Data = loadfile(SaveFolder..'\\'..SaveFile)
    if Load_Data then
        -- Load saved data
        Load_Data()
        if Debug then BASE:E({FileVer,'STNE.Save.Groups savedata loaded'}) end
    end
end

-- Remove old groups and spawn new ones if group save data exists
if STNE.Save.Groups ~= nil then
    if Debug then BASE:E({FileVer,'STNE.Save.Groups savedata found, removing old groups'}) end
    local Set_Group = SET_GROUP:New()
    Set_Group:FilterPrefixes(PrefixGroup)
    Set_Group:FilterOnce()
    Set_Group:ForEachGroupAlive(
        function(Grp)
            Grp:Destroy()
        end
    )
    -- Spawn groups from savedata
    for GroupName, Template in pairs(STNE.Save.Groups) do
        if Debug then BASE:E({FileVer,'Spawn',Group=GroupName}) end
        _DATABASE:Spawn(Template)
    end
else
    if Debug then BASE:E({FileVer,'STNE.Save.Groups savedata not found'}) end
end

--- Convert table to string for save, copy from stne.Utils.lua
--- @param Tbl table
local function TableToSave(Tbl)
    if Debug then BASE:E({FileVer,'TableToSave'}) end
    local ReT = '{'
    --- Sub function for convert table to string for save
    --- @param Tbl table
    --- @param Indx number
    local function SubTableToSave(Tbl, Indx)
        --local Func = WithFunc or false
        local Tabs = Indx or 1
        local Tab = ''
        local SubReT = ''
        for i = 1, Tabs, 1 do
            if i <= Tabs then
                Tab = Tab..'    '
            end
        end
        for key, value in pairs(Tbl) do
            -- Keys
            if type(key) == 'number' then
                key = '\n'..Tab..'['..tostring(key)..'] = '
            elseif type(key) == 'string' then
                key = "\n"..Tab.."['"..tostring(key).."'] = "
            end
            -- Values
            if type(value) == 'string' then
                value = "'"..tostring(value).."',"
            elseif type(value) == 'number' then
                value = tostring(value)..','
            elseif type(value) == 'boolean' then
                value = tostring(value)..','
            elseif type(value) == 'function' then
                    --value = 'f(),'
            elseif type(value) == 'table' then
                value = '{'..tostring(SubTableToSave(value, Tabs + 1))..'\n'..Tab..'},'
            else
                value = nil
            end
            if value ~= nil then
                SubReT = SubReT..key..tostring(value)
            end
        end
        return tostring(SubReT)
    end
    local SubReT = SubTableToSave(Tbl)
    ReT = ReT..SubReT..'\n}'
    return tostring(ReT)
end

--- Prepare groups data for save
STNE.Save.Groups = {}
local function PrepareGroups()
    if Debug then BASE:E({FileVer,'PrepareGroups'}) end
    STNE.Save.Groups = {}
    -- Get groups for save
    local Set_Group = SET_GROUP:New()
    Set_Group:FilterPrefixes(PrefixGroup)
    Set_Group:FilterOnce()
    Set_Group:ForEachGroupAlive(
        function(Grp)
            local TempTable = {}
            local UnitCount = 0
            local GrpName = Grp:GetName()
            local GrpTemplate = Grp:GetTemplate()
            local GrpCoord = Grp:GetCoordinate()
            local GrpUnits = Grp:GetUnits()
            for UnitID, Unit in UTILS.spairs(GrpUnits) do
                if Unit:IsAlive() then
                    UnitCount = UnitCount + 1
                    if Debug then BASE:E({FileVer,Group=GrpName,UnitID=UnitID,Alive='true',NewID=UnitCount}) end
                    table.insert(TempTable, UnitCount, GrpTemplate.units[UnitID])
                    -- Get new position and heading for unit
                    local UnitCoord = Unit:GetCoordinate()
                    local UnitHdg = Unit:GetHeading()
                    TempTable[UnitCount].x = UnitCoord.x
                    TempTable[UnitCount].y = UnitCoord.z
                    -- Moose heading fix GROUP:Respawn -> _Heading
                    local function HeadingFix(Heading)
                        local Hdg
                        if Heading <= 180 then
                            Hdg = math.rad(Heading)
                        else
                            Hdg = -math.rad(360 - Heading)
                        end
                        return Hdg 
                    end     
                    TempTable[UnitCount].heading = HeadingFix(UnitHdg)
                else
                    if Debug then BASE:E({FileVer,Group=GrpName,UnitID=UnitID,Alive='false'}) end
                end
            end
            GrpTemplate.units = TempTable
            --local TmpCoord = COORDINATE:New(GrpTemplate.x, 0, GrpTemplate.y)
            --local Distance = GrpCoord:Get2DDistance(TmpCoord)
            --if Distance >= 2 then
            --    if GrpTemplate.uncontrolled ~= nil then
            --        if Debug then BASE:E({FileVer,Uncontrolled='false',Group=GrpName,Distance=Distance}) end
            --        GrpTemplate.uncontrolled = false
            --    end
            --end
            --GrpTemplate.lateActivation = false
            STNE.Save.Groups[GrpName] = GrpTemplate
        end
    )
end

--- Save data to file
local function SaveDataToFile()
    if Debug then BASE:E({FileVer,'SaveDataToFile'}) end
    -- Save data if io enabled
    if io then
        local SaveData = ''
        local ResetFlag = trigger.misc.getUserFlag(STNE.Flags.ResetSaveGroups)
        if ResetFlag == 0 then
            -- Prepare groups data for save
            PrepareGroups()
            -- Save data
            SaveData = "STNE.Save.Groups = "
            SaveData = SaveData..TableToSave(STNE.Save.Groups)
        else
            SaveData = '-- Reset save data, flag: '..STNE.Flags.ResetSaveGroups..' value: '..ResetFlag
            if Debug then BASE:E({FileVer,'STNE.Save.Groups reset savedata'}) end
        end
        local Save_File = assert(io.open(SaveFolder..'\\'..SaveFile, "w"))
        if Save_File then
            Save_File:write(SaveData)
            Save_File:close()
            if Debug then BASE:E({FileVer,'STNE.Save.Groups savedata save success'}) end
        else
            if Debug then BASE:E({FileVer,'STNE.Save.Groups savedata save failed'}) end
        end
    end
end

-- End mission eventhandler for save data
if STNE.EventHandler == nil then STNE.EventHandler = {} end
if STNE.EventHandler.Save == nil then STNE.EventHandler.Save = {} end
STNE.EventHandler.Save.Groups = EVENTHANDLER:New()
STNE.EventHandler.Save.Groups:HandleEvent(world.event.S_EVENT_MISSION_END)
-- On mission end event
function STNE.EventHandler.Save.Groups:OnEventMissionEnd(EventData)
    SaveDataToFile()
end

-- Scheduler
if SaveTimer > 0 then
    if Debug then BASE:E({FileVer,Scheduler='enabled'}) end
    SCHEDULER:New(nil, function()
        SaveDataToFile()
    end, {}, SaveTimer, SaveTimer)
else
    if Debug then BASE:E({FileVer,Scheduler='disabled'}) end
end

-- EOF
env.info('FILE: '..FileVer..' END')
