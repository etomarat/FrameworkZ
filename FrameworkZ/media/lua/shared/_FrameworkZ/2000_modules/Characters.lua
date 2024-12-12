--! \page globalVars Global Variables
--! \section Characters Characters
--! FrameworkZ.Characters\n
--! See Characters for the module on characters.\n\n
--! FrameworkZ.Characters.List\n
--! A list of all instanced characters in the game.

FrameworkZ = FrameworkZ or {}

SKIN_COLOR_PALE = 0
SKIN_COLOR_WHITE = 1
SKIN_COLOR_TANNED = 2
SKIN_COLOR_BROWN = 3
SKIN_COLOR_DARK_BROWN = 4

HAIR_COLOR_BLACK_R = 0
HAIR_COLOR_BLACK_G = 0
HAIR_COLOR_BLACK_B = 0
HAIR_COLOR_BLONDE_R = 0.9
HAIR_COLOR_BLONDE_G = 0.9
HAIR_COLOR_BLONDE_B = 0.6
HAIR_COLOR_BROWN_R = 0.3
HAIR_COLOR_BROWN_G = 0.2
HAIR_COLOR_BROWN_B = 0.2
HAIR_COLOR_GRAY_R = 0.5
HAIR_COLOR_GRAY_G = 0.5
HAIR_COLOR_GRAY_B = 0.5
HAIR_COLOR_RED_R = 0.9
HAIR_COLOR_RED_G = 0.4
HAIR_COLOR_RED_B = 0.1
HAIR_COLOR_WHITE_R = 1
HAIR_COLOR_WHITE_G = 1
HAIR_COLOR_WHITE_B = 1

EQUIPMENT_SLOT_HEAD = "Hat"
EQUIPMENT_SLOT_FACE = "Mask"
EQUIPMENT_SLOT_EARS = "Ears"
EQUIPMENT_SLOT_BACKPACK = "Back"
EQUIPMENT_SLOT_GLOVES = "Hands"
EQUIPMENT_SLOT_UNDERSHIRT = "Tshirt"
EQUIPMENT_SLOT_OVERSHIRT = "Shirt"
EQUIPMENT_SLOT_VEST = "TorsoExtraVest"
EQUIPMENT_SLOT_BELT = "Belt"
EQUIPMENT_SLOT_PANTS = "Pants"
EQUIPMENT_SLOT_SOCKS = "Socks"
EQUIPMENT_SLOT_SHOES = "Shoes"

--! \brief Characters module for FrameworkZ. Defines and interacts with CHARACTER object.
--! \class Characters
FrameworkZ.Characters = {}
FrameworkZ.Characters.__index = FrameworkZ.Characters
FrameworkZ.Characters.List = {}
FrameworkZ.Characters.EquipmentSlots = {
    EQUIPMENT_SLOT_HEAD,
    EQUIPMENT_SLOT_FACE,
    EQUIPMENT_SLOT_EARS,
    EQUIPMENT_SLOT_BACKPACK,
    EQUIPMENT_SLOT_GLOVES,
    EQUIPMENT_SLOT_UNDERSHIRT,
    EQUIPMENT_SLOT_OVERSHIRT,
    EQUIPMENT_SLOT_VEST,
    EQUIPMENT_SLOT_BELT,
    EQUIPMENT_SLOT_PANTS,
    EQUIPMENT_SLOT_SOCKS,
    EQUIPMENT_SLOT_SHOES
}
FrameworkZ.Characters = FrameworkZ.Foundation:NewModule(FrameworkZ.Characters, "Characters")

--! \brief Character class for FrameworkZ.
--! \class CHARACTER
local CHARACTER = {}
CHARACTER.__index = CHARACTER

--! \brief Initialize a character.
--! \return \string username
function CHARACTER:Initialize()
	if not self.isoPlayer then return end

    local firstConnection = false
    local characterModData = self.isoPlayer:getModData()["PFW_CHAR"] or nil

    local inventory = FrameworkZ.Inventories:New(self.isoPlayer:getUsername())
    self.inventoryID = inventory:Initialize()
    self.inventory = inventory

    if not characterModData then
        firstConnection = true

        self.isoPlayer:getModData()["PFW_CHAR"] = {
            id = self.id or -1,
            name = self.name or "Unknown",
            description = self.description or "No description available.",
            faction = self.faction or FACTION_CITIZEN,
            age = self.age or 20,
            height = self.height or 70,
            eyeColor = self.eyeColor or "Brown",
            hairColor = self.hairColor or "Brown",
            skinColor = self.skinColor or "White",
            physique = self.physique or "Average",
            weight = self.weight or "125",
            inventory = self.inventory.items or {},
            upgrades = {}
        }

        if isClient() then
            self.isoPlayer:transmitModData()
        end
    end

    if firstConnection then
        self:InitializeDefaultItems()
    end

    self:ValidateCharacterData()

    if isClient() then
        timer:Simple(5, function()
            sendClientCommand("PFW_CHAR", "initialize", {self.isoPlayer:getUsername()})
        end)
    end

    return FrameworkZ.Characters:Initialize(self.username, self)
end

--! \brief Destroy a character. This will remove the character from the list of characters and is usually called after a player has disconnected.
function CHARACTER:Destroy()
    if isClient() then
        sendClientCommand("PFW_CHAR", "destroy", {self.isoPlayer:getUsername()})
    end
    
    self.isoPlayer = nil
end

--! \brief Initialize the default items for a character based on their faction. Called when PFW_CHAR mod data is first created.
function CHARACTER:InitializeDefaultItems()
    local faction = FrameworkZ.Factions:GetFactionByID(self.faction)

    if faction then
        for k, v in pairs(faction.defaultItems) do
           self:GiveItems(k, v)
        end
    end
end

--! \brief Validate the character's data.
--! \return \boolean Whether or not any of the character's new data was initialized.
function CHARACTER:ValidateCharacterData()
    local characterModData = self.isoPlayer:getModData()["PFW_CHAR"]

    if not characterModData then return false end

    local initializedNewData = false

    if not characterModData.name then
        initializedNewData = true
        characterModData.name = self.name or "Unknown"
    end

    if not characterModData.description then
        initializedNewData = true
        characterModData.description = self.description or "No description available."
    end

    if not characterModData.faction then
        initializedNewData = true
        characterModData.faction = self.faction or FACTION_CITIZEN
    end

    if not characterModData.age then
        initializedNewData = true
        characterModData.age = self.age or 20
    end

    if not characterModData.heightFeet then
        initializedNewData = true
        characterModData.heightFeet = self.heightFeet or 5
    end

    if not characterModData.heightInches then
        initializedNewData = true
        characterModData.heightInches = self.heightInches or 10
    end

    if not characterModData.eyeColor then
        initializedNewData = true
        characterModData.eyeColor = self.eyeColor or "Brown"
    end

    if not characterModData.hairColor then
        initializedNewData = true
        characterModData.hairColor = self.hairColor or "Brown"
    end

    if not characterModData.physique then
        initializedNewData = true
        characterModData.physique = self.physique or "Average"
    end

    if not characterModData.weight then
        initializedNewData = true
        characterModData.weight = self.weight or "125"
    end

    if not characterModData.inventory then
        initializedNewData = true
        characterModData.inventory = self.inventory.items or {}
    end

    if not characterModData.upgrades then
        initializedNewData = true
        characterModData.upgrades = {}
    end

    if isClient() then
        self.isoPlayer:transmitModData()
    end

    self.name = characterModData.name
    self.description = characterModData.description
    self.faction = characterModData.faction
    self.age = characterModData.age
    self.heightFeet = characterModData.heightFeet
    self.heightInches = characterModData.heightInches
    self.eyeColor = characterModData.eyeColor
    self.hairColor = characterModData.hairColor
    self.physique = characterModData.physique
    self.upgrades = characterModData.upgrades

    return initializedNewData
end

--! \brief Set the age of the character.
--! \param age \integer The age of the character.
function CHARACTER:SetAge(age)
    self.age = age
    self.isoPlayer:getModData()["PFW_CHAR"].age = age
    self.isoPlayer:transmitModData()

    if isClient() then
        sendClientCommand("PFW_CHAR", "update", {self.isoPlayer:getUsername(), "age", age})
    end
end

--! \brief Set the description of the character.
--! \param description \string The description of the character's appearance.
function CHARACTER:SetDescription(description)
    self.description = description
    self.isoPlayer:getModData()["PFW_CHAR"].description = description
    self.isoPlayer:transmitModData()
    
    if isClient() then
        sendClientCommand("PFW_CHAR", "update", {self.isoPlayer:getUsername(), "description", description})
    end
end

--! \brief Set the faction of the character.
--! \param faction \string The ID of the faction to set on the character.
function CHARACTER:SetFaction(faction)
    self.faction = faction
    self.isoPlayer:getModData()["PFW_CHAR"].faction = faction
    self.isoPlayer:transmitModData()
    
    if isClient() then
        sendClientCommand("PFW_CHAR", "update", {self.isoPlayer:getUsername(), "faction", faction})
    end
end

function CHARACTER:GetName(name)
    return self.name
end

--! \brief Set the name of the character.
--! \param name \string The new name for the character.
function CHARACTER:SetName(name)
    self.name = name
    self.isoPlayer:getModData()["PFW_CHAR"].name = name
    self.isoPlayer:transmitModData()
    
    if isClient() then
        sendClientCommand("PFW_CHAR", "update", {self.isoPlayer:getUsername(), "name", name})
    end
end

--! \brief Get the character's inventory.
--! \return \table The character's inventory object.
function CHARACTER:GetInventory()
    return FrameworkZ.Inventories:GetInventoryByID(self.inventoryID)
end

--! \brief Give a character items by the specified amount.
--! \param itemID \string The ID of the item to give.
--! \param amount \integer The amount of the item to give.
function CHARACTER:GiveItems(uniqueID, amount)
    for i = 1, amount do
        self:GiveItem(uniqueID)
    end
end

--! \brief Give a character an item.
--! \param uniqueID \string The ID of the item to give.
--! \return \boolean Whether or not the item was successfully given.
function CHARACTER:GiveItem(uniqueID)
    local inventory = self:GetInventory()
    local item = FrameworkZ.Items:GetItemByID(uniqueID)

    if inventory and item then
        local worldItem = self.isoPlayer:getInventory():AddItem(InventoryItemFactory.CreateItem(item.itemID))
        local instanceID = FrameworkZ.Items:AddInstance(item.itemID)
        local itemInstance = FrameworkZ.Items:InitializeInstance(instanceID, item, self.isoPlayer, worldItem)
        local itemData = {
            uniqueID = itemInstance.uniqueID,
            itemID = worldItem:getFullType(),
            instanceID = instanceID,
            owner = self.isoPlayer:getUsername(),
            name = itemInstance.name or "Unknown",
            description = itemInstance.description or "No description available.",
            category = itemInstance.category or "Uncategorized",
            shouldConsume = itemInstance.shouldConsume or false,
            weight = itemInstance.weight or 1,
            useAction = itemInstance.useAction or nil,
            useTime = itemInstance.useTime or nil
        }

        worldItem:getModData()["PFW_ITM"] = itemData
        worldItem:setName(itemData.name)
        worldItem:setActualWeight(itemData.weight)
        inventory:AddItem(itemInstance)

        if isClient() then
            --worldItem:transmitModData() -- Only transmit when item is on ground?
        end

        return true
    end

    return false
end

--! \brief Take an item from a character's inventory.
--! \param itemID \string The ID of the item to take.
--! \return \boolean Whether or not the item was successfully taken.
function CHARACTER:TakeItem(itemID)
    local item = FrameworkZ.Items:GetItemByID(itemID)

    if item then
        local inventory = self.isoPlayer:getInventory()
        local worldItem = inventory:getFirstTypeRecurse(item.id)
        local instanceID = worldItem:getModData()["PFW_ITM"].instanceID

        FrameworkZ.Items:RemoveInstance(item.id, instanceID)
        inventory:DoRemoveItem(worldItem)

        return true
    end

    return false
end

--! \brief Take an item from a character's inventory by its instance ID. Useful for taking a specific item from a stack.
--! \param itemID \string The ID of the item to take.
--! \param instanceID \integer The instance ID of the item to take.
--! \return \boolean Whether or not the item was successfully taken.
function CHARACTER:TakeItemByInstanceID(itemID, instanceID)
    local item = FrameworkZ.Items:GetItemByID(itemID)

    if item then
        local inventory = self.isoPlayer:getInventory()
        local worldItem = inventory:getFirstTypeRecurse(item.id) -- Search whole inventory for matching item instance ID or make an inventory module for more efficiency?

        FrameworkZ.Items:RemoveInstance(item.id, instanceID)
        inventory:DoRemoveItem(worldItem)

        return true
    end

    return false
end

--! \brief Checks if a character is a citizen.
--! \return \boolean Whether or not the character is a citizen.
function CHARACTER:IsCitizen()
    if not self.faction then return false end

    if self.faction == FACTION_CITIZEN then
        return true
    end
    
    return false
end

--! \brief Checks if a character is a combine.
--! \return \boolean Whether or not the character is a combine.
function CHARACTER:IsCombine()
    if not self.faction then return false end

    if self.faction == FACTION_CP then
        return true
    elseif self.faction == FACTION_OTA then
        return true
    elseif self.faction == FACTION_ADMINISTRATOR then
        return true
    end
    
    return false
end

--! \brief Create a new character object.
--! \param username \string The player's username as their ID.
--! \param id \integer The character's ID for the player stored data.
--! \param data \table (Optional) The character's data stored on the object.
--! \return \table The new character object.
function FrameworkZ.Characters:New(username, id, data)
    if not username then return false end

    local object

    if not data then
        object = {
            username = username,
            id = id or -1
        }
    else
        object = data
        object.username = username
        object.id = id or -1
    end

    setmetatable(object, CHARACTER)

	return object
end

--! \brief Initialize a character.
--! \param username \string The player's username.
--! \param character \table The character's object data.
--! \return \string The username added to the list of characters.
function FrameworkZ.Characters:Initialize(username, character)
    self.List[username] = character

    return username
end

--! \brief Get a character by their ID (i.e. username).
--! \param username \string The player's username to get their character object with.
--! \return \table The character object from the list of characters.
function FrameworkZ.Characters:GetCharacterByID(username)
    local character = self.List[username] or nil

    return character
end

if isClient() then

    local showingTooltip = false
    local previousMouseX = 0
    local previousMouseY = 0
    local tooltipX = 0
    local tooltipY = 0
    local tooltipPlayer = nil
    local tooltip = {name = "", description = {}}

    function FrameworkZ.Characters:GetDescriptionLines(description)
        local lines = {}
        local line = ""
        local lineLength = 0
        local words = {}

        for word in string.gmatch(description, "%S+") do
            table.insert(words, word)
        end

        for i = 1, #words do
            local word = words[i]
            local wordLength = string.len(word)

            if lineLength + wordLength <= 30 then
                line = line .. " " .. word
                lineLength = lineLength + wordLength
            else
                table.insert(lines, line)
                line = word
                lineLength = wordLength
            end
        end

        table.insert(lines, line)

        return lines
    end

    function FrameworkZ.Characters.OnPreUIDraw()
        if tooltip then
            local y = tooltipY + getTextManager():getFontFromEnum(UIFont.Dialogue):getLineHeight()
            
            getTextManager():DrawStringCentre(UIFont.Dialogue, tooltipX, y, tooltip.name, 0.6, 0.5, 0.4, 0.75)

            for k, v in pairs(tooltip.description) do
                y = y + getTextManager():getFontFromEnum(UIFont.Dialogue):getLineHeight()
                getTextManager():DrawStringCentre(UIFont.Dialogue, tooltipX, y, v, 1, 1, 1, 0.75)
            end
        end
    end

    function FrameworkZ.Characters:CreateCharacterTick(player, tickTime)
        timer:Create("CharacterTick", tickTime, 0, function()
            local x = getMouseX()
            local y = getMouseY()

            if x ~= previousMouseX or y ~= previousMouseY then
                Events.OnPreUIDraw.Remove(FrameworkZ.Characters.OnPreUIDraw)
                
                showingTooltip = false
                tooltipPlayer = nil
                previousMouseX = x
                previousMouseY = y
            elseif showingTooltip == false then
                showingTooltip = true

                if player then
                    local playerIndex = player:getPlayerNum()
                    local worldX = screenToIsoX(playerIndex, x, y, 0)
                    local worldY = screenToIsoY(playerIndex, x, y, 0)
                    local worldZ = player:getZ()
                    local square = getSquare(worldX, worldY, worldZ)

                    if square then
                        local playerOnSquare = square:getPlayer()

                        if playerOnSquare then
                            local playerOnSquareIndex = playerOnSquare:getPlayerNum()
                            tooltipX = isoToScreenX(playerOnSquareIndex, worldX, worldY, worldZ)
                            tooltipY = isoToScreenY(playerOnSquareIndex, worldX, worldY, worldZ)

                            tooltipPlayer = playerOnSquare
                            local character = FrameworkZ.Characters:GetCharacterByID(playerOnSquare:getUsername())
                            tooltip.name = character and character.name or "Invalid Character"
                            tooltip.description = FrameworkZ.Characters:GetDescriptionLines(character and character.description or "Invalid Description")


                            if tooltip then
                                Events.OnPreUIDraw.Add(FrameworkZ.Characters.OnPreUIDraw)
                            end
                        end
                    end
                end
            elseif showingTooltip == true then
                if player then
                    local playerIndex = player:getPlayerNum()
                    local worldX = screenToIsoX(playerIndex, x, y, 0)
                    local worldY = screenToIsoY(playerIndex, x, y, 0)
                    local worldZ = player:getZ()
                    local square = getSquare(worldX, worldY, worldZ)

                    if square then
                        local playerOnSquare = square:getPlayer()

                        if playerOnSquare ~= tooltipPlayer then
                            Events.OnPreUIDraw.Remove(FrameworkZ.Characters.OnPreUIDraw)
                            showingTooltip = false
                            tooltipPlayer = nil
                        end
                    end
                end
            end
        end)
    end

    --! \brief Initializes a player's character after loading.
    --! \return \boolean Whether or not the post load was successful.
    function FrameworkZ.Characters:PostLoad(isoPlayer, characterID)
        local username = isoPlayer:getUsername()
        local character = FrameworkZ.Characters:New(username, characterID)

        if not character then return false end

        FrameworkZ.Characters:CreateCharacterTick(isoPlayer, 1)
        character.isoPlayer = isoPlayer
        character:Initialize()
        timer:Create("FZ_CharacterSaveInterval", FrameworkZ.Config.CharacterSaveInterval, 0, function()
            if FrameworkZ.Players:SaveCharacter(username, FrameworkZ.Players:GetCharacterDataByID(username, character.id)) then
                if FrameworkZ.Config.ShouldNotifyOnCharacterSave then
                    FrameworkZ.Notifications:AddToQueue("Successfully saved current character.", FrameworkZ.Notifications.Types.Success)
                end
            else
                FrameworkZ.Notifications:AddToQueue("Failed to save current character.", FrameworkZ.Notifications.Types.Danger)
            end
        end)

        return true
    end

    --! \brief Destroys a character and removes them from the character list after disconnecting. Called by OnDisconnect event hook.
    function FrameworkZ.Characters:OnDisconnect()
        print("OnDisconnect")

        local player = getPlayer()
        local username = player:getUsername()
        local character = FrameworkZ.Characters:GetCharacterByID(username)

        if character then
            character:Destroy()
            print("Character destroyed")
        end

        self.List[username] = nil
    end
end

if not isClient() then

    --! \brief Initialize a character called by OnServerStarted event hook.
    --! \param module \string
    --! \param command \string
    --! \param player \table Player object.
    --! \param args \string
    function FrameworkZ.Characters.OnClientCommand(module, command, player, args)
        if module == "PFW_CHAR" then
            if command == "initialize" then
                local username = args[1]
                local character = FrameworkZ.Characters:New(username)

                character.isoPlayer = player
                character:Initialize()
            elseif command == "destroy" then
                local username = args[1]
                local character = FrameworkZ.Characters:GetCharacterByID(username)

                if character then
                    character:Destroy()
                end

                FrameworkZ.Characters.List[username] = nil
            elseif command == "update" then
                local username = args[1]
                local field = args[2]
                local newData = args[3]

                FrameworkZ.Characters.List[username][field] = newData
            end
        end
    end
    Events.OnClientCommand.Add(FrameworkZ.Characters.OnClientCommand)
end
