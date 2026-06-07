#!/usr/bin/env bash
VPN_CONNS=$(nmcli -t -f NAME,TYPE con show --active | grep ":vpn" | cut -d: -f1)

if [ -n "$VPN_CONNS" ]; then
    echo "$VPN_CONNS" | while read -r conn; do
        nmcli con down "$conn"
    done
    notify-send "VPN" "Disconnected"
else
    FIRST_VPN=$(nmcli -t -f NAME,TYPE con show | grep ":vpn" | cut -d: -f1 | head -1)
    if [ -n "$FIRST_VPN" ]; then
        nmcli con up "$FIRST_VPN"
        notify-send "VPN" "Connected to $FIRST_VPN"
    else
        notify-send "VPN" "No VPN connection configured"
    fi
fi
