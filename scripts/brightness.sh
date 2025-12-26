#!/usr/bin/env sh

# Brightness control script
# Dependencies: brightnessctl, libnotify

set -e

# Configuration
readonly SCRIPT_NAME="${0##*/}"
readonly BRIGHTNESS_STEP="5%"

# Check if brightnessctl is available
check_brightnessctl() {
	if ! command -v brightnessctl >/dev/null 2>&1; then
		printf "Error: brightnessctl not found. Install brightnessctl package.\n" >&2
		exit 1
	fi
}

# Get current brightness value
get_brightness() {
	brightnessctl get
}

# Send notification with replacement
send_notification() {
	# Dismiss existing Volume notifications (mako-specific)
	makoctl list | awk '/Brightness/ {id=$2; sub(":", "", id); system("makoctl dismiss " id)}'

	case "$1" in
	*)
		notify-send -u low "Brightness: $1%" --hint=int:value:"$1"
		;;
	esac

}

# Show usage
usage() {
	printf "Usage: %s {up|down}\n" "$SCRIPT_NAME"
	printf "Commands:\n"
	printf "  up    - Increase brightness by %s\n" "$BRIGHTNESS_STEP"
	printf "  down  - Decrease brightness by %s\n" "$BRIGHTNESS_STEP"
}

# Main logic
main() {
	check_brightnessctl

	case "${1:-}" in
	up)
		brightnessctl set "$BRIGHTNESS_STEP+"
		send_notification "$(get_brightness)"
		;;
	down)
		brightnessctl set "$BRIGHTNESS_STEP-"
		send_notification "$(get_brightness)"
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
