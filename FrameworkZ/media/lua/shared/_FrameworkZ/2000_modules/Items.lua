FrameworkZ = FrameworkZ or {}

--! \brief Items module for FrameworkZ. Defines and interacts with ITEM \object.
--! \class FrameworkZ.Items
FrameworkZ.Items = {}
FrameworkZ.Items.__index = FrameworkZ.Items
FrameworkZ.Items.List = {}
FrameworkZ.Items.Instances = {}
FrameworkZ.Items = FrameworkZ.Foundation:NewModule(FrameworkZ.Items, "Items")

local ITEM = {}
ITEM.__index = ITEM

ITEM.name = "Unnamed Item"
ITEM.description = "No description available."
ITEM.category = "No Category"
ITEM.useText = "Use"
ITEM.useTime = 1
ITEM.weight = 1
ITEM.shouldConsume = true

function ITEM:Initialize()
    return FrameworkZ.Items:Initialize(self)
end

function ITEM:CanContext(isoPlayer, worldItem) return true end
function ITEM:CanDrop(isoPlayer, worldItem) return true end
function ITEM:CanUse(isoPlayer, worldItem) return true end
function ITEM:OnContext(playerObject, instance, interactContext) end
function ITEM:OnInstanced(isoPlayer, worldItem) end
function ITEM:OnUse(isoPlayer, worldItem) end

function ITEM:GetName()
    return self.name or "Unnamed Item"
end

function FrameworkZ.Items:New(uniqueID, itemID, username)
    if not uniqueID then return false, "Missing unique ID." end

    local object = {
        uniqueID = uniqueID,
        itemID = itemID or "Base.Plank",
        owner = username or nil,
    }

    setmetatable(object, ITEM)

    return object, "Item created."
end

function FrameworkZ.Items:Initialize(data)
    self.List[data.uniqueID] = data

    return data.uniqueID
end

function FrameworkZ.Items:CreateWorldItem(isoPlayer, fullItemID)
    if not isoPlayer then return false, "Missing ISO Player." end
    if not fullItemID then return false, "Missing full item ID." end

    local worldItem = isoPlayer:getInventory():AddItem(InventoryItemFactory.CreateItem(fullItemID))

    return true, "Created world item.", worldItem
end

function FrameworkZ.Items:CreateItem(itemID, isoPlayer)
    if not itemID then return false, "Missing item ID." end
    if not isoPlayer then return false, "Missing ISO Player." end

    local item = self:GetItemByID(itemID)

    if not item then return false, "Item not found." end

    local success, message, worldItem = FrameworkZ.Items:CreateWorldItem(isoPlayer, item.itemID)

    if not success or not worldItem then return false, message end

    local instanceID, itemInstance = self:AddInstance(item, isoPlayer, worldItem)

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

    return true, "Created " .. itemInstance.uniqueID .. " item.", itemInstance
end

function FrameworkZ.Items:AddInstance(item, isoPlayer, worldItem)
    local instanceID = #self.Instances + 1

    --item["worldItem"] = worldItem
    --self.Instances[instanceID] = item
    table.insert(self.Instances, FrameworkZ.Utilities:CopyTable(item))

    local itemInstance = self.Instances[instanceID]

    if itemInstance.OnInstanced then
        itemInstance:OnInstanced(isoPlayer, worldItem)
    end

    return instanceID, itemInstance
end

function FrameworkZ.Items:LinkWorldItemToInstanceData(worldItem, instanceData)
    worldItem:getModData()["FZ_ITM"] = instanceData
    worldItem:setName(instanceData.name)
    worldItem:setActualWeight(instanceData.weight)
end

function FrameworkZ.Items:GetInstance(id)
    return self.Instances[id]
end

function FrameworkZ.Items:RemoveInstance(id)
    local instance = self.Instances[id]

    if instance.OnRemoved then
        instance:OnRemoved()
    end

    instance.worldItem:getContainer():DoRemoveItem(instance.worldItem)
    self.Instances[id] = nil
end

function FrameworkZ.Items:GetItemByID(uniqueID)
    local item = self.List[uniqueID] or nil

    return item
end

-- TODO use multiple items, not just one
function FrameworkZ.Items:OnUseItemCallback(parameters)
    local worldItem, item, playerObject = parameters[1], parameters[2], parameters[3]

    item:OnUse(playerObject, worldItem)
end

function FrameworkZ.Items:OnDropItemCallback(parameters)
    local items, playerObject = ISInventoryPane.getActualItems(parameters[1]), parameters[2]

	for _, item in ipairs(items) do
		if not item:isFavorite() then
			ISInventoryPaneContextMenu.dropItem(item, playerObject)
		end
	end
end

function FrameworkZ.Items:OnExamineItemCallback(parameters)
    local item, playerObject = parameters[1], parameters[2]

    playerObject:Say(item.description)
end

function FrameworkZ.Items:OnFillInventoryObjectContextMenu(player, context, items)
    context:clear()

    local playerObject = getSpecificPlayer(player)
    local menuManager = MenuManager.new(context)
    local interactSubMenu = menuManager:addSubMenu("Interact")
    local equipSubMenu = menuManager:addSubMenu("Equip")
    local manageSubMenu = menuManager:addSubMenu("Manage")

    items = ISInventoryPane.getActualItems(items)

    local uniqueIDCounts = {}
    for k, v in pairs(items) do
        if instanceof(v, "InventoryItem") and v:getModData()["FZ_ITM"] then
            local uniqueID = v:getModData()["FZ_ITM"].uniqueID
            uniqueIDCounts[uniqueID] = (uniqueIDCounts[uniqueID] or 0) + 1
        end
    end

    for k, v in pairs(items) do
        if instanceof(v, "InventoryItem") and v:getModData()["FZ_ITM"] then
            local itemData = v:getModData()["FZ_ITM"]
            local uniqueID = itemData.uniqueID
            local instanceID = itemData.instanceID
            local instance = self:GetInstance(instanceID)
            local canContext = false

            if instance then
                if instance.CanContext then
                    canContext = instance:CanContext(playerObject, v)
                end

                if canContext then
                    if instance.OnContext then
                        context = instance:OnContext(playerObject, menuManager, uniqueIDCounts[uniqueID])
                    elseif instance.OnUse then
                        local useText = (instance.useText or "Use") .. " " .. instance.name
                        local useOption = Options.new(useText, self, FrameworkZ.Items.OnUseItemCallback, {v, instance, playerObject}, true, true, uniqueIDCounts[uniqueID])
                        menuManager:addAggregatedOption(uniqueID, useOption, interactSubMenu)
                    end
                end

                local examineText = "Examine " .. instance.name
                local examineOption = Options.new(examineText, self, FrameworkZ.Items.OnExamineItemCallback, {v, instance, playerObject}, false, true, uniqueIDCounts[uniqueID])
                menuManager:addAggregatedOption("Examine" .. uniqueID, examineOption, interactSubMenu)

                local dropText = "Drop " .. instance.name
                local dropOption = Options.new(dropText, self, FrameworkZ.Items.OnDropItemCallback, {v, player}, false, true, uniqueIDCounts[uniqueID])
                menuManager:addAggregatedOption(uniqueID, dropOption, manageSubMenu)
            else
                local option = Options.new()
                option:setText("Malformed Item")
                menuManager:addOption(option, interactSubMenu)
            end
        end
    end

    menuManager:buildMenu()

    if interactSubMenu:getContext():isEmpty() then
        local option = Options.new()
        option:setText("No Interactions Available")
        menuManager:addOption(option, interactSubMenu)
    end
end

FrameworkZ.Foundation:RegisterModule(FrameworkZ.Items)
