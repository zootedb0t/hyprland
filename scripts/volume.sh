#!/usr/bin/env sh

# Dependency pamixer and mako
get_volume() {
	pamixer --get-volume
}

# Send the notification
send_notification() {
	volume=$(get_volume)
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume: $volume%"
}

case $1 in
up)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+
	send_notification
	;;
down)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
	send_notification
	;;
mute)
	# Toggle mute
	if [ "$(pamixer --get-mute)" == "false" ]; then
		pamixer -m && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume Switched OFF"
	elif [ "$(pamixer --get-mute)" == "true" ]; then
		pamixer -u && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume Switched ON"
	fi
	;;
mic)
	wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	;;
esac
