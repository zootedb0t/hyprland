#!/bin/sh

get_volume() {
	amixer sget Master | grep 'Right:' | awk -F'[' '{print $2}' | awk -F'%' '{print $1}'
	# wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -F' ' '{print $2}' | awk -F'.' '{print $2}';
}

# Send the notification
send_notification() {
	volume=$(get_volume)
	dunstify "Volume $volume% " -r 5555 -u normal -h int:value:$((volume))
}

case $1 in
up)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1
	send_notification
	;;
down)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1
	send_notification
	;;
mute)
	# Toggle mute
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	is_mute="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -F' ' '{print $3}' | awk -F'[][]' '{print $2}')"
	if [ "$is_mute" = "MUTED" ]; then
		dunstify "Mute" -r 5555 -u normal -h int:value:0
	else
		send_notification
	fi
	;;
esac
