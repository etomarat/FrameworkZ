--! \page globalVars Global Variables
--! \section Inventories Inventories
--! FrameworkZ.Inventories\n
--! See Inventories for the module on inventories.\n\n
--! FrameworkZ.Inventories.List\n
--! A list of all instanced inventories in the game.\n\n
--! FrameworkZ.Inventories.Types\n
--! The types of inventories that can be created.

FrameworkZ = FrameworkZ or {}

--! \brief The Inventories module for FrameworkZ. Defines and interacts with INVENTORY object.
--! \class Inventories
FrameworkZ.Inventories = {}
FrameworkZ.Inventories.__index = FrameworkZ.Inventories
FrameworkZ.Inventories.List = {}
FrameworkZ.Inventories.Types = {
    Character = "Character",
    Container = "Container",
    Vehicle = "Vehicle"
}
FrameworkZ.Inventories = FrameworkZ.Foundation:NewModule(FrameworkZ.Inventories, "Inventories")

--! \brief Inventory class for FrameworkZ.
--! \class INVENTORY
local INVENTORY = {}
INVENTORY.__index = INVENTORY

--! \brief Initialize an inventory.
--! \return \string The inventory's ID.
function INVENTORY:Initialize()
    return FrameworkZ.Inventories:Initialize(self.id, self)
end

--! \brief Add an item to the inventory.
--! \details Note: This does not add a world item, it simply adds it to the inventory's object. Please use CHARACTER::GiveItem(itemID) to add an item to a character's inventory along with the world item.
--! \param item \string The item's ID.
--! \see CHARACTER::GiveItem(itemID)
function INVENTORY:AddItem(item)
    self.items[#self.items + 1] = item
end

--! \brief Add multiple items to the inventory.
--! \details Note: This does not add a world item, it simply adds it to the inventory's object. Please use CHARACTER::GiveItems(itemID) to add an items to a character's inventory along with the world item.
--! \param itemID \string The item's ID.
--! \param quantity \integer The quantity of the item to add.
--! \see CHARACTER::GiveItems(itemID)
function INVENTORY:AddItems(itemID, quantity)
    for i = 1, quantity do
        self:AddItem(itemID)
    end
end

--! \brief Get the inventory's name.
--! \return \string The inventory's name.
function INVENTORY:GetName()
    return self.name or "Someone's Inventory"
end

--! \brief Create a new inventory object.
--! \param username \string The owner's username. Can be nil for no owner.
--! \param type \string The type of inventory. Can be nil, but creates a character inventory type by default. Refer to FrameworkZ.Inventories.Types table for available types.
--! \param id \string The inventory's ID. Can be nil for an auto generated ID (recommended).
--! \return \table The new inventory object.
function FrameworkZ.Inventories:New(username, type, id)
    if not id then
        FrameworkZ.Inventories.List[#FrameworkZ.Inventories.List + 1] = {} -- Reserve space to avoid inconsistencies.
        id = #FrameworkZ.Inventories.List
    end

    local object = {
        id = id,
        owner = username or "",
        type = type or FrameworkZ.Inventories.Types.Character,
        name = "Someone's Inventory",
        description = "No description available.",
        items = {}
    }

    setmetatable(object, INVENTORY)

    return object
end

--! \brief Initialize an inventory.
--! \param id \table The inventory's id.
--! \param object \table The inventory's object.
--! \return \integer The inventory's ID.
function FrameworkZ.Inventories:Initialize(id, object)
    FrameworkZ.Inventories.List[id] = object

    return id
end

function FrameworkZ.Inventories:GetInventoryByID(id)
    local inventory = FrameworkZ.Inventories.List[id] or nil

    return inventory
end

--! \brief Recursively traverses the inventory table for missing data while referencing the item definitions to rebuild the inventory.
--! \param inventory \table The inventory to rebuild.
--! \return \table The rebuilt inventory.
function FrameworkZ.Inventories:Rebuild(isoPlayer, inventory, items)
    if not isoPlayer then return false, "No ISO Player to add items to." end
    if not inventory then return false, "No inventory to rebuild." end
    if not items then return false, "No items to add to inventory." end

    -- Helper function to rebuild the inventory object itself
    local function rebuildInventoryObject(inventory)
        local inventoryDefinition = INVENTORY
        if inventoryDefinition then
            for key, value in pairs(inventoryDefinition) do
                if inventory[key] == nil then
                    inventory[key] = value
                end
            end
        end
    end

    -- Helper function to recursively rebuild an item
    local function rebuildItem(item)
        if type(item) == "table" then
            local itemDefinition = FrameworkZ.Items:GetItemByID(item.uniqueID)

            if itemDefinition then
                local function recursiveRebuild(target, source)
                    for key, value in pairs(source) do
                        if type(value) == "table" then
                            target[key] = target[key] or {}
                            recursiveRebuild(target[key], value)
                        elseif target[key] == nil then
                            target[key] = value
                        end
                    end
                end

                recursiveRebuild(item, itemDefinition)
            end

            local success, message, worldItem = FrameworkZ.Items:CreateWorldItem(isoPlayer, item.itemID)

            if success and worldItem then
                local instanceID, itemInstance = FrameworkZ.Items:AddInstance(item, isoPlayer, worldItem)

                local instanceData = {
                    uniqueID = itemInstance.uniqueID,
                    itemID = worldItem:getFullType(),
                    instanceID = instanceID,
                    owner = isoPlayer:getUsername(),
                    name = itemInstance.name or "Unknown",
                    description = itemInstance.description or "No description available.",
                    category = itemInstance.category or "Uncategorized",
                    shouldConsume = itemInstance.shouldConsume or false,
                    weight = itemInstance.weight or 1,
                    useAction = itemInstance.useAction or nil,
                    useTime = itemInstance.useTime or nil,
                    customFields = itemInstance.customFields or {}
                }

                FrameworkZ.Items:LinkWorldItemToInstanceData(worldItem, instanceData)

                inventory:AddItem(itemInstance)
            end
        end
    end

    -- Rebuild the inventory object itself
    --rebuildInventoryObject(inventory)

    -- Rebuild each item in the inventory
    for key, item in pairs(items) do
        rebuildItem(item)
    end

    return true, "Inventory rebuilt.", inventory
end
