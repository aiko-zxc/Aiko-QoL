local addonName, ns = ...

local PathUtils = {}
ns.Core.PathUtils = PathUtils

function PathUtils:Split(path)
    local keys = {}
    for key in string.gmatch(path, "([^.]+)") do
        keys[#keys + 1] = key
    end
    return keys
end
