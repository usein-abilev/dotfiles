#!/usr/bin/env bash
SINK=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOL=$(echo "$SINK" | awk '{print $2 * 100}' | xargs printf "%.0f")
MUTED=$(echo "$SINK" | grep -c MUTED)
NICK=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep node.nick | sed 's/.*= "//;s/"//')

if [ "$MUTED" -ne 0 ]; then
    echo "{\"text\": \"  $NICK\", \"class\": \"muted\", \"tooltip\": \"Muted - $NICK\"}"
else
    echo "{\"text\": \"  $VOL%  $NICK\", \"class\": \"\", \"tooltip\": \"$NICK - $VOL%\"}"
fi
