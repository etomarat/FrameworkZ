if not isClient() then return end

ProjectFramework = ProjectFramework or {}

ProjectFramework.Notifications = {}
ProjectFramework.Notifications.__index = ProjectFramework.Notifications
ProjectFramework.Notifications.List = {}
ProjectFramework.Notifications.Types = {
    Info = "Info",
    Warning = "Warning",
    Error = "Error"
}
ProjectFramework.Notifications = ProjectFramework.Foundation:NewModule(ProjectFramework.Notifications, "Notifications")

function ProjectFramework.Notifications:Add(type, message, duration)
    local notification = {
        type = type,
        message = message,
        duration = duration,
        fadeTime = 1, -- The time it takes for the notification to fade out in seconds
        fadeTimer = 0 -- The current fade timer
    }

    table.insert(self.List, 1, notification)
end
