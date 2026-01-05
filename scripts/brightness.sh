#!/usr/bin/env sh

# Brightness control script
# Dependencies: brightnessctl, libnotify

STEP="5%"

# Check dependency
command -v brightnessctl >/dev/null 2>&1 || {
	echo "Error: brightnessctl not found"
	exit 1
}

# Get brightness percentage
get_brightness() {
	brightnessctl -m | cut -d',' -f4
}

# Send notification
notify() {
	notify-send \
		-u low \
		-h string:x-canonical-private-synchronous:brightness \
		"Brightness: $(get_brightness)"
}

case "$1" in
up)
	brightnessctl set "$STEP+"
	notify
	;;
down)
	brightnessctl set "$STEP-"
	notify
	;;
*)
	echo "Usage: $0 {up|down}"
	exit 1
	;;
esac
