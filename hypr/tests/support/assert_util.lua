local M = {}

function M.deep_equal(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for k, v in pairs(a) do
        if not M.deep_equal(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

local function dump(v, indent)
    indent = indent or ""
    if type(v) ~= "table" then
        return tostring(v)
    end
    local parts = {}
    for k, val in pairs(v) do
        table.insert(parts, indent .. "  " .. tostring(k) .. " = " .. dump(val, indent .. "  "))
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
end

function M.equal(actual, expected, msg)
    if not M.deep_equal(actual, expected) then
        error((msg or "values differ") .. "\nexpected: " .. dump(expected) .. "\nactual:   " .. dump(actual), 2)
    end
end

function M.truthy(v, msg)
    if not v then
        error(msg or "expected truthy value", 2)
    end
end

return M
