#!/usr/bin/env sh

# Dependency pamixer and mako
get_volume() {
	pamixer --get-volume
}

# Function to send notification
send_notification() {
	local volume="$1"
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume: $volume"
}

case $1 in
up)
	pamixer -i 1
	send_notification "$(get_volume)%"
	;;
down)
	pamixer -d 1
	send_notification "$(get_volume)%"
	;;
mute)
	# Toggle mute
	is_muted=$(pamixer --get-mute)
	if [ "$is_muted" == "false" ]; then
		pamixer -m
		send_notification "Muted"
	else
		pamixer -u
		send_notification "$(get_volume)%"
	fi
	;;
mic)
	# wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	# Check if wpctl is available
	if command -v wpctl >/dev/null 2>&1; then
		wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	else
		echo "Warning: wpctl not found. Microphone mute functionality unavailable."
	fi
	;;
*)
	echo "Usage: $0 (up|down|mute|mic)"
	;;
esac
