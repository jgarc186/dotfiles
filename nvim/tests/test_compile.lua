-- Compiles (but never executes) every config .lua file. loadfile() parses
-- the file and returns nil + error on a syntax error, so this catches the
-- most common agent regression — a typo/broken Lua — across ALL files,
-- including the per-plugin config files that can't be executed here because
-- their plugins aren't installed in the headless test environment.
local A = require("support.assert_util")
local H = require("support.harness")

local files = { H.path("init.lua") }
for _, f in ipairs(H.lua_files("lua")) do
    table.insert(files, f)
end

A.truthy(#files > 1, "found no lua files to compile")

local failures = {}
for _, f in ipairs(files) do
    local chunk, err = loadfile(f)
    if not chunk then
        table.insert(failures, f .. "\n    " .. tostring(err))
    end
end

if #failures > 0 then
    error("syntax errors in " .. #failures .. " file(s):\n  " ..
        table.concat(failures, "\n  "))
end
