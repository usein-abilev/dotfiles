#!/usr/bin/env bash

CHOICE=$(printf "  Lock\n  Logout\n  Suspend\n  Reboot\n⏻  Shutdown" | rofi -i -dmenu -p "Power" -theme ~/.config/rofi/config.rasi -l 5)

case "$CHOICE" in
    *Lock)     loginctl lock-session ;;
    *Logout)   hyprctl dispatch 'hl.dsp.exit()' ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff -i ;;
esac
