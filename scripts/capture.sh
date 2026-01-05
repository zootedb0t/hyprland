#!/usr/bin/env sh

# ======================
# Configuration
# ======================
ROFI_CMD="rofi -dmenu -config ~/.config/rofi/capture.rasi"
DIR="$HOME/Pictures/Screenshots"
TIME=$(date +%Y-%m-%d-%H-%M-%S)
FILE="Screenshot_${TIME}.png"
FILEPATH="$DIR/$FILE"

mkdir -p "$DIR"

# ======================
# Helpers
# ======================

notify_success() {
	notify-send -u low -i "$FILEPATH" "Screenshot Saved" "$FILE"
}

notify_fail() {
	notify-send -u critical "Screenshot Failed" "$1"
}

copy_clipboard() {
	wl-copy <"$FILEPATH" --type image/png
}

take_shot() {
	# sleep 1
	if grim "$@"; then
		copy_clipboard
		notify_success
	else
		notify_fail "Could not capture screenshot"
	fi
}

# ======================
# Screenshot modes
# ======================

shot_now() {
	take_shot "$FILEPATH"
}

shot_area() {
	selection=$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)
	[ -z "$selection" ] && notify-send "Screenshot Cancelled" && exit 0
	take_shot -g "$selection" "$FILEPATH"
}

shot_window() {
	active=$(hyprctl activewindow -j) || notify_fail "No active window"

	x=$(echo "$active" | jq -r '.at[0]')
	y=$(echo "$active" | jq -r '.at[1]')
	w=$(echo "$active" | jq -r '.size[0]')
	h=$(echo "$active" | jq -r '.size[1]')

	geometry="${x},${y} ${w}x${h}"
	take_shot -g "$geometry" "$FILEPATH"
}

# ======================
# Menu
# ======================

show_menu() {
	printf "Area screenshot\nWindow screenshot\n" | $ROFI_CMD
}

# ======================
# Entry point
# ======================

case "$1" in
now)
	shot_now
	;;
area)
	shot_area
	;;
window)
	shot_window
	;;
menu)
	choice=$(show_menu)
	case "$choice" in
	"Area screenshot") shot_area ;;
	"Window screenshot") shot_window ;;
	*) exit 0 ;;
	esac
	;;
*)
	echo "Usage: $0 {now|area|window|menu}"
	exit 1
	;;
esac
