#!/usr/bin/env bash

function get_volume {
	amixer sget Master | grep 'Right:' | awk -F'[' '{print $2}' | awk -F'%' '{print $1}'
	# wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -F' ' '{print $2}' | awk -F'.' '{print $2}'
}

# Send the notification
function send_notification {
	volume=$(get_volume)
	dunstify "Volume $volume% " -r 5555 -u normal -h int:value:$((volume))
	# dunstify "Volume $volume% " -r 5555 -u normal
}

case $1 in
up)
	# Unmute
	# amixer -D pulse set Master on >/dev/null
	# amixer -q sset Master 3%+ >/dev/null
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1
	send_notification
	;;
down)
	# Unmute
	# amixer -D pulse set Master on >/dev/null
	# amixer -q sset Master 3%- >/dev/null
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1
	send_notification
	;;
mute)
	# Toggle mute
	# amixer -q sset Master toggle
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	is_mute="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -F' ' '{print $3}' | awk -F'[][]' '{print $2}')"
	if [ "$is_mute" == "MUTED" ]; then
		dunstify "Mute" -r 5555 -u normal -h int:value:0
	else
		send_notification
	fi
	;;
esac
