local Cfg = {
--#################################################################################################
--
--  RadioStation
--
--  Radio station broadcast for playing music or unit chatter.
--
--  https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/
--
--#################################################################################################
--##  CONFIGURATION START  ##  DO NOT EDIT ABOVE THIS LINE  #######################################
--#################################################################################################
    Debug = false,                                  -- Debug mode, true/false
    MuteFC3 = true,                                 -- Mute radio if any client flying FC3 plane, true/false
    Station = 'Radio Hellhole',                     -- UNIT or STATIC Radio station
    Frequency = 275.500,                            -- Frequency, in MHz
    Modulation = 'AM',                              -- Modulation, 'AM' or 'FM'
    Power = 1000,                                   -- Power, in W
    Randomize = true,                               -- Randomize sound order, true/false
    Loop = true,                                    -- Loop sounds, true/false
    MinDelay = 2,                                   -- (optional) Add min delay between sounds, seconds
    MaxDelay = 2,                                   -- (optional) Add max delay between sounds, seconds
    Folder = 'Sounds',                              -- Sounds folder, in .miz file
    Sounds = {                                      -- Sound files, in sounds folder
    --  {'FileName', Seconds},
        {'Buffalo Springfield - For What Its Worth.ogg', 157},
        {'Creedence Clearwater Revival Fortunate Son.ogg', 141},
        {'Paint it Black.ogg', 226},
        {'ACDC - Hells Bells.ogg', 311},
        {'All Along The Watchtower.ogg', 241},
        {'ZZ Top - La Grange.ogg', 227},
        {'ACDC - TNT.ogg', 214},
        {'ACDC - You Shook Me All Night Long.ogg', 210},
        {'Edwin Starr - War.ogg', 206},
        {'ACDC - Highway to Hell.ogg', 207},
        {'ACDC - Thunderstruck.ogg', 292},
        {'The_Rolling_Stones_-_Sympathy_For_The_Devil.ogg', 382},
        {'Dos Gringos - I Wish I Had A Gun Just Like The A-10.ogg', 126},
        {'Dos Gringos - Legend of Shaved Dogs Ass.ogg', 357},
        {'Jeremiah Weed - Dos Gringos.ogg', 198},
        {'Vanha rauta.ogg', 319},
        {'Im A Pilot - Dos Gringos.ogg', 311},
        {'Kenny Loggins - Danger Zone.ogg', 212},
        {'ZZ Top - Tush.ogg', 138},
    },
--#################################################################################################
--##  CONFIGURATION END  ##  DO NOT EDIT BELOW THIS LINE  #########################################
--#################################################################################################
}

-- File
local LuaFile = 'stne.RadioStation.lua'
local Version = '201221'
local FileVer = LuaFile..'/'..Version
env.info('FILE: '..FileVer..' START')

-- Override configuration
if STNE_Config_RadioStation then
    for key, value in pairs(STNE_Config_RadioStation) do
        Cfg[key] = value
    end
end

-- Read config table
BASE:E({FileVer,Cfg=Cfg})
local Debug = Cfg.Debug
local MuteFC3 = Cfg.MuteFC3
local Station = Cfg.Station
local Frequency = Cfg.Frequency
local Modulation = Cfg.Modulation
local Power = Cfg.Power
local Randomize = Cfg.Randomize
local Loop = Cfg.Loop
local MinDelay = Cfg.MinDelay or 0
local MaxDelay = Cfg.MaxDelay or MinDelay
local Folder = Cfg.Folder
local Sounds = Cfg.Sounds

-- Local variables
local RandomTable = {}
local NextSoundID = 1

-- Set modulation
if Modulation == 'FM' then
    Modulation = radio.modulation.FM
else
    Modulation = radio.modulation.AM
end

-- Modified MOOSE BEACON:RadioBeacon function for radio broadcast
function BEACON:STNERadioStation(FileName, Frequency, Modulation, Power, BeaconDuration)
    Frequency = Frequency * 1000000 -- Conversion to Hz
    trigger.action.radioTransmission(FileName, self.Positionable:GetPositionVec3(), Modulation, false, Frequency, Power, tostring(self.ID))
    if BeaconDuration then -- Schedule the stop of the BEACON if asked by the MD
        SCHEDULER:New( nil,
        function()
            self:StopRadioBeacon()
        end, {}, BeaconDuration)
    end
end

-- Radio station object
local RadioStationObj = nil
if STATIC:FindByName(Station, false) then
    RadioStationObj = STATIC:FindByName(Station, false)
elseif UNIT:FindByName(Station) then
    RadioStationObj = UNIT:FindByName(Station)
end
local RadioStation = nil
if RadioStationObj ~= nil and RadioStationObj:IsAlive() then
    RadioStation = RadioStationObj:GetBeacon()
    RadioStationObj:HandleEvent(EVENTS.Dead, RadioStationObj.OnEventDead)
    function RadioStationObj:OnEventDead(EventData)
        if Debug then BASE:E({FileVer,'OnEventDead, RadioStation: '..Station}) end
        RadioStation:StopRadioBeacon()
    end
else
    if Debug then BASE:E({FileVer,'RadioStation: '..Station..' is dead or nil, skip start'}) end
end

--- Broadcast sound
--- @param SoundTable table
local function Broadcast(SoundTable)
    local Sound = SoundTable[1] or ''
    local Duration = SoundTable[2] or 10
    local FSound = Sound
    if Folder ~= nil then
        FSound = Folder..'/'..Sound
    end
    RadioStation:STNERadioStation(FSound, Frequency, Modulation, Power, Duration)
    if Debug then BASE:E({FileVer,'Broadcast',Station=Station,Frequency=Frequency,Power=Power,Duration=Duration,Sound=FSound}) end
end

--- Populate random sound table with random sound order
local function PopulateRandomTable()
    if Debug then BASE:E({FileVer,'PopulateRandomTable'}) end
    for _, RandomSound in UTILS.rpairs(Sounds) do
        table.insert(RandomTable, RandomSound)
    end
end
PopulateRandomTable()

--- Get next random sound
local function GetNextRandom()
    if #RandomTable == 0 and Loop == true then
        PopulateRandomTable()
    end
    if #RandomTable > 0 then
        local Random = math.random(1, #RandomTable)
        local SoundTable = RandomTable[Random]
        if Debug then BASE:E({FileVer,'GetNextRandom',Number=Random,Sound=SoundTable[1],RandomTable=#RandomTable}) end
        table.remove(RandomTable, Random)
        return SoundTable
    else
        return nil
    end
end

--- Is client plane type FC3 plane
--- @param Client table
local function IsPlaneFC3(Client)
    local PlaneIsFC3 = false
    if Client ~= nil and Client:IsAlive() and Client:GetPlayerName() ~= nil then
        local TypeName = Client:GetTypeName()
        local FC3PlaneTypes = {
            'Su-25T',   -- Free plane (not actual FC3)
            'J-11A',    -- China asset
            'MiG-29A',
            'MiG-29S',
            'Su-25',
            'Su-27',
            'Su-33',
            'A-10A',
            'F-15C',
        }
        for _, FC3PlaneType in pairs(FC3PlaneTypes) do
            if TypeName == FC3PlaneType then
                PlaneIsFC3 = true
            end
        end
        if Debug then BASE:E({FileVer,IsPlaneFC3=PlaneIsFC3,Client=Client:GetPlayerName(),Type=TypeName}) end
    end
    return PlaneIsFC3
end

--- Mute FC3 radio
--- @param Client table
local function MuteFC3Radio(Client)
    local PlaneIsFC3 = IsPlaneFC3(Client)
    if Debug then BASE:E({FileVer,MuteFC3Enabled=MuteFC3,MuteRadio=PlaneIsFC3}) end
    if MuteFC3 == true and PlaneIsFC3 == true then
        RadioStation:StopRadioBeacon()
    end
end

-- Clients set
local Clients_Set = SET_CLIENT:New()
Clients_Set:FilterStart()

-- Client joins slot event
if MuteFC3 == true then
    -- Eventhandler
    if STNE == nil then STNE = {} end
    if STNE.EventHandler == nil then STNE.EventHandler = {} end
    if STNE.EventHandler.RadioStation == nil then STNE.EventHandler.RadioStation = {} end
    STNE.EventHandler.RadioStation = EVENTHANDLER:New()
    STNE.EventHandler.RadioStation:HandleEvent(world.event.S_EVENT_BIRTH)
    -- OnEventBirth event
    function STNE.EventHandler.RadioStation:OnEventBirth(EventData)
        if Debug then BASE:E({FileVer,'OnEventBirth'}) end
        if EventData.IniUnit ~= nil and EventData.IniUnit:IsPlayer() then
            MuteFC3Radio(EventData.IniUnit)
        end
    end
end

--- Is some of clients flying with FC3 plane
local function IsSomePlaneFC3()
    local SomePlaneFC3 = false
    Clients_Set:ForEachClient(
        function(Client)
            if Client ~= nil and Client:IsAlive() and Client:GetPlayerName() ~= nil then
                if IsPlaneFC3(Client) == true then
                    SomePlaneFC3 = true
                end
            end
        end
    )
    if Debug then BASE:E({FileVer,IsSomePlaneFC3=SomePlaneFC3}) end
    return SomePlaneFC3
end

--- Radio broadcast scheduler
local function BroadcastScheduler()
    if RadioStationObj ~= nil and RadioStationObj:IsAlive() then
        local SoundTable = nil
        local SkipBroadcast = false
        if MuteFC3 == true then
            SkipBroadcast = IsSomePlaneFC3()
        end
        if SkipBroadcast == true then
            if Debug then BASE:E({FileVer,SkipBroadcast=SkipBroadcast,MuteFC3=MuteFC3,Duration='30'}) end
            SCHEDULER:New(nil, function()
                BroadcastScheduler()
            end, {}, 30)
        else
            if Randomize == true then
                SoundTable = GetNextRandom()
            else
                if NextSoundID > #Sounds and Loop == true then
                    NextSoundID = 1
                end
                SoundTable = Sounds[NextSoundID]
                NextSoundID = NextSoundID + 1
            end
            if SoundTable ~= nil then
                Broadcast(SoundTable)
                local AddDuration = math.random(MinDelay, MaxDelay)
                local Duration = SoundTable[2] + AddDuration
                SCHEDULER:New(nil, function()
                    BroadcastScheduler()
                end, {}, Duration)
                if Debug then BASE:E({FileVer,BroadcastScheduler=Station,Duration=Duration,DurationBetweenSounds=AddDuration,Randomize=Randomize,Loop=Loop}) end
            else
                if Debug then BASE:E({FileVer,'RadioStation: '..Station..' SoundTable is nil, exit scheduler'}) end
            end
        end
    else
        if Debug then BASE:E({FileVer,'RadioStation: '..Station..' is dead or nil, exit scheduler'}) end
    end
end
SCHEDULER:New(nil, function()
    BroadcastScheduler()
end, {}, 10)

-- EOF
env.info('FILE: '..FileVer..' END')
