--! \mainpage Main Page
--! Created By RJ_RayJay
--! \section Introduction
--! Project HL2RP is a roleplay framework for the game Project Zomboid. This framework is designed to be a base for roleplay servers, providing a variety of features and systems to help server owners create a unique and enjoyable roleplay experience for their players. We have plans to make a standalone framework for Project Zomboid, but for now, we are focusing on the Project HL2RP framework integrated with the HL2RP gamemode.
--! \section Features
--! The Project HL2RP framework includes a variety of features and systems to help server owners create a unique and enjoyable roleplay experience for their players. Some of the features and systems include:
--! - Characters
--! - Factions
--! - Entities
--! - Items
--! - Inventories
--! - Trading
--! - Crafting
--! - Skills
--! - Vehicles
--! - Housing
--! - Jobs
--! - Quests
--! - Events
--! - Admin
--! - ...and more!
--! \section Installation
--! To install the Project HL2RP framework, simply download the latest release from the Steam Workshop and add the Workshop ID/Mod ID into your Project Zomboid server's config file. After installing, you can start your server and the framework will be ready to use.
--! \section Usage
--! The Project HL2RP framework is designed to be easy to use and extend. The framework is built using Lua, a lightweight, multi-paradigm programming language designed primarily for embedded use in applications. The framework is designed to be modular, allowing server owners to easily add, remove, and modify features and systems to suit their needs. The framework also includes extensive documentation to help server owners understand how to use and extend the framework.
--! \section Contributing
--! The Project HL2RP framework is an open-source project and we welcome contributions from the community. If you would like to contribute to the framework, you can do so by forking the GitHub repository, making your changes, and submitting a pull request. We also welcome bug reports, feature requests, and feedback from the community. If you have any questions or need help with the framework, you can join the Project HL2RP Discord server and ask for assistance in the #support channel.
--! \section License
--! The Project HL2RP framework is licensed under the MIT License, a permissive open-source license that allows you to use, modify, and distribute the framework for free. You can find the full text of the MIT License in the LICENSE file included with the framework. We chose the MIT License because we believe in the power of open-source software and want to encourage collaboration and innovation in the Project Zomboid community.
--! \section Support
--! If you need help with the Project HL2RP framework, you can join the Project HL2RP Discord server and ask for assistance in the #support channel. We have a friendly and knowledgeable community that is always willing to help with any questions or issues you may have. We also have a variety of resources available to help you get started with the framework, including documentation, tutorials, and example code.
--! \section Conclusion
--! The Project HL2RP framework is a powerful and flexible tool for creating roleplay servers in Project Zomboid. Whether you are a server owner looking to create a unique roleplay experience for your players or a developer looking to contribute to an open-source project, the Project HL2RP framework has something for everyone. We hope you enjoy using the framework and look forward to seeing the amazing roleplay experiences you create with it.
--! \section Links
--! - GitHub Repository: Coming Soon(tm)
--! - Discord Server: https://discord.gg/dEZwKHPeWZ
--! - Documentation: https://projectframework-docs.pixelport.community
--! - Tutorials: Coming Soon(tm)
--! - Example Code: Coming Soon(tm)

--! \page globalVars Global Variables
--! \section FrameworkZ FrameworkZ
--! FrameworkZ
--! The global table that contains all of the framework.
--! [table]: /var_types.html#table "table"
--! \page varTypes Variable Types
--! \section string string
--! A string is a sequence of characters. Strings are used to represent text and are enclosed in double quotes or single quotes.
--! \section boolean boolean
--! A boolean is a value that can be either true or false. Booleans are used to represent logical values.
--! \section integer integer
--! A integer is a numerical value without any decimal points.
--! \section float float
--! A float is a numerical value with decimal points.
--! \section table table
--! A table is a collection of key-value pairs. It is the only data structure available in Lua that allows you to store data with arbitrary keys and values. Tables are used to represent arrays, sets, records, and other data structures.
--! \section function function
--! A function is a block of code that can be called and executed. Functions are used to encapsulate and reuse code.
--! \section nil nil
--! Nil is a special value that represents the absence of a value. Nil is used to indicate that a variable has no value.
--! \section any any
--! Any is a placeholder that represents any type of value. It is used to indicate that a variable can hold any type of value.
--! \section mixed mixed
--! Mixed is a placeholder that represents a combination of different types of values. It is used to indicate that a variable can hold a variety of different types of values.
--! \section class class
--! Class is a placeholder that represents a class of objects by a table set to a metatable.

local Events = Events
local isClient = isClient

--! \brief FrameworkZ global table.
--! \class FrameworkZ
FrameworkZ = FrameworkZ or {}

--! \brief Foundation for FrameworkZ.
--! \class Foundation
--! \memberof FrameworkZ
FrameworkZ.Foundation = {}

--FrameworkZ.Foundation.__index = FrameworkZ.Foundation

--! \brief Modules for FrameworkZ.
--! \memberof FrameworkZ
FrameworkZ.Modules = {}

--! \brief Create a new instance of the FrameworkZ Framework.
--! \return \table The new instance of the FrameworkZ Framework.
function FrameworkZ.Foundation.New()
    local object = {
        version = FrameworkZ.Config.Version
    }
    object.__index = FrameworkZ.Foundation

    setmetatable(object, FrameworkZ.Foundation)

	return object
end

--! \brief Create a new module for the FrameworkZ Framework.
--! \param MODULE_TABLE \table The table to use as the module.
--! \param moduleName \string The name of the module.
--! \return \table The new module.
function FrameworkZ.Foundation:NewModule(moduleObject, moduleName)
	if (not FrameworkZ.Modules[moduleName]) then
		local object = {}
		moduleObject.__index = moduleObject
		setmetatable(object, moduleObject)
		FrameworkZ.Modules[moduleName] = object
		--FrameworkZ.Foundation:RegisterModuleHandler(object)
	end

	return FrameworkZ.Modules[moduleName]
end

function FrameworkZ.Foundation:GetModule(moduleName)
    return FrameworkZ.Modules[moduleName]
end

function FrameworkZ.Foundation:RegisterFramework()
	FrameworkZ.Foundation:RegisterFrameworkHandler()
end

function FrameworkZ.Foundation:RegisterModule(module)
	FrameworkZ.Foundation:RegisterModuleHandler(module)
end

--! \brief Get the version of the FrameworkZ Framework.
--! \return \string The version of the FrameworkZ Framework.
function FrameworkZ.Foundation:GetVersion()
    return self.version
end

FrameworkZ.Foundation = FrameworkZ.Foundation.New()

--[[
    PROJECT FRAMEWORK
    HOOKS SYSTEM
--]]

HOOK_CATEGORY_FRAMEWORK = "framework"
HOOK_CATEGORY_MODULE = "module"
HOOK_CATEGORY_GAMEMODE = "gamemode"
HOOK_CATEGORY_PLUGIN = "plugin"
HOOK_CATEGORY_GENERIC = "generic"

FrameworkZ.Foundation.HookHandlers = {
    framework = {},
    module = {},
    gamemode = {},
    plugin = {},
    generic = {}
}

FrameworkZ.Foundation.RegisteredHooks = {
    framework = {},
    module = {},
    gamemode = {},
    plugin = {},
    generic = {}
}

--! \brief Add a new hook handler to the list.
--! \param hookName \string The name of the hook handler to add.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:AddHookHandler(hookName, category)
    category = category or HOOK_CATEGORY_GENERIC
    self.HookHandlers[category][hookName] = true
end

--! \brief Add a new hook handler to the list for all categories.
--! \param hookName \string The name of the hook handler to add.
function FrameworkZ.Foundation:AddAllHookHandlers(hookName)
    FrameworkZ.Foundation:AddHookHandler(hookName, HOOK_CATEGORY_FRAMEWORK)
    FrameworkZ.Foundation:AddHookHandler(hookName, HOOK_CATEGORY_MODULE)
    FrameworkZ.Foundation:AddHookHandler(hookName, HOOK_CATEGORY_GAMEMODE)
    FrameworkZ.Foundation:AddHookHandler(hookName, HOOK_CATEGORY_PLUGIN)
    FrameworkZ.Foundation:AddHookHandler(hookName, HOOK_CATEGORY_GENERIC)
end

--! \brief Remove a hook handler from the list.
--! \param hookName \string The name of the hook handler to remove.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:RemoveHookHandler(hookName, category)
    category = category or HOOK_CATEGORY_GENERIC
    self.HookHandlers[category][hookName] = nil
end

--! \brief Register hook handlers for the framework.
--! \param framework \table The framework table containing the functions.
function FrameworkZ.Foundation:RegisterFrameworkHandler()
    self:RegisterHandlers(self, HOOK_CATEGORY_FRAMEWORK)
end

--! \brief Unregister hook handlers for the framework.
--! \param framework \table The framework table containing the functions.
function FrameworkZ.Foundation:UnregisterFrameworkHandler()
    self:UnregisterHandlers(self, HOOK_CATEGORY_FRAMEWORK)
end

--! \brief Register hook handlers for a module.
--! \param module \table The module table containing the functions.
function FrameworkZ.Foundation:RegisterModuleHandler(module)
    self:RegisterHandlers(module, HOOK_CATEGORY_MODULE)
end

--! \brief Unregister hook handlers for a module.
--! \param module \table The module table containing the functions.
function FrameworkZ.Foundation:UnregisterModuleHandler(module)
    self:UnregisterHandlers(module, HOOK_CATEGORY_MODULE)
end

--! \brief Register hook handlers for the gamemode.
--! \param module \table The module table containing the functions.
function FrameworkZ.Foundation:RegisterGamemodeHandler(gamemode)
    self:RegisterHandlers(gamemode, HOOK_CATEGORY_GAMEMODE)
end

--! \brief Unregister hook handlers for the gamemode.
--! \param module \table The module table containing the functions.
function FrameworkZ.Foundation:UnregisterGamemodeHandler(gamemode)
    self:UnregisterHandlers(gamemode, HOOK_CATEGORY_GAMEMODE)
end

--! \brief Register hook handlers for a plugin.
--! \param plugin \table The plugin table containing the functions.
function FrameworkZ.Foundation:RegisterPluginHandler(plugin)
    self:RegisterHandlers(plugin, HOOK_CATEGORY_PLUGIN)
end

--! \brief Unregister hook handlers for a plugin.
--! \param plugin \table The plugin table containing the functions.
function FrameworkZ.Foundation:UnregisterPluginHandler(plugin)
    self:UnregisterHandlers(plugin, HOOK_CATEGORY_PLUGIN)
end

--! \brief Register hook handlers for a plugin.
--! \param plugin \table The plugin table containing the functions.
function FrameworkZ.Foundation:RegisterGenericHandler()
    self:RegisterHandlers(nil, HOOK_CATEGORY_GENERIC)
end

--! \brief Unregister hook handlers for a plugin.
--! \param plugin \table The plugin table containing the functions.
function FrameworkZ.Foundation:UnregisterGenericHandler()
    self:UnregisterHandlers(nil, HOOK_CATEGORY_GENERIC)
end

--! \brief Register handlers for a specific category.
--! \param object \table The object containing the functions.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:RegisterHandlers(objectOrHandlers, category)
    category = category or HOOK_CATEGORY_GENERIC
    if not self.HookHandlers[category] then
        error("Invalid category: " .. tostring(category))
    end

    -- Iterate over the hook names using pairs since HookHandlers is now a dictionary
    for hookName, _ in pairs(self.HookHandlers[category]) do
        if objectOrHandlers and type(objectOrHandlers) == "table" then
            -- Check if the object/table has a function for the hookName
            local handlerFunction = objectOrHandlers[hookName]
            if handlerFunction and type(handlerFunction) == "function" then
                self:RegisterHandler(hookName, handlerFunction, objectOrHandlers, hookName, category)
            end
        else
            -- objectOrHandlers is nil or not a table
            -- Try to get the function from the global environment
            local handler = _G[hookName]
            if handler and type(handler) == "function" then
                self:RegisterHandler(hookName, handler, nil, nil, category)
            end
        end
    end
end

--! \brief Unregister handlers for a specific category.
--! \param object \table The object containing the functions.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:UnregisterHandlers(objectOrHandlers, category)
    category = category or HOOK_CATEGORY_GENERIC
    if not self.HookHandlers[category] then
        error("Invalid category: " .. tostring(category))
    end

    for hookName, _ in pairs(self.HookHandlers[category]) do
        if objectOrHandlers and type(objectOrHandlers) == "table" then
            local handlerFunction = objectOrHandlers[hookName]
            if handlerFunction and type(handlerFunction) == "function" then
                self:UnregisterHandler(hookName, handlerFunction, objectOrHandlers, hookName, category)
            end
        else
            local handler = _G[hookName]
            if handler and type(handler) == "function" then
                self:UnregisterHandler(hookName, handler, nil, nil, category)
            end
        end
    end
end

--! \brief Register a handler for a hook.
--! \param hookName \string The name of the hook.
--! \param handler \function The function to call when the hook is executed.
--! \param object \table (Optional) The object containing the function.
--! \param functionName \string (Optional) The name of the function to call.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:RegisterHandler(hookName, handler, object, functionName, category)
    category = category or HOOK_CATEGORY_GENERIC
    self.RegisteredHooks[category][hookName] = self.RegisteredHooks[category][hookName] or {}

    if object and functionName then
        table.insert(self.RegisteredHooks[category][hookName], {
            handler = function(...)
                object[functionName](object, ...)
            end,
            object = object,
            functionName = functionName
        })
    else
        table.insert(self.RegisteredHooks[category][hookName], handler)
    end
end


--! \brief Unregister a handler from a hook.
--! \param hookName \string The name of the hook.
--! \param handler \function The function to unregister.
--! \param object \table (Optional) The object containing the function.
--! \param functionName \string (Optional) The name of the function to unregister.
--! \param category \string The category of the hook (framework, module, plugin, generic).
function FrameworkZ.Foundation:UnregisterHandler(hookName, handler, object, functionName, category)
    category = category or HOOK_CATEGORY_GENERIC
    local hooks = self.RegisteredHooks[category] and self.RegisteredHooks[category][hookName]
    if hooks then
        for i = #hooks, 1, -1 do
            if object and functionName then
                if hooks[i].object == object and hooks[i].functionName == functionName then
                    table.remove(hooks, i)
                    break
                end
            else
                if hooks[i] == handler then
                    table.remove(hooks, i)
                    break
                end
            end
        end
    end
end

--! \brief Execute hooks.
--! \param hookName \string The name of the hook.
--! \param category \string The category of the hook (framework, module, plugin, generic).
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteHook(hookName, category, ...)
    category = category or HOOK_CATEGORY_GENERIC
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--! \brief Execute all of the hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteAllHooks(hookName, ...)
    for category, _ in pairs(FrameworkZ.Foundation.RegisteredHooks) do
        FrameworkZ.Foundation.ExecuteHook(hookName, category, ...)
    end
end

--! \brief Execute the framework hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteFrameworkHooks(hookName, ...)
    local category = HOOK_CATEGORY_FRAMEWORK
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--! \brief Execute module hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteModuleHooks(hookName, ...)
    local category = HOOK_CATEGORY_MODULE
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--! \brief Execute the gamemode hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteGamemodeHooks(hookName, ...)
    local category = HOOK_CATEGORY_GAMEMODE
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--! \brief Execute plugin hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecutePluginHooks(hookName, ...)
    local category = HOOK_CATEGORY_PLUGIN
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--! \brief Execute generic hooks.
--! \param hookName \string The name of the hook.
--! \param ... \vararg Additional arguments to pass to the hook functions.
function FrameworkZ.Foundation.ExecuteGenericHooks(hookName, ...)
    local category = HOOK_CATEGORY_GENERIC
    if FrameworkZ.Foundation.RegisteredHooks[category] and FrameworkZ.Foundation.RegisteredHooks[category][hookName] then
        for _, func in ipairs(FrameworkZ.Foundation.RegisteredHooks[category][hookName]) do
            if type(func) == "table" and func.handler then
                if select("#", ...) == 0 then
                    func.handler()
                else
                    func.handler(...)
                end
            else
                if select("#", ...) == 0 then
                    func()
                else
                    func(...)
                end
            end
        end
    end
end

--[[
	PROJECT FRAMEWORK
	HOOKS ADDITIONS
--]]


--! \brief Called when the game starts. Executes the OnGameStart function for all modules.
function FrameworkZ.Foundation:OnGameStart()
    FrameworkZ.Foundation.ExecuteFrameworkHooks("PreInitializeClient", getPlayer())
end

function FrameworkZ.Foundation:PreInitializeClient(isoPlayer)
    FrameworkZ.Foundation.ExecuteModuleHooks("PreInitializeClient", isoPlayer)
    FrameworkZ.Foundation.ExecuteGamemodeHooks("PreInitializeClient", isoPlayer)
    FrameworkZ.Foundation.ExecutePluginHooks("PreInitializeClient", isoPlayer)

    FrameworkZ.Foundation.ExecuteFrameworkHooks("InitializeClient", isoPlayer)
end
FrameworkZ.Foundation:AddAllHookHandlers("PreInitializeClient")

function FrameworkZ.Foundation:InitializeClient(isoPlayer)
    timer:Simple(FrameworkZ.Config.InitializationDuration, function()
        FrameworkZ.Foundation.ExecuteModuleHooks("InitializeClient", isoPlayer)
        FrameworkZ.Foundation.ExecuteGamemodeHooks("InitializeClient", isoPlayer)
        FrameworkZ.Foundation.ExecutePluginHooks("InitializeClient", isoPlayer)

        FrameworkZ.Foundation.ExecuteFrameworkHooks("PostInitializeClient", isoPlayer)
    end)
end
FrameworkZ.Foundation:AddAllHookHandlers("InitializeClient")

function FrameworkZ.Foundation:PostInitializeClient(isoPlayer)
    FrameworkZ.Foundation.ExecuteModuleHooks("PostInitializeClient", isoPlayer)
    FrameworkZ.Foundation.ExecuteGamemodeHooks("PostInitializeClient", isoPlayer)
    FrameworkZ.Foundation.ExecutePluginHooks("PostInitializeClient", isoPlayer)
end
FrameworkZ.Foundation:AddAllHookHandlers("PostInitializeClient")

function FrameworkZ.Foundation:OnMainMenuEnter()
    FrameworkZ.Foundation.ExecuteFrameworkHooks("OnOpenEscapeMenu", getPlayer())
end

function FrameworkZ.Foundation:OnOpenEscapeMenu(isoPlayer)
    FrameworkZ.Foundation.ExecuteModuleHooks("OnOpenEscapeMenu", isoPlayer)
    FrameworkZ.Foundation.ExecuteGamemodeHooks("OnOpenEscapeMenu", isoPlayer)
    FrameworkZ.Foundation.ExecutePluginHooks("OnOpenEscapeMenu", isoPlayer)
end
FrameworkZ.Foundation:AddAllHookHandlers("OnOpenEscapeMenu")

if not isClient() then

	--! \brief Called when the server starts. Executes the OnServerStarted function for all modules.
	function FrameworkZ.Foundation.OnServerStarted()
		for k, v in pairs(FrameworkZ.Modules) do
			if v.OnServerStarted then
				v.OnServerStarted(v)
			end
		end
	end
	Events.OnServerStarted.Add(FrameworkZ.Foundation.OnServerStarted)

end
