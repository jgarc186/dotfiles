-- Programs used throughout the other modules (mirrors the $vars at the
-- top of hyprland.conf; Lua has no macro-substitution so this is a table).
return {
    terminal = "kitty",
    fileManager = "nautilus",
    browser = "chromium",
    passwordManager = "1password",
    communication = "slack",
    menu = "~/.config/rofi/launchers/type-2/launcher.sh || pkill rofi",
    musicPlayer = "spotify",
}
