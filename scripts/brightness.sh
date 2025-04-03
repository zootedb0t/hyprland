#!/usr/bin/env sh

# Dependency brightnessctl and mako
send_notification() {
	currentBrightness="$(brightnessctl g)"
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Brightness: $currentBrightness%"
}

case $1 in
# increase the backlight by 1%
up)
	brightnessctl set 1%+
	send_notification
	;;
# decrease the backlight by 1%
down)
	brightnessctl set 1%-
	send_notification
	;;
*)
	echo "Error: Unknown argument '$1'"
	;;
esac
