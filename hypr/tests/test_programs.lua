-- Drives modules/programs.lua against the $var definitions at the top of hyprland.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
local programs = mock_hl.fresh_require("modules.programs")

assert_util.equal(programs, {
    terminal = "kitty",
    fileManager = "nautilus",
    browser = "chromium",
    passwordManager = "1password",
    communication = "slack",
    menu = "~/.config/rofi/launchers/type-2/launcher.sh || pkill rofi",
    musicPlayer = "spotify",
}, "modules.programs table mismatch")
