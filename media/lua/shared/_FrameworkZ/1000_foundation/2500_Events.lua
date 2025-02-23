local Events = Events

FrameworkZ = FrameworkZ or {}

function FrameworkZ.OnClientCommand(module, command, isoPlayer, args)
    FrameworkZ.Foundation.ExecuteAllHooks("OnConnected", module, command, isoPlayer, args)
end
Events.OnClientCommand.Add(FrameworkZ.OnClientCommand)

function FrameworkZ.OnConnected()
    FrameworkZ.Foundation.ExecuteAllHooks("OnConnected")
end
Events.OnConnected.Add(FrameworkZ.OnConnected)

function FrameworkZ.OnFillInventoryObjectContextMenu(player, context, items)
    FrameworkZ.Foundation.ExecuteAllHooks("OnFillInventoryObjectContextMenu", player, context, items)
end
Events.OnFillInventoryObjectContextMenu.Add(FrameworkZ.OnFillInventoryObjectContextMenu)
FrameworkZ.Foundation:AddAllHookHandlers("OnFillInventoryObjectContextMenu")

function FrameworkZ.OnInitGlobalModData()
    FrameworkZ.Foundation.ExecuteAllHooks("OnInitGlobalModData")
end
Events.OnInitGlobalModData.Add(FrameworkZ.OnInitGlobalModData)

function FrameworkZ.OnMainMenuEnter()
    FrameworkZ.Foundation.ExecuteAllHooks("OnMainMenuEnter")
end
Events.OnMainMenuEnter.Add(FrameworkZ.OnMainMenuEnter)

function FrameworkZ.OnPlayerDeath(player)
    FrameworkZ.Foundation.ExecuteAllHooks("OnPlayerDeath")
end
Events.OnPlayerDeath.Add(FrameworkZ.OnPlayerDeath)
FrameworkZ.Foundation:AddAllHookHandlers("OnPlayerDeath")

function FrameworkZ.OnGameStart()
    FrameworkZ.Foundation.ExecuteAllHooks("OnGameStart")
end
Events.OnGameStart.Add(FrameworkZ.OnGameStart)
FrameworkZ.Foundation:AddAllHookHandlers("OnGameStart")

function FrameworkZ.LoadGridsquare(square)
    FrameworkZ.Foundation.ExecuteAllHooks("LoadGridsquare")

    --[[for k, v in pairs(FrameworkZ.Modules) do
        if v.LoadGridsquare then
            v.LoadGridsquare(v, square)
        end
    end--]]
end
Events.LoadGridsquare.Add(FrameworkZ.Foundation.LoadGridsquare)
FrameworkZ.Foundation:AddAllHookHandlers("LoadGridsquare")

function FrameworkZ.OnDisconnect()
    FrameworkZ.Foundation.ExecuteAllHooks("OnDisconnect")
end
Events.OnDisconnect.Add(FrameworkZ.OnDisconnect)
FrameworkZ.Foundation:AddAllHookHandlers("OnDisconnect")

--[[
function FrameworkZ.Foundation.OnFillInventoryObjectContextMenu(playerID, context, items)
    FrameworkZ.Foundation.ExecuteAllHooks("LoadGridsquare")

    for k, v in pairs(FrameworkZ.Modules) do
        if v.OnFillInventoryObjectContextMenu then
            v.OnFillInventoryObjectContextMenu(v, playerID, context, items)
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(FrameworkZ.OnFillInventoryObjectContextMenu)
FrameworkZ.Foundation:AddAllHookHandlers("OnFillInventoryObjectContextMenu")
--]]

function FrameworkZ.OnPreFillInventoryObjectContextMenu(playerID, context, items)
    FrameworkZ.Foundation.ExecuteAllHooks("OnPreFillInventoryObjectContextMenu")

    --[[for k, v in pairs(FrameworkZ.Modules) do
        if v.OnPreFillInventoryObjectContextMenu then
            v.OnPreFillInventoryObjectContextMenu(v, playerID, context, items)
        end
    end--]]
end
Events.OnPreFillInventoryObjectContextMenu.Add(FrameworkZ.OnPreFillInventoryObjectContextMenu)
FrameworkZ.Foundation:AddAllHookHandlers("OnPreFillInventoryObjectContextMenu")
