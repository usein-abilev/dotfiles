#!/usr/bin/env bash
FLAG=/tmp/hyprsunset-mode
if [ -f "$FLAG" ]; then
    hyprctl hyprsunset identity
    rm -f "$FLAG"
    notify-send "Night Mode" "Disabled"
else
    hyprctl hyprsunset temperature 4500
    touch "$FLAG"
    notify-send "Night Mode" "Enabled (4500K)"
fi
