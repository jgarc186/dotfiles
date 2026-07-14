-- Neovim config test runner.
--
-- Run with:
--   nvim --headless -u NONE -i NONE -l nvim/tests/run_tests.lua
--
-- Unlike hypr/tests (which mocks `hl` because there's no local Wayland),
-- these run inside a real headless Neovim and load the real config modules,
-- so assertions are against actual `vim` state. Everything is network-free:
-- plugin specs are captured via a mocked `require('lazy')`, and per-plugin
-- config files are only compiled, never executed.

-- Resolve this script's dir so it works from any CWD.
local this_dir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"

package.path = this_dir .. "?.lua;"
    .. this_dir .. "support/?.lua;"
    .. package.path

local tests = {
    "test_compile",       -- syntax of every file (fastest, broadest)
    "test_options",       -- real vim.o values
    "test_keymaps",       -- real keymaps + leader
    "test_init",          -- format-on-save autocmd
    "test_highlights",    -- custom highlight group names (source-level)
    "test_plugins_spec",  -- lazy spec validation (no plugin install)
}

local passed, failed = 0, 0
for _, name in ipairs(tests) do
    package.loaded[name] = nil
    local ok, err = pcall(require, name)
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
if failed > 0 then
    vim.cmd("cquit 1")
else
    vim.cmd("quit")
end
