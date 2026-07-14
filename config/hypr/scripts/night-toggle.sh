#!/usr/bin/env bash
FLAG=/tmp/hyprsunset-mode
if [ -f "$FLAG" ]; then
    hyprctl hyprsunset identity
    rm -f "$FLAG"
    notify-send "Night Mode" "Disabled"
else
    hyprctl hyprsunset temperature 3500
    touch "$FLAG"
    notify-send "Night Mode" "Enabled (3500K)"
fi
