#!/usr/bin/env bash
LINE=$(nmcli -t -f NAME,TYPE con show --active 2>/dev/null | grep ":vpn" | head -1)
if [ -n "$LINE" ]; then
    NAME="${LINE%%:*}"
    printf '{"text": "\uf023 %s", "class": "connected", "tooltip": "VPN: %s"}\n' "$NAME" "$NAME"
else
    printf '{"text": "", "class": "disconnected"}\n'
fi