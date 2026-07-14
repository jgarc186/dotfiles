-- Run with: luajit hypr/tests/run_tests.lua

local this_dir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
local hypr_root = this_dir .. "../"

package.path = this_dir .. "?.lua;"
    .. this_dir .. "support/?.lua;"
    .. hypr_root .. "?.lua;"
    .. package.path

local tests = {
    "test_programs",
    "test_monitors",
    "test_environment",
    "test_permissions",
    "test_autostart",
    "test_animations",
    "test_input",
    "test_workspaces",
    "test_binds",
    "test_hyprland_entry",
}

local passed, failed = 0, 0
for _, name in ipairs(tests) do
    package.loaded[name] = nil
    local ok, err = pcall(function()
        require(name)
    end)
    if ok then
        passed = passed + 1
        print("PASS  " .. name)
    else
        failed = failed + 1
        print("FAIL  " .. name)
        print("      " .. tostring(err))
    end
end

print(string.format("\n%d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
