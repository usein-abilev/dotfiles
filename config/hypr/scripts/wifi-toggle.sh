#!/usr/bin/env bash
WIFI_STATE=$(nmcli radio wifi)

if [ "$WIFI_STATE" = "enabled" ]; then
    nmcli radio wifi off
    notify-send "WiFi" "Disabled"
else
    nmcli radio wifi on
    notify-send "WiFi" "Enabled"
fi
