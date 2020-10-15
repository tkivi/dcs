local Cfg = {
--#################################################################################################
--
--  SlotBlock
--
--  Slot block hook. Install to host/server ..Saved Games\DCS.openbeta\Scripts\Hooks
--
--  Usage:
--
--      MISSION EDITOR -> TRIGGERS -> ... -> DO SCRIPT ->
--
--      Enable/disable slot block: (1000 = enable, other = disable)
--          trigger.action.setUserFlag('stneSlotBlock', 1000)
--
--      Airplane/helicopter slots: (1000 = disable, other = enable)
--          trigger.action.setUserFlag('GroupName', 1000)
--
--      Tactical cmdr, JTAC/Operator, Observer, Game master slots: (flagname = virtual_slotname_sidenumber) (1000 = disable, other = enable)
--      Possible flag names:
--          virtual_artillery_commander_1
--          virtual_artillery_commander_2
--          virtual_forward_observer_1
--          virtual_forward_observer_2
--          virtual_observer_1
--          virtual_observer_2
--          virtual_instructor_1
--          virtual_instructor_2
--      Example:
--          trigger.action.setUserFlag('virtual_artillery_commander_1', 1000)
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    SlotBlockFlagValue = 1000,              -- Flag value to check
    -- UCID Tables
    ArtilleryCommanderUCID = {              -- Tactical cmdr slot override
    },
    ForwardObserverUCID = {                 -- JTAC/Operator slot override
    },
    ObserverUCID = {                        -- Observer slot override
    },
    InstructorUCID = {                      -- Game master slot override
    },
    AdminUCID = {                           -- Admin override = no restrictions
      --'dc82465h3257882276dht2b854g5ky37',
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.SlotBlock.GameGUI.lua'
local Version = '201015'
local FileVer = LuaFile..'/'..Version
net.log('FILE: '..FileVer..' START')

-- Prepare global variables
if STNE == nil then
    STNE = {}
end
if STNE.Hook == nil then
    STNE.Hook = {}
end
if STNE.Hook.SlotBlock == nil then
    STNE.Hook.SlotBlock = {}
end

-- Read config table
local SlotBlockFlagValue = Cfg.SlotBlockFlagValue
local ArtilleryCommanderUCID = Cfg.ArtilleryCommanderUCID
local ForwardObserverUCID = Cfg.ForwardObserverUCID
local ObserverUCID = Cfg.ObserverUCID
local InstructorUCID = Cfg.InstructorUCID
local AdminUCID = Cfg.AdminUCID

--- Get flag value for group
--- @param GroupName string
function STNE.Hook.SlotBlock.GetFlagValue(GroupName)
    local FlagValue, Success = net.dostring_in('server', 'return trigger.misc.getUserFlag(\"'..GroupName..'\")')
    if Success then
        return tonumber(FlagValue)
    else
        net.log(FlagValue)
        return 0
    end
end

--- Get group name
--- @param SlotID number
function STNE.Hook.SlotBlock.GetGroupName(SlotID)
    local GroupName = DCS.getUnitProperty(SlotID, DCS.UNIT_GROUPNAME)
    return GroupName
end

--- Send message to MP chat
--- @param ClientID number
function STNE.Hook.SlotBlock.SendMessage(ClientID)
    local Message = ''
    local SlotID = net.get_player_info(ClientID, 'slot')
    if SlotID ~= '' and SlotID ~= nil then
        local GroupName = STNE.Hook.SlotBlock.GetGroupName(SlotID)
        local UnitType = DCS.getUnitProperty(SlotID, DCS.UNIT_TYPE)
        Message = string.format('%s (%s) not available', GroupName, UnitType)
    else
        Message = 'Slot not available'
    end
    net.send_chat_to(Message, ClientID)
end

--- Force client back to spectator slot
--- @param ClientID number
function STNE.Hook.SlotBlock.ForceSpectator(ClientID)
    net.log(FileVer..', onPlayerChangeSlot, Slot is blocked, force client back to spectator')
    STNE.Hook.SlotBlock.SendMessage(ClientID)
    net.force_player_slot(ClientID, 0, '')
end

--- Check if client UCID is in config table
--- @param ClientUCID string
--- @param UnitType string
function STNE.Hook.SlotBlock.CheckUCID(ClientUCID, UnitType)
    -- Admin
    for _, UCID in pairs(AdminUCID) do
        if UCID == ClientUCID then
            net.log(FileVer..', onPlayerChangeSlot, ClientUCID found in Admin UCID table, override slot block')
            return true
        end
    end
    -- Other
    local TableUCID = {}
    local TableName = ''
    if UnitType == 'artillery_commander' then
        TableName = 'artillery_commander'
        TableUCID = ArtilleryCommanderUCID
    end
    if UnitType == 'forward_observer' then
        TableName = 'forward_observer'
        TableUCID = ForwardObserverUCID
    end
    if UnitType == 'observer' then
        TableName = 'observer'
        TableUCID = ObserverUCID
    end
    if UnitType == 'instructor' then
        TableName = 'instructor'
        TableUCID = InstructorUCID
    end
    for _, UCID in pairs(TableUCID) do
        if UCID == ClientUCID then
            net.log(FileVer..', onPlayerChangeSlot, ClientUCID found in UCID table: '..TableName..', override slot block')
            return true
        end
    end
    return false
end

--- Change slot event
--- @param ClientID number
function STNE.Hook.SlotBlock.onPlayerChangeSlot(ClientID)
    if  DCS.isServer() and DCS.isMultiplayer() and DCS.getModelTime() > 1 then
        local Enabled = STNE.Hook.SlotBlock.GetFlagValue('stneSlotBlock')
        if Enabled == SlotBlockFlagValue then
            local SlotID = net.get_player_info(ClientID, 'slot')
            if SlotID ~= '' and SlotID ~= nil then
                local ClientName = net.get_player_info(ClientID, 'name')
                local ClientUCID = net.get_player_info(ClientID, 'ucid')
                local UnitType = DCS.getUnitProperty(SlotID, DCS.UNIT_TYPE)
                local UnitSide = net.get_player_info(ClientID, 'side')
                local GroupName = STNE.Hook.SlotBlock.GetGroupName(SlotID)
                -- Virtual unit, change group name
                if GroupName == 'Virtual unit' and (UnitType == 'artillery_commander' or UnitType == 'forward_observer' or UnitType == 'observer' or UnitType == 'instructor') then
                    GroupName = 'virtual_'..UnitType..'_'..UnitSide
                end
                -- Get flag value
                local FlagValue = STNE.Hook.SlotBlock.GetFlagValue(GroupName)
                -- Debug
                net.log(FileVer..', onPlayerChangeSlot, Enabled=true, ClientName='..ClientName..', ClientUCID='..ClientUCID..', SlotID='..SlotID..', UnitType='..UnitType..', UnitSide='..UnitSide..', Flag='..GroupName..', Value='..FlagValue)
                -- Check UCID overrides
                if STNE.Hook.SlotBlock.CheckUCID(ClientUCID, UnitType) then
                    FlagValue = 0
                end
                -- Force to spectator slot
                if FlagValue == SlotBlockFlagValue then
                    STNE.Hook.SlotBlock.ForceSpectator(ClientID)
                end
            end
        else
            net.log(FileVer..', onPlayerChangeSlot, Enabled=false')
        end
    else
        net.log(FileVer..', onPlayerChangeSlot, not isServer or not isMultiplayer or getModelTime < 1')
    end
end

-- Hook
DCS.setUserCallbacks(STNE.Hook.SlotBlock)

-- EOF
net.log('FILE: '..FileVer..' END')