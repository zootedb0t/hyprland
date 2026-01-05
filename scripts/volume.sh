#!/usr/bin/env sh

# Volume control script (PipeWire)
# Dependencies: wpctl, libnotify

STEP="5%"

command -v wpctl >/dev/null 2>&1 || {
	echo "Error: wpctl not found"
	exit 1
}

get_volume() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}'
}

is_muted() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

notify_volume() {
	if is_muted; then
		notify-send \
			-u low \
			-h string:x-canonical-private-synchronous:volume \
			-h int:value:0 \
			"Volume" "Muted"
	else
		notify-send \
			-u low \
			-h string:x-canonical-private-synchronous:volume \
			-h int:value:"$1" \
			"Volume: $1%"
	fi
}

case "$1" in
up)
	wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$STEP+"
	notify_volume "$(get_volume)"
	;;
down)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ "$STEP-"
	notify_volume "$(get_volume)"
	;;
mute)
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	notify_volume "$(get_volume)"
	;;
mic)
	wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED &&
		notify-send "Microphone" "Muted" ||
		notify-send "Microphone" "Unmuted"
	;;
*)
	echo "Usage: $0 {up|down|mute|mic}"
	exit 1
	;;
esac
