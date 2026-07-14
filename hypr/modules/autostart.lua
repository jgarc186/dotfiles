-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon & waybar && nm-applet & xsettingsd & swaync & swayosd-server & hyprsunset")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("awww img ~/Pictures/wallpapers/s8dVKrc.jpeg --transition-type center")
end)
