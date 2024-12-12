--! \page globalVars Global Variables
--! \section Players Players
--! FrameworkZ.Players\n
--! See Players for the module on players.\n\n
--! FrameworkZ.Players.List\n
--! A list of all instanced players in the game.

local getPlayer = getPlayer
local isClient = isClient

FrameworkZ = FrameworkZ or {}

--! \brief Characters module for FrameworkZ. Defines and interacts with PLAYER object.
--! \class Characters
FrameworkZ.Players = {}
FrameworkZ.Players.List = {}
FrameworkZ.Players.Roles = {
    User = "User",
    Operator = "Operator",
    Moderator = "Moderator",
    Admin = "Admin",
    Super_Admin = "Super Admin",
    Owner = "Owner"
}
FrameworkZ.Players = FrameworkZ.Foundation:NewModule(FrameworkZ.Players, "Players")

--! \brief Character class for FrameworkZ.
--! \class PLAYER
local PLAYER = {}
PLAYER.__index = PLAYER

function PLAYER:Initialize()
    if not self.isoPlayer then return end

    local firstConnection = false
    local characterModData = self.isoPlayer:getModData()["FZ_PLY"] or nil

    if not characterModData then
        firstConnection = true

        self:InitializeDefaultFactionWhitelists()

        self.isoPlayer:getModData()["FZ_PLY"] = {
            username = self.username,
            steamID = self.steamID,
            role = self.role,
            maxCharacters = self.maxCharacters,
            previousCharacter = self.previousCharacter,
            whitelists = self.whitelists,
            characters = self.characters
        }

        if isClient() then
            self.isoPlayer:transmitModData()
        end
    end

    self:ValidatePlayerData()

    if isClient() then
        timer:Simple(5, function()
            sendClientCommand("FZ_PLY", "initialize", {self.isoPlayer:getUsername()})
        end)
    end

    return FrameworkZ.Players:Initialize(self.username, self)
end

function PLAYER:Destroy()
    if isClient() then
        sendClientCommand("FZ_PLY", "destroy", {self.isoPlayer:getUsername()})
    end

    self = nil
end

function PLAYER:InitializeDefaultFactionWhitelists()
    local factions = FrameworkZ.Factions.List

    for k, v in pairs(factions) do
        if v.isWhitelistedByDefault then
            self.whitelists[v.id] = true
        end
    end
end

function PLAYER:ValidatePlayerData()
    local characterModData = self.isoPlayer:getModData()["FZ_PLY"]

    if not characterModData then return false end

    local initializedNewData = false

    if not characterModData.username then
        initializedNewData = true
        characterModData.username = self.username or getPlayer():getUsername()
    end

    if not characterModData.steamID then
        initializedNewData = true
        characterModData.steamID = self.steamID or getPlayer():getSteamID()
    end

    if not characterModData.role then
        initializedNewData = true
        characterModData.role = self.role or FrameworkZ.Players.Roles.User
    end

    if not characterModData.maxCharacters then
        initializedNewData = true
        characterModData.maxCharacters = self.maxCharacters or FrameworkZ.Config.DefaultMaxCharacters
    end

    if not characterModData.previousCharacter then
        initializedNewData = true
        characterModData.previousCharacter = self.previousCharacter or nil
    end

    if not characterModData.whitelists then
        self:InitializeDefaultFactionWhitelists()
        initializedNewData = true
        characterModData.whitelists = self.whitelists
    end

    if not characterModData.characters then
        initializedNewData = true
        characterModData.characters = self.characters or {}
    end

    if isClient() then
        self.isoPlayer:transmitModData()
    end

    self.username = characterModData.username
    self.steamID = characterModData.steamID
    self.role = characterModData.role
    self.maxCharacters = characterModData.maxCharacters
    self.previousCharacter = characterModData.previousCharacter
    self.whitelists = characterModData.whitelists
    self.characters = characterModData.characters

    return initializedNewData
end

--! \brief Gets the stored player mod data table. Used internally. Do not use this unless you know what you are doing. Updating data on the mod data will cause inconsistencies between the mod data and the FrameworkZ player object.
--! \return \table The stored player mod data table.
function PLAYER:GetStoredData()
    return self.isoPlayer:getModData()["FZ_PLY"]
end

function PLAYER:GetWhitelists()
    return self.whitelists
end

function PLAYER:SetWhitelisted(factionID, whitelisted)
    if not factionID then return false end

    self.whitelists[factionID] = whitelisted
    self:GetStoredData().whitelists[factionID] = whitelisted

    return true
end

function PLAYER:IsWhitelisted(factionID)
    if not factionID then return false end

    return self.whitelists[factionID] or false
end

--! \brief Plays a sound for the player that only they can hear.
--! \param soundName \string The name of the sound to play.
--! \return \integer The sound's ID.
function PLAYER:PlayLocalSound(soundName)
    return self.isoPlayer:getEmitter():playSoundImpl(soundName, nil)
end

--! \brief Stops a sound for the player.
--! \param soundNameOrID \mixed of \string or \integer The name or ID of the sound to stop.
function PLAYER:StopSound(soundNameOrID)
    if type(soundNameOrID) == "number" then
        self.isoPlayer:getEmitter():stopSound(soundNameOrID)
    elseif type(soundNameOrID) == "string" then
        self.isoPlayer:getEmitter():stopSoundByName(soundNameOrID)
    end
end

function FrameworkZ.Players:New(username, isoPlayer)
    if not username or not isoPlayer then return false end

    local object = {
        username = username,
        isoPlayer = isoPlayer,
        steamID = isoPlayer:getSteamID(),
        role = FrameworkZ.Players.Roles.User,
        maxCharacters = FrameworkZ.Config.DefaultMaxCharacters,
        previousCharacter = nil,
        whitelists = {},
        characters = {}
    }

    setmetatable(object, PLAYER)

	return object
end

function FrameworkZ.Players:Initialize(username, player)
    FrameworkZ.Players.List[username] = player

    return username
end

function FrameworkZ.Players:GetPlayerByID(username)
    if not username then return false end

    local player = FrameworkZ.Players.List[username]

    if player then
        return player
    end

    return false
end

--! \brief Gets saved character data by their ID.
--! \param username \string The username of the player.
--! \param characterID \integer The ID of the character.
--! \return \table or \boolean The character data or false if the data failed to be retrieved.
function FrameworkZ.Players:GetCharacterDataByID(username, characterID)
    if not username or not characterID then return false end

    local player = FrameworkZ.Players:GetPlayerByID(username)

    if player then
        local character = player.characters[characterID]

        if character then
            return character
        end
    end

    return false
end

function FrameworkZ.Players:CreateCharacter(username, data)
    if not username or not data then return false end

    local player = self:GetPlayerByID(username)

    if player and player.characters then
        data.META_ID = #player.characters + 1
        data.META_FIRST_LOAD = true

        -- Pause character save interval to prevent data inconsistencies (if created character while character is currently loaded)
        if timer:Exists("FZ_CharacterSaveInterval") then
            timer:Pause("FZ_CharacterSaveInterval")
        end

        table.insert(player.characters, data)
        player:GetStoredData().characters = player.characters

        if isClient() then
            player.isoPlayer:transmitModData()
        end

        if timer:Exists("FZ_CharacterSaveInterval") then
            timer:Simple(10, function()
                timer:Resume("FZ_CharacterSaveInterval")
            end)
        end

        return true, #player.characters
    end

    return false
end

function FrameworkZ.Players:SaveCharacter(username, character)
    local player = FrameworkZ.Players:GetPlayerByID(username)

    if not player or not character then return false end

    local isoPlayer = player.isoPlayer
    local survivorDescriptor = isoPlayer:getDescriptor()

    character.INVENTORY_ITEMS = {}
    local inventory = isoPlayer:getInventory():getItems()
    for i = 0, inventory:size() - 1 do
        table.insert(character.INVENTORY_ITEMS, {id = inventory:get(i):getFullType()})
    end

    character.EQUIPMENT_SLOT_HEAD = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_HEAD) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_HEAD):getFullType()} or nil
    character.EQUIPMENT_SLOT_FACE = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_FACE) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_FACE):getFullType()} or nil
    character.EQUIPMENT_SLOT_EARS = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_EARS) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_EARS):getFullType()} or nil
    character.EQUIPMENT_SLOT_BACKPACK = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_BACKPACK) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_BACKPACK):getFullType()} or nil
    character.EQUIPMENT_SLOT_GLOVES = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_GLOVES) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_GLOVES):getFullType()} or nil
    character.EQUIPMENT_SLOT_UNDERSHIRT = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_UNDERSHIRT) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_UNDERSHIRT):getFullType()} or nil
    character.EQUIPMENT_SLOT_OVERSHIRT = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_OVERSHIRT) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_OVERSHIRT):getFullType()} or nil
    character.EQUIPMENT_SLOT_VEST = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_VEST) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_VEST):getFullType()} or nil
    character.EQUIPMENT_SLOT_BELT = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_BELT) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_BELT):getFullType()} or nil
    character.EQUIPMENT_SLOT_PANTS = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_PANTS) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_PANTS):getFullType()} or nil
    character.EQUIPMENT_SLOT_SOCKS = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_SOCKS) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_SOCKS):getFullType()} or nil
    character.EQUIPMENT_SLOT_SHOES = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_SHOES) and {id = survivorDescriptor:getWornItem(EQUIPMENT_SLOT_SHOES):getFullType()} or nil

    -- Save character position/direction angle
    character.POSITION_X = isoPlayer:getX()
    character.POSITION_Y = isoPlayer:getY()
    character.POSITION_Z = isoPlayer:getZ()
    character.DIRECTION_ANGLE = isoPlayer:getDirectionAngle()

    local getStats = isoPlayer:getStats()
    character.STAT_HUNGER = getStats:getHunger()
    character.STAT_THIRST = getStats:getThirst()
    character.STAT_FATIGUE = getStats:getFatigue()
    character.STAT_STRESS = getStats:getStress()
    character.STAT_PAIN = getStats:getPain()
    character.STAT_PANIC = getStats:getPanic()
    character.STAT_BOREDOM = getStats:getBoredom()
    --character.STAT_UNHAPPINESS = getStats:getUnhappyness()
    character.STAT_DRUNKENNESS = getStats:getDrunkenness()
    character.STAT_ENDURANCE = getStats:getEndurance()
    --character.STAT_TIREDNESS = getStats:getTiredness()

    --[[
    modData.status.health = character:getBodyDamage():getOverallBodyHealth()
    modData.status.injuries = character:getBodyDamage():getInjurySeverity()
    modData.status.hyperthermia = character:getBodyDamage():getTemperature()
    modData.status.hypothermia = character:getBodyDamage():getColdStrength()
    modData.status.wetness = character:getBodyDamage():getWetness()
    modData.status.hasCold = character:getBodyDamage():HasACold()
    modData.status.sick = character:getBodyDamage():getSicknessLevel()
    --]]

    if isClient() then
        isoPlayer:transmitModData()
    end

    return true
end

function FrameworkZ.Players:SaveCharacterByID(username, characterID)

end

--[[
    Steps:
        1. Load equipment/items
        2. Teleport
        3. Ungod
        4. Apply damage/wounds/moodles (if applicable)
        5. Make visible
        6. Unmute
        7. Save
        8. Post load
        9. Return true
--]]
function FrameworkZ.Players:LoadCharacter(username, character, survivorDescriptor)
    local player = FrameworkZ.Players:GetPlayerByID(username)

    if not player or not character then return false end

    local isoPlayer = player.isoPlayer

    if character.META_FIRST_LOAD == true then
        character.META_FIRST_LOAD = false

        isoPlayer:setX(FrameworkZ.Config.SpawnX)
        isoPlayer:setY(FrameworkZ.Config.SpawnY)
        isoPlayer:setZ(FrameworkZ.Config.SpawnZ)
        isoPlayer:setLx(FrameworkZ.Config.SpawnX)
        isoPlayer:setLy(FrameworkZ.Config.SpawnY)
        isoPlayer:setLz(FrameworkZ.Config.SpawnZ)
    else
        isoPlayer:setX(character.POSITION_X)
        isoPlayer:setY(character.POSITION_Y)
        isoPlayer:setZ(character.POSITION_Z)
        isoPlayer:setLx(character.POSITION_X)
        isoPlayer:setLy(character.POSITION_Y)
        isoPlayer:setLz(character.POSITION_Z)
        isoPlayer:setDirectionAngle(character.DIRECTION_ANGLE)
    end

    isoPlayer:clearWornItems()
    isoPlayer:getInventory():clear()

    for k, v in pairs(character) do
        if string.match(k, "EQUIPMENT_SLOT_") then
            if v then
                local item = isoPlayer:getInventory():AddItem(v)
                isoPlayer:setWornItem(item:getBodyLocation(), item)
            end
        end
    end

    local isFemale = survivorDescriptor:isFemale()
    isoPlayer:setFemale(isFemale)
    isoPlayer:getDescriptor():setFemale(isFemale)
    isoPlayer:getHumanVisual():clear()
    isoPlayer:getHumanVisual():copyFrom(survivorDescriptor:getHumanVisual())
    isoPlayer:resetModel()

    isoPlayer:setGodMod(false)
    isoPlayer:setInvincible(false)

    -- Apply damage/wounds/moodles

    isoPlayer:setInvisible(false)
    isoPlayer:setGhostMode(false)
    isoPlayer:setNoClip(false)

    if VoiceManager:playerGetMute(username) then
        VoiceManager:playerSetMute(username)
    end

    if not FrameworkZ.Characters:PostLoad(isoPlayer, character.META_ID) then return false end
    if not self:SaveCharacter(username, character) then return false end

    return true
end

function FrameworkZ.Players:LoadCharacterByID(username, characterID)

end

function FrameworkZ.Players:DeleteCharacter(username, character)

end

function FrameworkZ.Players:DeleteCharacterByID(username, characterID)

end

if isClient() then
    function FrameworkZ.Players:InitializeClient(isoPlayer)
        timer:Simple(FrameworkZ.Config.InitializationDuration, function()
            local player = FrameworkZ.Players:New(isoPlayer:getUsername(), isoPlayer)

            if player then
                player:Initialize()
                --sendClientCommand("FZ_PLY", "initialize", {player.isoPlayer:getUsername()})
            end
        end)
    end
end

if not isClient() then
    function FrameworkZ.Players.OnClientCommand(module, command, isoPlayer, args)
        if module == "FZ_PLY" then
            if command == "initialize" then
                local username = args[1]
                local player = FrameworkZ.Players:New(username, isoPlayer)

                if player then
                    player:Initialize()
                end
            elseif command == "remove_limbo_protection" then
                isoPlayer:setGodMod(false)
                isoPlayer:setInvincible(false)
                isoPlayer:setInvisible(false)
                isoPlayer:setGhostMode(false)
                isoPlayer:setNoClip(false)
                sendPlayerExtraInfo(isoPlayer)
            elseif command == "on_first_load" then
                isoPlayer:setX(FrameworkZ.Config.SpawnX)
                isoPlayer:setY(FrameworkZ.Config.SpawnY)
                isoPlayer:setZ(FrameworkZ.Config.SpawnZ)
                isoPlayer:setLx(FrameworkZ.Config.SpawnX)
                isoPlayer:setLy(FrameworkZ.Config.SpawnY)
                isoPlayer:setLz(FrameworkZ.Config.SpawnZ)
            elseif command == "destroy" then
                local username = args[1]
                local player = FrameworkZ.Players:GetPlayerByID(username)

                if player then
                    player:Destroy()
                end

                FrameworkZ.Characters.List[username] = nil
            elseif command == "update" then
                local username = args[1]
                local field = args[2]
                local newData = args[3]

                FrameworkZ.Players.List[username][field] = newData
            end
        end
    end
    Events.OnClientCommand.Add(FrameworkZ.Players.OnClientCommand)
end

FrameworkZ.Foundation:RegisterModule(FrameworkZ.Players)
