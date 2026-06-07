#!/usr/bin/env bash
DIR="/tmp/hyprshot"
mkdir -p "$DIR"

FILE="$DIR/latest.png"

output=$(/usr/local/bin/hyprshot -m region -s -o "$DIR" -f "latest.png" -z 2>&1)
[[ "$output" =~ "invalid" ]] && exit 1

wl-copy < "$FILE"

# --hint=int:transient:1 stops swaync from saving it to history
# -t 5000 means it will automatically close after 5 seconds
RESPONSE=$(notify-send "Screenshot" "Copied to clipboard" \
    --action="click-action=Open Preview" \
    --hint=int:transient:1 \
    -i $FILE \
    -t 5000 \
    --wait)

if [ "$RESPONSE" = "click-action" ]; then
    xdg-open "$FILE"
fi
