ProjectFramework = ProjectFramework or {}

ProjectFramework.Classes = {}
ProjectFramework.Classes.__index = ProjectFramework.Classes
ProjectFramework.Classes.List = {}
ProjectFramework.Classes = ProjectFramework.Foundation:NewModule(ProjectFramework.Classes, "Classes")

local CLASS = {}
CLASS.__index = CLASS

function CLASS:Initialize()
	return ProjectFramework.Classes:Initialize(self.name, self)
end

function ProjectFramework.Classes:New(name)
    local object = {
        id = name,
        name = name,
        description = "No description available.",
        limit = 0,
        members = {}
    }

    setmetatable(object, CLASS)

	return object
end

function ProjectFramework.Classes:Initialize(id, object)
    self.List[id] = object

    return id
end

function ProjectFramework.Classes:GetClassByID(factionID)
    local class = self.List[factionID] or nil
    
    return class
end
