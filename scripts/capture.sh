#!/usr/bin/env sh

ROFI_CMD="rofi -dmenu -i -theme ~/.config/rofi/capture.rasi"

# # Configuration
time=$(date +%Y-%m-%d-%H-%M-%S)
dir="/home/stoney/Pictures/Screenshots"
file="Screenshot_${time}.png"
filepath="$dir/$file"

# Ensure directory exists
if [ ! -d "$dir" ]; then
	mkdir -p "$dir"
fi

# Options for screenshots
shotnow=" Screenshot"
shotarea=" Area screenshot"
shotwin=" Current window screenshot"

# Notification function
notify() {
	if [ -f "$filepath" ]; then
		notify-send -u low -i "$filepath" "Screenshot Saved" "$file"
	else
		notify-send -u critical "Screenshot Failed" "Could not save screenshot"
	fi
}

# Copy to clipboard function
copy_to_clipboard() {
	if [ -f "$filepath" ]; then
		wl-copy <"$filepath" --type image/png
		return 0
	else
		return 1
	fi
}

# Full screen screenshot
shotnow() {
	sleep 1

	if grim "$filepath"; then
		copy_to_clipboard
		notify
	else
		notify-send -u critical "Screenshot Failed" "Could not capture full screen"
	fi
}

# Area screenshot
shotarea() {
	sleep 1

	# Get selection coordinates
	selection=$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2 2>/dev/null)

	if [ -n "$selection" ]; then
		if grim -g "$selection" "$filepath"; then
			copy_to_clipboard
			notify
		else
			notify-send -u critical "Screenshot Failed" "Could not capture selected area"
		fi
	else
		notify-send -u low "Screenshot Cancelled" "No area selected"
	fi
}

# Current window screenshot
shotwin() {
	sleep 1

	# Get active window info
	active_window=$(hyprctl activewindow -j 2>/dev/null)

	if [ -n "$active_window" ]; then
		# Parse window position and size using jq if available, otherwise fallback to text parsing
		if command -v jq >/dev/null 2>&1; then
			w_x=$(echo "$active_window" | jq -r '.at[0]')
			w_y=$(echo "$active_window" | jq -r '.at[1]')
			w_width=$(echo "$active_window" | jq -r '.size[0]')
			w_height=$(echo "$active_window" | jq -r '.size[1]')
			geometry="${w_x},${w_y} ${w_width}x${w_height}"
		else
			# Fallback to text parsing (your original method)
			w_pos=$(echo "$active_window" | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
			w_size=$(echo "$active_window" | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed 's/,/x/g')
			geometry="$w_pos $w_size"
		fi

		if grim -g "$geometry" "$filepath"; then
			copy_to_clipboard
			notify
		else
			notify-send -u critical "Screenshot Failed" "Could not capture window"
		fi
	else
		notify-send -u critical "Screenshot Failed" "Could not get active window info"
	fi
}

# Screenshot menu
screenshot_menu() {
	selected_option=$(printf "%s\n%s\n" "$shotarea" "$shotwin" | $ROFI_CMD)

	case "$selected_option" in
	"$shotarea")
		shotarea
		;;
	"$shotwin")
		shotwin
		;;
	*)
		# User cancelled or invalid selection
		exit 0
		;;
	esac
}

case "$1" in
now)
	shotnow
	;;
menu)
	screenshot_menu
	;;
area)
	shotarea
	;;
window)
	shotwin
	;;
*)
	echo "Usage: $0 {now|menu|area|window}"
	echo "  now    - Take full screen screenshot"
	echo "  menu   - Show selection menu"
	echo "  area   - Take area screenshot"
	echo "  window - Take current window screenshot"
	exit 1
	;;
esac
