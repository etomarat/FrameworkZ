FrameworkZ = FrameworkZ or {}
FrameworkZ.PreConfig = {}

function FrameworkZ.PreConfig.onChatWindowInit()
    ISChat.instance:setVisible(false)
end
Events.OnChatWindowInit.Add(FrameworkZ.PreConfig.onChatWindowInit)
