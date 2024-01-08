#!/usr/bin/env sh

pid=$(ps -u "$USER" -o pid,%mem,%cpu,comm | sort -b -k2 -r | sed -n '1!p' | wofi --show dmenu -p "Select any process to kill" | awk '{print $1}')

kill -15 "$pid" 2>/dev/null && notify-send "Process Killed"
