FrameworkZ = FrameworkZ or {}

FrameworkZ.Items = {}
FrameworkZ.Items.__index = FrameworkZ.Items
FrameworkZ.Items.List = {}
FrameworkZ.Items.Instances = {}
FrameworkZ.Items = FrameworkZ.Foundation:NewModule(FrameworkZ.Items, "Items")

local ITEM = {}
ITEM.__index = ITEM

function ITEM:Initialize()
    return FrameworkZ.Items:Initialize(self.uniqueID, self)
end

function ITEM:GetName()
    return self.name or "Unnamed Item"
end

function FrameworkZ.Items:New(uniqueID, itemID, username)
    local object = {
        uniqueID = uniqueID or nil,
        itemID = itemID or "Base.Plank",
        owner = username or "",
        name = "Unnamed Item",
        description = "No description available."
    }

    setmetatable(object, ITEM)

    return object
end

function FrameworkZ.Items:Initialize(uniqueID, data)
    FrameworkZ.Items.List[uniqueID] = data

    return uniqueID
end

function FrameworkZ.Items:AddInstance()
    self.Instances[#self.Instances + 1] = {}

    return #self.Instances
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

function FrameworkZ.Items:InitializeInstance(id, item, playerObject, worldItem)
    if item.OnInstanced then
        item:OnInstanced(playerObject, worldItem)
    end

    item["worldItem"] = worldItem
    self.Instances[id] = item

    return self.Instances[id]
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
        if instanceof(v, "InventoryItem") and v:getModData()["PFW_ITM"] then
            local uniqueID = v:getModData()["PFW_ITM"].uniqueID
            uniqueIDCounts[uniqueID] = (uniqueIDCounts[uniqueID] or 0) + 1
        end
    end

    for k, v in pairs(items) do
        if instanceof(v, "InventoryItem") and v:getModData()["PFW_ITM"] then
            local itemData = v:getModData()["PFW_ITM"]
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
                        context = instance:OnContext(playerObject, instance, interactContext)
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
