#!/usr/bin/env bash
BT_STATE=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$BT_STATE" = "yes" ]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Disabled"
else
    bluetoothctl power on
    notify-send "Bluetooth" "Enabled"
fi
