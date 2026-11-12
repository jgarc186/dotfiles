-- Drives modules/autostart.lua against modules/autostart.conf
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.autostart")

local on_calls = mock_hl.find("hl.on")
assert_util.equal(#on_calls, 1, "expected exactly one hl.on registration")
assert_util.equal(on_calls[1].args.event, "hyprland.start", "autostart should hook hyprland.start")

assert_util.truthy(#mock_hl.find("hl.exec_cmd") == 0, "exec_cmd should not fire until the hyprland.start callback runs")

on_calls[1].args.fn()

local exec_calls = mock_hl.find("hl.exec_cmd")
assert_util.equal(#exec_calls, 3, "expected 3 exec_cmd calls from the 3 exec-once lines")

assert_util.equal(
    exec_calls[1].args.cmd,
    "awww-daemon & quickshell & nm-applet & xsettingsd & swayosd-server & hyprsunset",
    "first autostart command mismatch"
)

-- `&&` binds tighter than `&`, so `quickshell && x &` is one background job in
-- which x only starts once quickshell exits - which it doesn't, for a session.
-- Everything here runs side by side.
assert_util.truthy(
    not exec_calls[1].args.cmd:find("&&", 1, true),
    "`&&` in the autostart line holds what follows it until the previous program exits: " .. exec_calls[1].args.cmd
)

-- Quickshell is the notification daemon now (services/Notifs.qml). Only one
-- process can own org.freedesktop.Notifications, and whichever of the two won
-- the race at login would get every notification.
for _, c in ipairs(exec_calls) do
    assert_util.truthy(
        not c.args.cmd:find("swaync"),
        "swaync would race quickshell for the notification bus name: " .. c.args.cmd
    )
end
assert_util.equal(
    exec_calls[2].args.cmd,
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
    "second autostart command mismatch"
)
assert_util.equal(
    exec_calls[3].args.cmd,
    "awww img ~/Pictures/wallpapers/s8dVKrc.jpeg --transition-type center",
    "third autostart command mismatch"
)

for _, c in ipairs(exec_calls) do
    assert_util.truthy(not c.args.cmd:find("exec%-once"), "leftover 'exec-once' text found in: " .. c.args.cmd)
end
