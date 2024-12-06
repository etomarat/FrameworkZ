local getCore = getCore
local getPlayer = getPlayer
local getWorld = getWorld

FrameworkZ = FrameworkZ or {}
FrameworkZ.Hooks = {}
FrameworkZ.Hooks = FrameworkZ.Foundation:NewModule(FrameworkZ.Hooks, "Hooks")

if isClient() then
    function FrameworkZ.Hooks:InitializeClient()
        local cell = getWorld():getCell()
        local x = cell:getMaxX()
        local y = cell:getMaxY()
        local z = 0
        local isoPlayer = getPlayer()
        isoPlayer:setInvincible(true)
        isoPlayer:setInvisible(true)
        isoPlayer:setGhostMode(true)
        isoPlayer:setNoClip(true)
        isoPlayer:setX(x)
        isoPlayer:setY(y)
        isoPlayer:setZ(z)
	    isoPlayer:setLx(x)
	    isoPlayer:setLy(y)
	    isoPlayer:setLz(z)

        local ui = PFW_Introduction:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight(), getPlayer())
        ui:initialise()
        ui:addToUIManager()
    end
end

FrameworkZ.Foundation:RegisterModule(FrameworkZ.Hooks)
FrameworkZ.Foundation:RegisterFramework()