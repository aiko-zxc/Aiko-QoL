local addonName, ns = ...

local TableUtils = {}
ns.Core.TableUtils = TableUtils

function TableUtils:DeepCopy(value)
    if value == nil then
        return nil
    end

    if CopyTable and type(value) == "table" then
        return CopyTable(value)
    end

    local function copy(input)
        if type(input) ~= "table" then
            return input
        end

        local result = {}
        for k, v in pairs(input) do
            result[k] = copy(v)
        end
        return result
    end

    return copy(value)
end

function TableUtils:EnsureTable(parent, key, fallback)
    if type(parent[key]) ~= "table" then
        if type(fallback) == "table" then
            parent[key] = self:DeepCopy(fallback)
        else
            parent[key] = {}
        end
    end
end
