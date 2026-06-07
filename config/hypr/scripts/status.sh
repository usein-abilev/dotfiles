#!/usr/bin/env bash
# Outputs current status for swaync buttons widget
WIFI=$(nmcli radio wifi | grep -q enabled && echo "on" || echo "off")
BT=$(bluetoothctl show | grep "Powered:" | awk '{print $2}' | grep -q yes && echo "on" || echo "off")
NIGHT=$([ -f /tmp/hyprsunset-mode ] && echo "on" || echo "off")
VPN=$(nmcli -t -f NAME,TYPE con show --active | grep -q ":vpn" && echo "on" || echo "off")

echo "{\"wifi\":\"$WIFI\",\"bluetooth\":\"$BT\",\"night\":\"$NIGHT\",\"vpn\":\"$VPN\"}"
