if not isClient() then return end

ProjectFramework = ProjectFramework or {}

ProjectFramework.Notifications = {}
ProjectFramework.Notifications.__index = ProjectFramework.Notifications
ProjectFramework.Notifications.Queue = {}
ProjectFramework.Notifications.List = {}
ProjectFramework.Notifications.Types = {
    Default = "Default",
    Info = "Info",
    Warning = "Warning",
    Danger = "Danger"
}
ProjectFramework.Notifications.Colors = {
    Default = {r = 1, g = 1, b = 1, a = 0.5},
    Info = {r = 0.051, g = 0.792, b = 0.941, a = 0.5},
    Warning = {r = 1, g = 0.757, b = 0.027, a = 0.5},
    Danger = {r = 0.863, g = 0.208, b = 0.271, a = 0.5}
}
ProjectFramework.Notifications = ProjectFramework.Foundation:NewModule(ProjectFramework.Notifications, "Notifications")

function ProjectFramework.Notifications:ProcessQueue(isProcessingContinued)
    if not (isProcessingContinued or not self.isProcessing) and not (#self.Queue > 0 or #self.List > 0) then return false end
    
    if isProcessingContinued or not self.isProcessing then
        if #self.Queue > 0 then
            self.isProcessing = true
            local queuedNotification = self.Queue[1]

            queuedNotification:initialise()
            queuedNotification:addToUIManager()

            local player = ProjectFramework.Players:GetPlayerByID(getPlayer():getUsername())
            if player then player:PlayLocalSound("pfw_lightswitch2") end

            table.remove(self.Queue, 1)
            table.insert(self.List, 1, queuedNotification)

            if #self.List > 1 then
                for i = 2, #self.List, 1 do
                    local position = i - 1
                    local topNotification = self.List[1]
                    local notification = self.List[i]
                    notification:setY(topNotification:getY() + notification:getHeight() * position + 10 * position)
                end
            end

            timer:Simple(1, function()
                self.isProcessing = self:ProcessQueue(true)
            end)

            return true
        elseif #self.List > 0 then
            self.isProcessing = true
            local processingID = nil

            for i = 1, #self.List, 1 do
                local notification = self.List[i]
                local expired = notification.hasExpired

                if expired then
                    notification.isExpiring = true
                    processingID = i
                    break
                end
            end

            if not processingID then return false end

            local processingNotification = self.List[processingID]

            timer:Create("NotificationFadeOut", 0, 0, function()
                if processingNotification.isExpiring and processingNotification.textLabel.a > 0 then
                    processingNotification.backgroundColor.a = processingNotification.backgroundColor.a - processingNotification.originalAlpha * 0.01
                    processingNotification.borderColor.a = processingNotification.borderColor.a - processingNotification.originalAlpha * 0.01
                    processingNotification.textLabel.a = processingNotification.textLabel.a - 1 * 0.01
                elseif processingNotification.isExpiring and timer:Exists("NotificationFadeOut") then
                    timer:Remove("NotificationFadeOut")
                    processingNotification.hasFullyExpired = true
                    processingNotification.backgroundColor.a = 0
                    processingNotification.borderColor.a = 0
                    processingNotification.textLabel.a = 0

                    timer:Simple(0.5, function()
                        for i = processingID, #self.List, 1 do
                            local notification = self.List[i]

                            if not notification.isExpiring then
                                notification:setY(notification:getY() - (processingNotification:getHeight() + 10))
                            end
                        end

                        processingNotification:removeFromUIManager()
                        table.remove(self.List, processingID)

                        timer:Simple(1, function()
                            self.isProcessing = self:ProcessQueue(true)
                        end)
                    end)
                elseif not processingNotification.hasFullyExpired and not processingNotification.isExpiring then
                    timer:Remove("NotificationFadeOut")
                    processingNotification.backgroundColor.a = math.min(processingNotification.originalAlpha + 0.25, 1)
                    processingNotification.borderColor.a = processingNotification.originalAlpha
                    processingNotification.textLabel.a = 1

                    timer:Simple(1, function()
                        self.isProcessing = self:ProcessQueue(true)
                    end)
                end
            end)

            return true
        end
    end
end

function ProjectFramework.Notifications:AddToQueue(message, duration, type)
    local notification = PFW_Notification:new(type and type or ProjectFramework.Notifications.Types.Default, message, duration and duration or 10, getPlayer())

    table.insert(self.Queue, notification)
end

function ProjectFramework.Notifications:OnGameStart()
    timer:Create("NotificationTick", 1, 0, function()
        if not self.isProcessing then
            self.isProcessing = self:ProcessQueue(false)
        end
    end)
end
