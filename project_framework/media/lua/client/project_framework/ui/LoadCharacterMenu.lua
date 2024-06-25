PFW_LoadCharacterMenu = ISPanel:derive("PFW_LoadCharacterMenu")

function PFW_LoadCharacterMenu:initialise()
    ISPanel.initialise(self)

    self.gender = "Male"

    local characterPreviewWidth = 200
    local characterPreviewHeight = 400
    local isFemale = (self.gender == "Female" and true) or (self.gender == "Male" and false)
    self.survivor = SurvivorFactory:CreateSurvivor(SurvivorType.Neutral, isFemale)
    self.survivor:setFemale(isFemale)

    self.nextButton = ISButton:new(self.width - 20, 0, 30, self.height, ">", self, PFW_LoadCharacterMenu.onNext)
    self.nextButton.font = UIFont.Large
    self.nextButton.internal = "NEXT"
    self.nextButton:initialise()
    self.nextButton:instantiate()
    self:addChild(self.nextButton)

    self.previousButton = ISButton:new(0, 0, 30, self.height, "<", self, PFW_LoadCharacterMenu.onPrevious)
    self.previousButton.font = UIFont.Large
    self.previousButton.internal = "PREVIOUS"
    self.previousButton:initialise()
    self.previousButton:instantiate()
    self:addChild(self.previousButton)

    self.characterPreview = PFW_CharacterPreview:new(self.width / 2 - characterPreviewWidth / 2, self.height / 2 - characterPreviewHeight / 2, characterPreviewWidth, characterPreviewHeight, "EventIdle")
    self.characterPreview:initialise()
    self.characterPreview:removeChild(self.characterPreview.animCombo)
    self.characterPreview:setCharacter(getPlayer())
    self.characterPreview:setSurvivorDesc(self.survivor)
    self:addChild(self.characterPreview)
end

function PFW_LoadCharacterMenu:onNext()
    self.currentIndex = math.min(self.currentIndex + 1, #self.characters)
    self:updateCharacterPreview()
end

function PFW_LoadCharacterMenu:onPrevious()
    self.currentIndex = math.max(self.currentIndex - 1, 1)
    self:updateCharacterPreview()
end

function PFW_LoadCharacterMenu:updateCharacterPreview()
    -- Update character preview based on self.currentIndex
    -- This is where you'd change the displayed character and potentially play the walking animation
end

function PFW_LoadCharacterMenu:render()
    ISPanel.prerender(self)

    -- Render the character preview and any other UI elements here
end

function PFW_LoadCharacterMenu:new(x, y, width, height, isoPlayer, characters)
    local o = {}

	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = {r=0, g=0, b=0, a=0}
	o.borderColor = {r=0, g=0, b=0, a=0}
	o.moveWithMouse = false
	o.isoPlayer = isoPlayer
    o.characters = characters
	PFW_LoadCharacterMenu.instance = o

	return o
end

return PFW_LoadCharacterMenu
