-- Drives modules/binds.lua against modules/binds.conf, line for line.
local assert_util = require("support.assert_util")
local mock_hl = require("support.mock_hl")

mock_hl.reset()
mock_hl.fresh_require("modules.binds")

local calls = mock_hl.find("hl.bind")

local function exec(cmd) return { fn = "hl.dsp.exec_cmd", args = cmd } end
local function close() return { fn = "hl.dsp.window.close", args = nil } end
local function float(a) return { fn = "hl.dsp.window.float", args = a } end
local function focus(a) return { fn = "hl.dsp.focus", args = a } end
local function move(a) return { fn = "hl.dsp.window.move", args = a } end
local function drag() return { fn = "hl.dsp.window.drag", args = nil } end
local function resize() return { fn = "hl.dsp.window.resize", args = nil } end

local mainMod = "SUPER"

local expected = {
    { keys = mainMod .. " + Q", dispatcher = exec("kitty") },
    { keys = mainMod .. " + C", dispatcher = close() },
    { keys = mainMod .. " + M", dispatcher = exec("systemctl suspend") },
    { keys = mainMod .. " + E", dispatcher = exec("nautilus") },
    { keys = mainMod .. " + V", dispatcher = float({ action = "toggle" }) },
    { keys = mainMod .. " + B", dispatcher = exec("chromium") },
    { keys = mainMod .. " + R", dispatcher = exec("1password") },
    { keys = mainMod .. " + N", dispatcher = exec("slack") },
    { keys = mainMod .. " + S", dispatcher = exec("spotify") },
    { keys = mainMod .. " + Space", dispatcher = exec("~/.config/rofi/launchers/type-2/launcher.sh || pkill rofi") },
    { keys = mainMod .. " + P", dispatcher = exec("pkill waybar") },
    { keys = mainMod .. " + O", dispatcher = exec("waybar &") },
    { keys = mainMod .. " + X", dispatcher = exec("hyprlock") },

    -- Every modifier needs its own "+" — "Ctrl SHIFT + 4" parses as one bad
    -- modifier token ("Ctrl SHIFT") and fails: 'failed to parse key string:
    -- Unknown keysym: "Ctrl SHIFT", did you forget a +?'
    { keys = "Ctrl + SHIFT + 4", dispatcher = exec("hyprshot -m region output --clipboard-only") },
    { keys = "Ctrl + SHIFT + R",
      dispatcher = exec("wf-recorder --audio=effect_output.j415-mic -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4") },
    { keys = "Ctrl + SHIFT + S", dispatcher = exec("pkill -SIGINT wf-recorder") },

    { keys = mainMod .. " + h",    dispatcher = focus({ direction = "left" }) },
    { keys = mainMod .. " + l",    dispatcher = focus({ direction = "right" }) },
    { keys = mainMod .. " + k",    dispatcher = focus({ direction = "up" }) },
    { keys = mainMod .. " + down", dispatcher = focus({ direction = "down" }) },
}

-- SUPER+[0-9] switch workspace, SUPER+SHIFT+[0-9] move window to workspace (10 maps to key 0)
for i = 1, 10 do
    local key = i % 10
    table.insert(expected, { keys = mainMod .. " + " .. key, dispatcher = focus({ workspace = i }) })
    table.insert(expected, { keys = mainMod .. " + SHIFT + " .. key, dispatcher = move({ workspace = i }) })
end

local rest = {
    { keys = mainMod .. " + mouse_down", dispatcher = focus({ workspace = "e+1" }) },
    { keys = mainMod .. " + mouse_up",   dispatcher = focus({ workspace = "e-1" }) },

    { keys = mainMod .. " + mouse:272", dispatcher = drag(),   opts = { mouse = true } },
    { keys = mainMod .. " + mouse:273", dispatcher = resize(), opts = { mouse = true } },

    { keys = "XF86AudioRaiseVolume", dispatcher = exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), opts = { locked = true, repeating = true } },
    { keys = "XF86AudioLowerVolume", dispatcher = exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      opts = { locked = true, repeating = true } },
    { keys = "XF86AudioMute",        dispatcher = exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     opts = { locked = true, repeating = true } },
    { keys = "XF86AudioMicMute",     dispatcher = exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   opts = { locked = true, repeating = true } },
    { keys = "XF86MonBrightnessUp",  dispatcher = exec("brightnessctl -e4 -n2 set 5%+"),                  opts = { locked = true, repeating = true } },
    { keys = "XF86MonBrightnessDown",dispatcher = exec("brightnessctl -e4 -n2 set 5%-"),                  opts = { locked = true, repeating = true } },
    { keys = "XF86KbdBrightnessUp",  dispatcher = exec("light -A 10 -s sysfs/leds/smc::kbd_backlight"),   opts = { locked = true, repeating = true } },
    { keys = "XF86KbdBrightnessDown",dispatcher = exec("light -U 10 -s sysfs/leds/smc::kbd_backlight"),   opts = { locked = true, repeating = true } },

    { keys = "XF86AudioNext",  dispatcher = exec("playerctl next"),       opts = { locked = true } },
    { keys = "XF86AudioPause", dispatcher = exec("playerctl play-pause"), opts = { locked = true } },
    { keys = "XF86AudioPlay",  dispatcher = exec("playerctl play-pause"), opts = { locked = true } },
    { keys = "XF86AudioPrev",  dispatcher = exec("playerctl previous"),   opts = { locked = true } },

    { keys = "XF86AudioRaiseVolume", dispatcher = exec("swayosd-client --output-volume raise") },
    { keys = "XF86AudioLowerVolume", dispatcher = exec("swayosd-client --output-volume lower") },
    { keys = "XF86AudioMute",        dispatcher = exec("swayosd-client --output-volume mute-toggle") },
    { keys = "XF86AudioMicMute",     dispatcher = exec("swayosd-client --input-volume mute-toggle") },

    { keys = "XF86MonBrightnessUp",   dispatcher = exec("swayosd-client --brightness raise") },
    { keys = "XF86MonBrightnessDown", dispatcher = exec("swayosd-client --brightness lower") },

    { keys = "Caps_Lock", dispatcher = exec("swayosd-client --caps-lock"), opts = { release = true } },

    { keys = "XF86AudioPlay", dispatcher = exec("swayosd-client --playerctl play-pause") },
    { keys = "XF86AudioNext", dispatcher = exec("swayosd-client --playerctl next") },
    { keys = "XF86AudioPrev", dispatcher = exec("swayosd-client --playerctl previous") },
}

for _, e in ipairs(rest) do
    table.insert(expected, e)
end

assert_util.equal(#calls, #expected,
    string.format("expected %d hl.bind calls, got %d", #expected, #calls))

for i, e in ipairs(expected) do
    local actual = calls[i].args
    assert_util.equal(actual.keys, e.keys, "bind #" .. i .. " keys mismatch")
    assert_util.equal(actual.dispatcher, e.dispatcher,
        "bind #" .. i .. " (" .. tostring(e.keys) .. ") dispatcher mismatch")
    assert_util.equal(actual.opts, e.opts,
        "bind #" .. i .. " (" .. tostring(e.keys) .. ") opts mismatch")
end
