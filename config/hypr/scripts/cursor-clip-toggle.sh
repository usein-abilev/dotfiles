#!/usr/bin/env bash
LOCK_FILE="/tmp/cursor-clip-overlay.lock"

if [ -f "$LOCK_FILE" ]; then
    read PID < "$LOCK_FILE"
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        rm -f "$LOCK_FILE"
        exit
    fi
    rm -f "$LOCK_FILE"
fi

cursor-clip &
disown
echo $! > "$LOCK_FILE"
