require "ISUI/ISPanel"

PFW_MainMenu = ISPanel:derive("PFW_MainMenu")

local nextLightning = 5

function PFW_MainMenu:initialise()
    timer:Create("MainMenuTick", 1, 0, function()
        if PFW_MainMenu.instance then
            if not timer:Exists("NextLightning") then
                timer:Create("NextLightning", nextLightning, 1, function()
                    local mainMenu = PFW_MainMenu.instance
                    mainMenu.shouldFlashLightning = true
                    mainMenu.hasFlashed1 = false
                    mainMenu.hasFlashed2 = false
                    mainMenu.hasFlashed3 = false
                    nextLightning = ZombRandBetween(10, 60)

                    timer:Simple(2, function()
                        mainMenu.emitter:playSoundImpl("thunder" .. ZombRandBetween(3, 4), nil)
                    end)
                end)
            end
        end
    end)

    self.uiHelper = ProjectFramework.UI
    self.emitter = self.playerObject:getEmitter()
	local title = ProjectFramework.Config.GamemodeTitle
    local subtitle = ProjectFramework.Config.GamemodeDescription
    local createCharacterLabel = "Create Character"
    local loadCharacterLabel = "Load Character"
    local disconnectLabel = "Disconnect"
    local middleX = self.width / 2 - 200 / 2
    local middleY = self.height / 2 + ProjectFramework.UI.GetHeight(UIFont.Title, title) + ProjectFramework.UI.GetHeight(UIFont.Large, subtitle)

	ISPanel.initialise(self)
    self.emitter:playSoundImpl("hl2_song19", nil)

    local stepWidth, stepHeight = 500, 600
    local stepX, stepY = self.width / 2 - stepWidth / 2, self.height / 2 - stepHeight / 2
    self.MainMenu = self
    self.createCharacterSteps = ProjectFramework.UserInterfaces:New("VanillaCreateCharacter", self)
    self.createCharacterSteps.onEnterInitialMenu = self.onEnterMainMenu
    self.createCharacterSteps.onExitInitialMenu = self.onExitMainMenu
    self.createCharacterSteps:Initialize()
    self.createCharacterSteps:RegisterNextStep("MainMenu", "SelectFaction", self, PFW_CreateCharacterFaction, self.onEnterFactionMenu, self.onExitFactionMenu, {x = stepX, y = stepY, width = stepWidth, height = stepHeight, playerObject = self.playerObject})
    self.createCharacterSteps:RegisterNextStep("SelectFaction", "EnterInfo", PFW_CreateCharacterFaction, PFW_CreateCharacterInfo, self.onEnterInfoMenu, self.onExitInfoMenu, {x = stepX, y = stepY, width = stepWidth, height = stepHeight, playerObject = self.playerObject})
    self.createCharacterSteps:RegisterNextStep("EnterInfo", "CustomizeAppearance", PFW_CreateCharacterInfo, PFW_CreateCharacterAppearance, self.onEnterAppearanceMenu, self.onExitAppearanceMenu, {x = stepX, y = stepY, width = stepWidth, height = stepHeight, playerObject = self.playerObject})
    self.createCharacterSteps:RegisterNextStep("CustomizeAppearance", "MainMenu", PFW_CreateCharacterAppearance, self, self.onFinalizeCharacter, nil, {x = stepX, y = stepY, width = stepWidth, height = stepHeight, playerObject = self.playerObject})

    self.titleY = self.uiHelper.GetHeight(UIFont.Title, title)

    self.title = ISLabel:new(self.uiHelper.GetMiddle(self.width, UIFont.Title, title), self.titleY, 25, title, 1, 1, 1, 1, UIFont.Title, true)
	self:addChild(self.title)

    self.subtitle = ISLabel:new(self.uiHelper.GetMiddle(self.width, UIFont.Large, subtitle), self.titleY + self.uiHelper.GetHeight(UIFont.Large, subtitle), 25, subtitle, 1, 1, 1, 1, UIFont.Large, true)
    self:addChild(self.subtitle)

    self.createCharacterButton = ISButton:new(middleX, middleY - 75, 200, 50, createCharacterLabel, self.createCharacterSteps, self.createCharacterSteps.ShowNextStep)
    self.createCharacterButton.font = UIFont.Large
    self:addChild(self.createCharacterButton)

    self.loadCharacterButton = ISButton:new(middleX, middleY, 200, 50, loadCharacterLabel, self, PFW_MainMenu.onEnterLoadCharacterMenu)
    self.loadCharacterButton.font = UIFont.Large
    self:addChild(self.loadCharacterButton)

    self.disconnectButton = ISButton:new(middleX, middleY + 75, 200, 50, disconnectLabel, self, PFW_MainMenu.onDisconnect)
    self.disconnectButton.font = UIFont.Large
    self:addChild(self.disconnectButton)

    --[[
    self.closeButton = ISButton:new(middleX, middleY + 150, 200, 50, "Close", self, PFW_MainMenu.onClose)
    self.closeButton.font = UIFont.Large
    self:addChild(self.closeButton)
    --]]
end

function PFW_MainMenu:onClose()
    self:setVisible(false)
    self:removeFromUIManager()
end

function PFW_MainMenu:onEnterMainMenu()
    self.createCharacterButton:setVisible(true)
    self.loadCharacterButton:setVisible(true)
    self.disconnectButton:setVisible(true)
end

function PFW_MainMenu:onExitMainMenu()
    local maxCharacters = 1
    local currentCharacters = 0

    if currentCharacters < maxCharacters then
        self.createCharacterButton:setVisible(false)
        self.loadCharacterButton:setVisible(false)
        self.disconnectButton:setVisible(false)

        return true
    else
        return false
    end
end

function PFW_MainMenu:showStepControls(menu, backButtonIndex, backButton, backButtonText, forwardButtonIndex, forwardButton, forwardButtonText)
    if not backButton then
        local width = 200
        local height = 50
        local x = menu:getX()
        local y = menu:getY() + menu.height + 25

        self[backButtonIndex] = ISButton:new(x, y, width, height, backButtonText, self.createCharacterSteps, self.createCharacterSteps.ShowPreviousStep)
        self[backButtonIndex].font = UIFont.Large
        self:addChild(self[backButtonIndex])
    else
        backButton:setVisible(true)
    end

    if not forwardButton then
        local width = 200
        local height = 50
        local x = menu:getX() + menu.width - width
        local y = menu:getY() + menu.height + 25

        self[forwardButtonIndex] = ISButton:new(x, y, width, height, forwardButtonText, self.createCharacterSteps, self.createCharacterSteps.ShowNextStep)
        self[forwardButtonIndex].font = UIFont.Large
        self:addChild(self[forwardButtonIndex])
    else
        forwardButton:setVisible(true)
    end
end

function PFW_MainMenu:hideStepControls(backButton, forwardButton)
    if backButton then
        backButton:setVisible(false)
    end

    if forwardButton then
        forwardButton:setVisible(false)
    end
end

function PFW_MainMenu:onEnterFactionMenu(menu)
    self:showStepControls(menu, "returnToMainMenu", self.returnToMainMenu, "< Main Menu", "enterInfoForward", self.enterInfoForward, "Info >")
end

function PFW_MainMenu:onExitFactionMenu(menu)
    self:hideStepControls(self.returnToMainMenu, self.enterInfoForward)

    return true
end

function PFW_MainMenu:onEnterInfoMenu(menu)
    self:showStepControls(menu, "selectFaction", self.selectFaction, "< Faction", "customizeAppearance", self.customizeAppearance, "Appearance >")
end

function PFW_MainMenu:onExitInfoMenu(menu)
    self:hideStepControls(self.selectFaction, self.customizeAppearance)

    return true
end

function PFW_MainMenu:onEnterAppearanceMenu(menu)
    menu.faction = PFW_CreateCharacterFaction.instance.faction
    menu.gender = PFW_CreateCharacterInfo.instance.gender
    menu.skinColor = PFW_CreateCharacterInfo.instance.skinColorDropdown:getOptionData(PFW_CreateCharacterInfo.instance.skinColorDropdown.selected)

    PFW_CreateCharacterAppearance.instance.skinColor = menu.skinColor

    PFW_CreateCharacterAppearance.instance:resetGender(menu.gender)
    PFW_CreateCharacterAppearance.instance:resetHairStyles()
    PFW_CreateCharacterAppearance.instance:syncSkinColor()

    self:showStepControls(menu, "enterInfoBack", self.enterInfoBack, "< Info", "finalizeCharacter", self.finalizeCharacter, "Finalize >")
end

function PFW_MainMenu:onExitAppearanceMenu(menu)
    self:hideStepControls(self.enterInfoBack, self.finalizeCharacter)

    return true
end

function PFW_MainMenu:onFinalizeCharacter(menu)
    self:hideStepControls(self.enterInfoBack, self.finalizeCharacter)

    local factionInstance = PFW_CreateCharacterFaction.instance
    local infoInstance = PFW_CreateCharacterInfo.instance
    local appearanceInstance = PFW_CreateCharacterAppearance.instance

    local faction = factionInstance.faction
    local gender = infoInstance.genderDropdown:getSelectedText()
    local name = infoInstance.nameEntry:getText()
    local description = infoInstance.descriptionEntry:getText()
    local age = infoInstance.ageSlider:getCurrentValue()
    local height = infoInstance.heightSlider:getCurrentValue()
    local weight = infoInstance.weightSlider:getCurrentValue()
    local physique = infoInstance.physiqueDropdown:getSelectedText()
    local eyeColor = infoInstance.eyeColorDropdown:getSelectedText()
    local hairColor = infoInstance.hairColorDropdown:getSelectedText()
    local skinColor = infoInstance.skinColorDropdown:getOptionData(infoInstance.skinColorDropdown.selected) or nil

    local hair = appearanceInstance.hairDropdown and appearanceInstance.hairDropdown:getOptionData(appearanceInstance.hairDropdown.selected) or nil
    local head = appearanceInstance.headDropdown and appearanceInstance.headDropdown:getOptionData(appearanceInstance.headDropdown.selected).itemID or nil
    local face = appearanceInstance.faceDropdown and appearanceInstance.faceDropdown:getOptionData(appearanceInstance.faceDropdown.selected).itemID or nil
    local ears = appearanceInstance.earsDropdown and appearanceInstance.earsDropdown:getOptionData(appearanceInstance.earsDropdown.selected).itemID or nil
    local backpack = appearanceInstance.backpackDropdown and appearanceInstance.backpackDropdown:getOptionData(appearanceInstance.backpackDropdown.selected).itemID or nil
    local rightHand = nil
    local rightHandAccessory = nil
    local leftHand = nil
    local leftHandAccessory = nil
    local gloves = appearanceInstance.glovesDropdown and appearanceInstance.glovesDropdown:getOptionData(appearanceInstance.glovesDropdown.selected).itemID or nil
    local undershirt = appearanceInstance.undershirtDropdown and appearanceInstance.undershirtDropdown:getOptionData(appearanceInstance.undershirtDropdown.selected).itemID or nil
    local overshirt = appearanceInstance.overshirtDropdown and appearanceInstance.overshirtDropdown:getOptionData(appearanceInstance.overshirtDropdown.selected).itemID or nil
    local vest = appearanceInstance.vestDropdown and appearanceInstance.vestDropdown:getOptionData(appearanceInstance.vestDropdown.selected).itemID or nil
    local belt = appearanceInstance.beltDropdown and appearanceInstance.beltDropdown:getOptionData(appearanceInstance.beltDropdown.selected).itemID or nil
    local pants = appearanceInstance.pantsDropdown and appearanceInstance.pantsDropdown:getOptionData(appearanceInstance.pantsDropdown.selected).itemID or nil
    local socks = appearanceInstance.socksDropdown and appearanceInstance.socksDropdown:getOptionData(appearanceInstance.socksDropdown.selected).itemID or nil
    local shoes = appearanceInstance.shoesDropdown and appearanceInstance.shoesDropdown:getOptionData(appearanceInstance.shoesDropdown.selected).itemID or nil

    local characterData = {
        INFO_FACTION = faction,
        INFO_GENDER = gender,
        INFO_NAME = name,
        INFO_DESCRIPTION = description,
        INFO_AGE = age,
        INFO_HEIGHT = height,
        INFO_WEIGHT = weight,
        INFO_PHYSIQUE = physique,
        INFO_EYE_COLOR = eyeColor,
        INFO_HAIR_COLOR = hairColor,
        INFO_SKIN_COLOR = skinColor,
        INFO_HAIR_STYLE = hair,
        EQUIPMENT_SLOT_HEAD = head,
        EQUIPMENT_SLOT_FACE = face,
        EQUIPMENT_SLOT_EARS = ears,
        EQUIPMENT_SLOT_BACKPACK = backpack,
        EQUIPMENT_SLOT_GLOVES = gloves,
        EQUIPMENT_SLOT_UNDERSHIRT = undershirt,
        EQUIPMENT_SLOT_OVERSHIRT = overshirt,
        EQUIPMENT_SLOT_VEST = vest,
        EQUIPMENT_SLOT_BELT = belt,
        EQUIPMENT_SLOT_PANTS = pants,
        EQUIPMENT_SLOT_SOCKS = socks,
        EQUIPMENT_SLOT_SHOES = shoes,
        rightHand = rightHand,
        rightHandAccessory = rightHandAccessory,
        leftHand = leftHand,
        leftHandAccessory = leftHandAccessory,
        inventory = {}
    }

    local success, characterID = ProjectFramework.Players:CreateCharacter(self.playerObject:getUsername(), characterData)

    if success then
        ProjectFramework.Notifications:AddToQueue("Successfully created character " .. name .. " #" .. characterID .. ".")
    else
        ProjectFramework.Notifications:AddToQueue("Failed to create character.")
    end

    return true
end

function PFW_MainMenu:onEnterLoadCharacterMenu()
    local player = ProjectFramework.Players:GetPlayerByID(self.playerObject:getUsername())

    if not player then
        ProjectFramework.Notifications:AddToQueue("Failed to load characters.", nil, ProjectFramework.Notifications.Types.Danger)
        return false
    elseif #player.characters <= 0 then
        ProjectFramework.Notifications:AddToQueue("No characters found.", nil, ProjectFramework.Notifications.Types.Warning)
        return false
    end

    self:onExitMainMenu()

    if not self.loadCharacterMenu then
        local width = 800
        local height = 600
        local x = self.width / 2 - width / 2
        local y = self.height / 2 - height / 2

        self.loadCharacterMenu = PFW_LoadCharacterMenu:new(x, y, width, height, player)
        self.loadCharacterMenu:initialise()
        self:addChild(self.loadCharacterMenu)
    else
        self.loadCharacterMenu:setVisible(true)
    end

    if not self.loadCharacterBackButton then
        local widthReturn = 200
        local heightReturn = 50
        local xReturn = self.loadCharacterMenu:getX()
        local yReturn = self.loadCharacterMenu:getY() + self.loadCharacterMenu.height + 25

        self.loadCharacterBackButton = ISButton:new(xReturn, yReturn, widthReturn, heightReturn, "< Main Menu", self, self.onEnterMainMenuFromLoadCharacterMenu)
        self.loadCharacterBackButton.font = UIFont.Large
        self:addChild(self.loadCharacterBackButton)
    else
        self.loadCharacterBackButton:setVisible(true)
    end

    if not self.loadCharacterForwardButton then
        local widthLoad = 200
        local heightLoad = 50
        local xLoad = self.loadCharacterMenu:getX() + self.loadCharacterMenu.width - widthLoad
        local yLoad = self.loadCharacterMenu:getY() + self.loadCharacterMenu.height + 25

        self.loadCharacterForwardButton = ISButton:new(xLoad, yLoad, widthLoad, heightLoad, "Load Character >", self, self.onLoadCharacter)
        self.loadCharacterForwardButton.font = UIFont.Large
        self:addChild(self.loadCharacterForwardButton)
    else
        self.loadCharacterForwardButton:setVisible(true)
    end
    --self.loadCharacterMenu:addToUIManager()
end

function PFW_MainMenu:onEnterMainMenuFromLoadCharacterMenu()
    self.loadCharacterBackButton:setVisible(false)
    self.loadCharacterForwardButton:setVisible(false)
    self.loadCharacterMenu:setVisible(false)

    self:onEnterMainMenu()
end

function PFW_MainMenu:onLoadCharacter()
    
end

function PFW_MainMenu:onDisconnect()
    self:setVisible(false)
    self:removeFromUIManager()
	getCore():exitToMenu()
end

function PFW_MainMenu:prerender()
    ISPanel.prerender(self)

    local opacity = 0.25
    
    if self.shouldFlashLightning then
        opacity = 0.5
        
        if not self.hasFlashed1 then
            self:drawTextureScaled(getTexture("media/textures/lightning_1.png"), 0, 0, self.width, self.height, opacity, 1, 1, 1)
        elseif not self.hasFlashed2 then
            self:drawTextureScaled(getTexture("media/textures/lightning_2.png"), 0, 0, self.width, self.height, opacity, 1, 1, 1)
        elseif not self.hasFlashed3 then
            self:drawTextureScaled(getTexture("media/textures/lightning_1.png"), 0, 0, self.width, self.height, opacity, 1, 1, 1)
        end
        
        timer:Simple(0.05, function()
            self.hasFlashed1 = true

            timer:Simple(0.05, function()
                self.hasFlashed2 = true
                
                timer:Simple(0.05, function()
                    self.hasFlashed3 = true
                    self.shouldFlashLightning = false
                end)
            end)
        end)
    end

    self:drawTextureScaled(getTexture("media/textures/citidel.png"), 0, 0, self.width, self.height, opacity, 1, 1, 1)
end

function PFW_MainMenu:update()
    ISPanel.update(self)
end

function PFW_MainMenu:new(x, y, width, height, playerObject)
	local o = {}

	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = {r=0, g=0, b=0, a=1}
	o.borderColor = {r=0, g=0, b=0, a=1}
	o.moveWithMouse = false
	o.playerObject = playerObject
	PFW_MainMenu.instance = o

	return o
end

return PFW_MainMenu
