-- Assertion helpers for the Neovim config test suite.
-- Mirrors hypr/tests/support/assert_util.lua so both suites read the same.
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
        error((msg or "values differ")
            .. "\nexpected: " .. dump(expected)
            .. "\nactual:   " .. dump(actual), 2)
    end
end

function M.truthy(v, msg)
    if not v then
        error(msg or "expected truthy value", 2)
    end
end

function M.falsy(v, msg)
    if v then
        error((msg or "expected falsy value") .. "\nactual: " .. dump(v), 2)
    end
end

-- Asserts that `haystack` (string) contains `needle` (plain substring).
function M.contains(haystack, needle, msg)
    if type(haystack) ~= "string" or not haystack:find(needle, 1, true) then
        error((msg or "substring not found")
            .. "\nlooking for: " .. tostring(needle)
            .. "\nin:          " .. tostring(haystack), 2)
    end
end

return M
