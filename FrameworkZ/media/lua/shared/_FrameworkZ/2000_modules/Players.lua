--! \page globalVars Global Variables
--! \section Players Players
--! FrameworkZ.Players\n
--! See Players for the module on players.\n\n
--! FrameworkZ.Players.List\n
--! A list of all instanced players in the game.

local getPlayer = getPlayer
local isClient = isClient
local sendClientCommand = sendClientCommand

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
    local characterModData = self.isoPlayer:getModData()["PFW_PLY"] or nil

    if not characterModData then
        firstConnection = true

        self:InitializeDefaultFactionWhitelists()

        self.isoPlayer:getModData()["PFW_PLY"] = {
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
            sendClientCommand("PFW_PLY", "initialize", {self.isoPlayer:getUsername()})
        end)
    end

    return FrameworkZ.Players:Initialize(self.username, self)
end

function PLAYER:Destroy()
    if isClient() then
        sendClientCommand("PFW_PLY", "destroy", {self.isoPlayer:getUsername()})
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
    local characterModData = self.isoPlayer:getModData()["PFW_PLY"]

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

function PLAYER:GetStoredData()
    return self.isoPlayer:getModData()["PFW_PLY"]
end

function PLAYER:GetWhitelists()
    return self.whitelists
end

function PLAYER:SetWhitelisted(factionID, whitelisted)
    if not factionID then return false end

    self.whitelists[factionID] = whitelisted
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

function FrameworkZ.Players:GetCharacterByID(username, characterID)
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

    if player then
        local characters = player:GetStoredData().characters

        if characters then
            table.insert(characters, data)

            if isClient() then
                player.isoPlayer:transmitModData()
            end

            return true, #characters
        end
    end

    return false
end

function FrameworkZ.Players:SaveCharacter(username, characterID)

end

function FrameworkZ.Players:LoadCharacter(username, characterID)

end

function FrameworkZ.Players:DeleteCharacter(username, characterID)

end

if isClient() then
    function FrameworkZ.Players:InitializeClient()
        timer:Simple(FrameworkZ.Config.InitializationDuration, function()
            local isoPlayer = getPlayer()
            local player = FrameworkZ.Players:New(isoPlayer:getUsername(), isoPlayer)

            if player then
                player:Initialize()
                --sendClientCommand("PFW_PLY", "initialize", {player.isoPlayer:getUsername()})
            end
        end)
    end
end

if not isClient() then

    function FrameworkZ.Players.OnClientCommand(module, command, isoPlayer, args)
        if module == "PFW_PLY" then
            if command == "initialize" then
                local username = args[1]
                local player = FrameworkZ.Players:New(username, isoPlayer)

                if player then
                    player:Initialize()
                end
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
    Events.OnClientCommand.Add(FrameworkZ.Characters.OnClientCommand)
end

FrameworkZ.Foundation:RegisterModule(FrameworkZ.Players)
