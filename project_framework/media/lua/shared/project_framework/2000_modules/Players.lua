--! \page globalVars Global Variables
--! \section Players Players
--! ProjectFramework.Players\n
--! See Players for the module on players.\n\n
--! ProjectFramework.Players.List\n
--! A list of all instanced players in the game.

ProjectFramework = ProjectFramework or {}

--! \brief Characters module for ProjectFramework. Defines and interacts with PLAYER object.
--! \class Characters
ProjectFramework.Players = {}
ProjectFramework.Players.__index = ProjectFramework.Characters
ProjectFramework.Players.List = {}
ProjectFramework.Players.Roles = {
    User = "User",
    Operator = "Operator",
    Moderator = "Moderator",
    Admin = "Admin",
    Super_Admin = "Super Admin",
    Owner = "Owner"
}
ProjectFramework.Players = ProjectFramework.Foundation:NewModule(ProjectFramework.Players, "Players")

--! \brief Character class for ProjectFramework.
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
            whitelists = self.whitelists,
            characters = self.characters
        }

        if isClient() then
            self.isoPlayer:transmitModData()
        end
    end

    if isClient() then
        timer:Simple(5, function()
            sendClientCommand("PFW_PLY", "initialize", {self.isoPlayer:getUsername()})
        end)
    end

    return ProjectFramework.Players:Initialize(self.username, self)
end

function PLAYER:Destroy()
    if isClient() then
        sendClientCommand("PFW_PLY", "destroy", {self.isoPlayer:getUsername()})
    end

    self = nil
end

function PLAYER:InitializeDefaultFactionWhitelists()
    local factions = ProjectFramework.Factions.List

    for k, v in pairs(factions) do
        if v.isWhitelistedByDefault then
            self.whitelists[v.id] = true
        end
    end
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

function ProjectFramework.Players:New(username, isoPlayer)
    if not username or not isoPlayer then return false end

    local object = {
        username = username,
        isoPlayer = isoPlayer,
        steamID = isoPlayer:getSteamID(),
        role = ProjectFramework.Players.Roles.User,
        maxCharacters = ProjectFramework.Config.DefaultMaxCharacters,
        whitelists = {},
        characters = {}
    }

    setmetatable(object, PLAYER)

	return object
end

function ProjectFramework.Players:Initialize(username, player)
    self.List[username] = player

    return username
end

function ProjectFramework.Players:GetPlayerByID(username)
    if not username then return false end

    local player = ProjectFramework.Players.List[username]

    if player then
        return player
    end

    return false
end

function ProjectFramework.Players:GetCharacterByID(username, characterID)
    if not username or not characterID then return false end

    local player = ProjectFramework.Players:GetPlayerByID(username)

    if player then
        local character = player.characters[characterID]

        if character then
            return character
        end
    end

    return false
end

function ProjectFramework.Players:CreateCharacter(username, data)
    if not username or not data then return false end

    local player = self:GetPlayerByID(username)

    if player then
        local characters = player.isoPlayer:getModData()["PFW_PLY"].characters

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

function ProjectFramework.Players:SaveCharacter(username, characterID)

end

function ProjectFramework.Players:LoadCharacter(username, characterID)

end

function ProjectFramework.Players:DeleteCharacter(username, characterID)

end

if isClient() then
    function ProjectFramework.Players:OnGameStart()
        local cell = getWorld():getCell()
        local x = cell:getMaxX()
        local y = cell:getMaxY()
        local z = 0
        local isoPlayer = getPlayer()
        isoPlayer:setInvincible(true)
        isoPlayer:setInvisible(true)
        isoPlayer:setGhostMode(true)
        isoPlayer:setNoClip(true)
        isoPlayer:setX(x)
        isoPlayer:setY(y)
        isoPlayer:setZ(z)
	    isoPlayer:setLx(x)
	    isoPlayer:setLy(y)
	    isoPlayer:setLz(z)

        local ui = PFW_Introduction:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight(), getPlayer())
        ui:initialise()
        ui:addToUIManager()

        timer:Simple(ProjectFramework.Config.InitializationDuration, function()
            local player = ProjectFramework.Players:New(isoPlayer:getUsername(), isoPlayer)

            if player then
                player:Initialize()
                --sendClientCommand("PFW_PLY", "initialize", {player.isoPlayer:getUsername()})
            end
        end)
    end
end

if not isClient() then

    function ProjectFramework.Players.OnClientCommand(module, command, isoPlayer, args)
        if module == "PFW_PLY" then
            if command == "initialize" then
                local username = args[1]
                local player = ProjectFramework.Players:New(username, isoPlayer)

                if player then
                    player:Initialize()
                end
            elseif command == "destroy" then
                local username = args[1]
                local player = ProjectFramework.Players:GetPlayerByID(username)

                if player then
                    player:Destroy()
                end

                ProjectFramework.Characters.List[username] = nil
            elseif command == "update" then
                local username = args[1]
                local field = args[2]
                local newData = args[3]

                ProjectFramework.Players.List[username][field] = newData
            end
        end
    end
    Events.OnClientCommand.Add(ProjectFramework.Characters.OnClientCommand)
end
