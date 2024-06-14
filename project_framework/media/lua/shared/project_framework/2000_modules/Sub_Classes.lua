ProjectFramework = ProjectFramework or {}

ProjectFramework.SubClasses = {}
ProjectFramework.SubClasses.__index = ProjectFramework.SubClasses
ProjectFramework.SubClasses.List = {}
ProjectFramework.SubClasses = ProjectFramework.Foundation:NewModule(ProjectFramework.SubClasses, "Sub Classes")

local SUBCLASS = {}
SUBCLASS.__index = SUBCLASS

function SUBCLASS:Initialize()
	return ProjectFramework.SubClasses:Initialize(self.name, self)
end

function ProjectFramework.SubClasses:New(name)
    local object = {
        id = name,
        name = name,
        description = "No description available.",
        limit = 0,
        members = {}
    }

    setmetatable(object, SUBCLASS)

	return object
end

function ProjectFramework.SubClasses:Initialize(id, object)
    self.List[id] = object

    return id
end

function ProjectFramework.Factions:GetClassByID(factionID)
    local class = self.List[factionID] or nil
    
    return class
end
