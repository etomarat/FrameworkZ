PFW_CharacterView = ISPanel:derive("PFW_CharacterView")

local FONT_HEIGHT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HEIGHT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HEIGHT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function PFW_CharacterView:initialise()
    ISPanel.initialise(self)

    if self.characterNameLabel then
        self:removeChild(self.characterNameLabel)
    end

    if self.characterPreview then
        self:removeChild(self.characterPreview)
    end

    if self.descriptionLabels then
        for k, v in pairs(self.descriptionLabels) do
            self:removeChild(v)
        end
    end

    self.descriptionLabels = {}
    self.uiHelper = ProjectFramework.UI
    local descriptionLines = self:getDescriptionLines(self.description)
    local descriptionHeight = FONT_HEIGHT_SMALL * 4
    local isFemale = (self.character.gender == "Female" and true) or (self.character.gender == "Male" and false)
    local x = self.uiHelper.GetMiddle(self.width, UIFont.Medium, self.name)
    local y = 0

    self.survivor = SurvivorFactory:CreateSurvivor(SurvivorType.Neutral, isFemale)
    self.survivor:setFemale(isFemale)

    self.characterNameLabel = ISLabel:new(x, 0, FONT_HEIGHT_MEDIUM, self.name, 1, 1, 1, 1, UIFont.Medium, true)
    self.characterNameLabel:initialise()
    self:addChild(self.characterNameLabel)

    local previewHeight = self.height - self.characterNameLabel.height - descriptionHeight
    y = y + self.characterNameLabel.height + 4

    self.characterPreview = PFW_CharacterPreview:new(0, y, self.width, previewHeight, "EventIdle")
    self.characterPreview:initialise()
    self.characterPreview:removeChild(self.characterPreview.animCombo)
    self.characterPreview:setCharacter(self.isoPlayer)
    --self.characterPreview:setSurvivorDesc(self.survivor)
    self:updateAppearance()
    self:addChild(self.characterPreview)

    y = y + previewHeight

    for k, v in pairs(descriptionLines) do
        x = self.uiHelper.GetMiddle(self.width, UIFont.Small, v)

        local totalLines = #descriptionLines
        local adjustedK = k - 1
        local alphaStart = 1.0
        local alphaMin = 0.2
        local decayRate = 5
        local alpha

        if totalLines == 1 then
            alpha = alphaStart -- Directly set to alphaStart if there's only one line
        else
            alpha = alphaMin + (alphaStart - alphaMin) * ((1 - adjustedK / (totalLines - 1)) ^ decayRate)
            alpha = math.max(alpha, alphaMin)
        end

        local descriptionLabel = ISLabel:new(x, y, FONT_HEIGHT_SMALL, v, 1, 1, 1, alpha, UIFont.Small, true)
        descriptionLabel:initialise()
        self:addChild(descriptionLabel)

        table.insert(self.descriptionLabels, descriptionLabel)

        if k <= 3 then
            y = y + descriptionLabel.height
        else
            -- For more than 3 lines, the loop breaks after adding "..." to the last displayed line
            break
        end
    end
end

function PFW_CharacterView:render()
    ISPanel.prerender(self)

    -- Render the character preview and any other UI elements here
end

function PFW_CharacterView:updateAppearance()
    for k, v in ipairs (ProjectFramework.Characters.EquipmentSlots) do
        self.survivor:setWornItem(v, nil)
    end

    local character = self.character

    local headItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_HEAD)
    local faceItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_FACE)
    local earsItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_EARS)
    local backpackItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_BACKPACK)
    local glovesItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_GLOVES)
    local undershirtItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_UNDERSHIRT)
    local overshirtItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_OVERSHIRT)
    local vestItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_VEST)
    local beltItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_BELT)
    local pantsItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_PANTS)
    local socksItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_SOCKS)
    local shoesItem = InventoryItemFactory.CreateItem(character.EQUIPMENT_SLOT_SHOES)

    self.survivor:setWornItem(EQUIPMENT_SLOT_HEAD, headItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_FACE, faceItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_EARS, earsItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_BACKPACK, backpackItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_GLOVES, glovesItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_UNDERSHIRT, undershirtItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_OVERSHIRT, overshirtItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_VEST, vestItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_BELT, beltItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_PANTS, pantsItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_SOCKS, socksItem)
    self.survivor:setWornItem(EQUIPMENT_SLOT_SHOES, shoesItem)

    self.characterPreview:setSurvivorDesc(self.survivor)
end

function PFW_CharacterView:setCharacter(character)
    self.character = character
end

function PFW_CharacterView:setName(name)
    self.name = name
end

function PFW_CharacterView:setDescription(description)
    self.description = description
end

function PFW_CharacterView:reinitialize(character)
    self:setCharacter(character)
    self:setName(character.name)
    self:setDescription(character.description)
    self:initialise()
end

function PFW_CharacterView:getDescriptionLines(description)
    local lines = {}
    local line = ""
    local lineLength = 0
    local words = {}

    for word in string.gmatch(description, "%S+") do
        table.insert(words, word)
    end

    if #words == 0 then
        return {description}
    end

    for i = 1, #words do
        local word = words[i]
        local wordLength = string.len(word) + 1

        if lineLength + wordLength <= 30 or lineLength == 0 then
            line = lineLength == 0 and word or line .. " " .. word
            lineLength = lineLength + wordLength
        else
            table.insert(lines, line)
            line = word
            lineLength = wordLength
        end
    end

    if line ~= "" then
        table.insert(lines, line)
    end

    return lines
end

function PFW_CharacterView:new(x, y, width, height, isoPlayer, character, name, description)
    local o = {}

	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = {r=0, g=0, b=0, a=0}
	o.borderColor = {r=0, g=0, b=0, a=0}
	o.moveWithMouse = false
	o.isoPlayer = isoPlayer
    self.character = character
    o.name = name
    o.description = description
	PFW_CharacterView.instance = o

	return o
end

return PFW_CharacterView
