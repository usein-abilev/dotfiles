hl.on("hyprland.start", function ()
    hl.exec_cmd("brightnessctl -d intel_backlight set 0")
    hl.exec_cmd("hyprsunset -t 3500")

    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal --replace &")
    hl.exec_cmd(terminal)
    hl.exec_cmd("waybar")

    -- start clipboard daemons
    hl.exec_cmd(clipboard .. " --daemon &")

    -- enable notifications
    hl.exec_cmd("swaync")
    hl.exec_cmd("sleep 0.5 && swaync-client --dnd-off")

end)

hl.on("hyprland.shutdown", function ()
    hl.exec_cmd("brightnessctl -d intel_backlight set 60")
end)
