--! \brief Utility module for FrameworkZ. Contains utility functions and classes.
--! \class FrameworkZ.Utility
FrameworkZ.Utilities = {}
FrameworkZ.Utilities.__index = FrameworkZ.Utilities
FrameworkZ.Utilities = FrameworkZ.Foundation:NewModule(FrameworkZ.Utilities, "Utilities")

--! \brief Copies a table.
--! \param \table originalTable The table to copy.
--! \param \table tableCopies (Internal) The table of copies used internally by the function.
--! \return \table The copied table.
function FrameworkZ.Utilities:CopyTable(originalTable, tableCopies)
    tableCopies = tableCopies or {}

    local originalType = type(originalTable)
    local copy

    if originalType == "table" then
        if tableCopies[originalTable] then
            copy = tableCopies[originalTable]
        else
            copy = {}
            tableCopies[originalTable] = copy

            for originalKey, originalValue in pairs(originalTable) do
                copy[self:CopyTable(originalKey, tableCopies)] = self:CopyTable(originalValue, tableCopies)
            end

            setmetatable(copy, self:CopyTable(getmetatable(originalTable), tableCopies))
        end
    else -- number, string, boolean, etc
        copy = originalTable
    end

    return copy
end
