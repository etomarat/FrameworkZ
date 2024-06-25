ProjectFramework = ProjectFramework or {}

require "ISUI/ISPanel"

PFW_CreateCharacterAppearance = ISPanel:derive("PFW_CreateCharacterAppearance")

local yOffset = 0

function PFW_CreateCharacterAppearance:initialise()
    ISPanel.initialise(self)

    local isFemale = (self.gender == "Female" and true) or (self.gender == "Male" and false)
    self.survivor = SurvivorFactory:CreateSurvivor(SurvivorType.Neutral, isFemale)
    self.survivor:setFemale(isFemale)
    self.uiHelper = ProjectFramework.UI

    local title = "Appearance"
    local subtitle = "Customize your character's appearance."
    local factionWidth = 500
    local factionHeight = 300
    local dropdownWidth = self.width * 0.5
    local middleX = self.width / 2
    local quarterX = self.width / 4
    self.factionsClothing = ProjectFramework.Factions:GetFactionByID(self.faction).clothing
    self.initialFaction = nil
    local entryWidth = 200
    local xPadding = self.width * 0.1
    local entryX = xPadding
    local labelX = xPadding - 5

    ISPanel.initialise(self)

    yOffset = self.uiHelper.GetHeight(UIFont.Title, title)

    self.title = ISLabel:new(self.uiHelper.GetMiddle(self.width, UIFont.Title, title), yOffset, 25, title, 1, 1, 1, 1, UIFont.Title, true)
    self.title:initialise()
	self:addChild(self.title)

    yOffset = yOffset + self.uiHelper.GetHeight(UIFont.Large, subtitle)

    self.subtitle = ISLabel:new(self.uiHelper.GetMiddle(self.width, UIFont.Large, subtitle), yOffset, 25, subtitle, 1, 1, 1, 1, UIFont.Large, true)
    self.subtitle:initialise()
    self:addChild(self.subtitle)

    yOffset = yOffset + 45

    self.characterPreview = PFW_CharacterPreview:new(self.width - 200, yOffset, 200, 400)
    self.characterPreview:initialise()
    self.characterPreview:setCharacter(getPlayer())
    self.characterPreview:setSurvivorDesc(self.survivor)
    self:addChild(self.characterPreview)

    if self.factionsClothing then
        self.headLabel, self.headDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Head:", "Hat", self.factionsClothing.head)
        self.faceLabel, self.faceDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Face:", "Mask", self.factionsClothing.face)
        self.earsLabel, self.earsDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Ears:", "Ears", self.factionsClothing.ears)
        self.backpackLabel, self.backpackDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Backpack:", "Back", self.factionsClothing.backpack)
        self.glovesLabel, self.glovesDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Gloves:", "Hands", self.factionsClothing.gloves)
        self.undershirtLabel, self.undershirtDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Undershirt:", "Tshirt", self.factionsClothing.undershirt)
        self.overshirtLabel, self.overshirtDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Overshirt:", "Shirt", self.factionsClothing.overshirt)
        self.vestLabel, self.vestDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Vest:", "TorsoExtraVest", self.factionsClothing.vest)
        self.beltLabel, self.beltDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Belt:", "Belt", self.factionsClothing.belt)
        self.pantsLabel, self.pantsDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Pants:", "Pants", self.factionsClothing.pants)
        self.socksLabel, self.socksDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Socks:", "Socks", self.factionsClothing.socks)
        self.shoesLabel, self.shoesDropdown = self:addClothingOption(entryX, yOffset, 25, entryWidth, "Shoes:", "Shoes", self.factionsClothing.shoes)
    end
end

function PFW_CreateCharacterAppearance:addClothingOption(x, y, height, entryWidth, labelText, clothingLocation, clothingTable)
    local label = ISLabel:new(x - 5, y, height, labelText, 1, 1, 1, 1, UIFont.Large, false)
    label:initialise()
    self:addChild(label)

    local dropdown = ISComboBox:new(x, y, entryWidth, height,self, self.onClothingChanged)

    if clothingTable then
        for k, v in pairs(clothingTable) do
            dropdown:addOptionWithData(v, {location = clothingLocation, itemID = k})
        end
    end

    dropdown:addOptionWithData("None", {location = clothingLocation, itemID = nil})
    dropdown:initialise()
    self:onClothingChanged(dropdown)
    self:addChild(dropdown)

    if not clothingTable then
        label:setVisible(false)
        dropdown:setVisible(false)

        return label, dropdown
    end
    yOffset = yOffset + 30

    return label, dropdown
end

function PFW_CreateCharacterAppearance:onClothingChanged(dropdown)
    local dropdownData = dropdown:getOptionData(dropdown.selected)
    local itemID = dropdownData.itemID
    local location = dropdownData.location
    local item = InventoryItemFactory.CreateItem(itemID)

    self.survivor:setWornItem(location, nil)

    if item then
        self.survivor:setWornItem(location, item)
    end

    self.characterPreview:setSurvivorDesc(self.survivor)
end

function PFW_CreateCharacterAppearance:resetGender()
    local isFemale = (self.gender == "Female" and true) or (self.gender == "Male" and false)
    self.survivor = SurvivorFactory:CreateSurvivor(SurvivorType.Neutral, isFemale)
    self.survivor:setFemale(isFemale)
    self:onClothingChanged(self.headDropdown)
    self:onClothingChanged(self.undershirtDropdown)
    self:onClothingChanged(self.overshirtDropdown)
    self:onClothingChanged(self.pantsDropdown)
    self:onClothingChanged(self.socksDropdown)
    self:onClothingChanged(self.shoesDropdown)
    self.characterPreview:setSurvivorDesc(self.survivor)
end

function PFW_CreateCharacterAppearance:render()
    ISPanel.render(self)
end

function PFW_CreateCharacterAppearance:update()
    ISPanel.update(self)
end

function PFW_CreateCharacterAppearance:new(parameters)
	local o = {}

	o = ISPanel:new(parameters.x, parameters.y, parameters.width, parameters.height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = {r=0, g=0, b=0, a=0}
	o.borderColor = {r=0, g=0, b=0, a=0}
	o.moveWithMouse = false
	o.playerObject = parameters.playerObject
    o.faction = parameters.faction
    o.gender = parameters.gender
	PFW_CreateCharacterAppearance.instance = o

	return o
end

return PFW_CreateCharacterAppearance
