hl.on("hyprland.start", function()
    hl.exec_cmd("brightnessctl -d intel_backlight set 0")
    hl.exec_cmd("hyprsunset -t 3500")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    hl.exec_cmd("/usr/libexec/xdg-desktop-portal &")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal-gnome &")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal-hyprland &")
    hl.exec_cmd("sleep 1 && dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\" &")
    hl.exec_cmd(terminal)
    hl.exec_cmd("waybar")

    -- start super key listener (launcher on lone Super press)
    hl.exec_cmd("python3 ~/.config/hypr/scripts/super-launcher.py &")

    -- clipboard manager daemon
    hl.exec_cmd("/usr/bin/wl-paste --type text --watch ~/go/bin/cliphist store &")
    hl.exec_cmd("/usr/bin/wl-paste --type image --watch ~/go/bin/cliphist store &")

    -- enable notifications
    hl.exec_cmd("swaync")
    hl.exec_cmd("sleep 2 && swaync-client --dnd-off")
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd("brightnessctl -d intel_backlight set 60")
end)
