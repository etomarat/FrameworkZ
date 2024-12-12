require "OptionScreens/ConnectToServer"

FrameworkZ = FrameworkZ or {}
FrameworkZ.PreConfig = {}

function FrameworkZ.PreConfig.onChatWindowInit()
    ISChat.instance:setVisible(false)
end
Events.OnChatWindowInit.Add(FrameworkZ.PreConfig.onChatWindowInit)

ConnectToServer.OnConnected = function(self)
	if not SystemDisabler.getAllowDebugConnections() and getDebug() and not isAdmin() and not isCoopHost() and not SystemDisabler.getOverrideServerConnectDebugCheck() then
		forceDisconnect()
		return
	end
	connectionManagerLog("connect-state-finish", "lua-connected");
	self.connecting = false
	self:setVisible(false)
	if not checkSavePlayerExists() then
		if not getWorld():getMap() then
            getWorld():setMap("Muldraugh, KY")
        end

        if MainScreen.instance.createWorld then
            createWorld(getWorld():getWorld())
        end

        GameWindow.doRenderEvent(false)
        forceChangeState(LoadingQueueState.new())
	else
		GameWindow.doRenderEvent(false)
		forceChangeState(LoadingQueueState.new())
	end
end