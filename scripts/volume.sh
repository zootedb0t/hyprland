#!/usr/bin/env sh

# Volume control script using wpctl
# Dependencies: pipewire-utils (wpctl), libnotify

set -e

# Configuration
readonly SCRIPT_NAME="${0##*/}"
readonly VOLUME_STEP="5%"
readonly NOTIFICATION_ID="volume-notification"

# Check if wpctl is available
check_wpctl() {
	if ! command -v wpctl >/dev/null 2>&1; then
		printf "Error: wpctl not found. Install pipewire-utils.\n" >&2
		exit 1
	fi
}

# Get current volume percentage (without % symbol)
get_volume() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}'
}

# Check if audio is muted
is_muted() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

# Send notification with replacement
send_notification() {
	notify-send -h "string:x-canonical-private-synchronous:$NOTIFICATION_ID" \
		-u low "Volume: $1"
}

# Show usage
usage() {
	printf "Usage: %s {up|down|mute|mic}\n" "$SCRIPT_NAME"
	printf "Commands:\n"
	printf "  up    - Increase volume by %s\n" "$VOLUME_STEP"
	printf "  down  - Decrease volume by %s\n" "$VOLUME_STEP"
	printf "  mute  - Toggle speaker mute\n"
	printf "  mic   - Toggle microphone mute\n"
}

# Main logic
main() {
	check_wpctl

	case "${1:-}" in
	up)
		wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$VOLUME_STEP+"
		if is_muted; then
			send_notification "$(get_volume)% (Muted)"
		else
			send_notification "$(get_volume)%"
		fi
		;;
	down)
		wpctl set-volume @DEFAULT_AUDIO_SINK@ "$VOLUME_STEP-"
		if is_muted; then
			send_notification "$(get_volume)% (Muted)"
		else
			send_notification "$(get_volume)%"
		fi
		;;
	mute)
		wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
		if is_muted; then
			send_notification "Muted"
		else
			send_notification "$(get_volume)%"
		fi
		;;
	mic)
		wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
		if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
			send_notification "Mic Muted"
		else
			send_notification "Mic Unmuted"
		fi
		;;
	-h | --help)
		usage
		;;
	"")
		printf "Error: No command specified\n" >&2
		usage
		exit 1
		;;
	*)
		printf "Error: Invalid command '%s'\n" "$1" >&2
		usage
		exit 1
		;;
	esac
}

main "$@"
