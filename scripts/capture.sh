#!/usr/bin/env sh

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="/home/stoney/Pictures/Screenshots"
file="Screenshot_${time}.png"

if [ ! -d "$dir" ]; then
	mkdir -p "$dir"
fi

# Options for screenshots
shotnow=" Screenshot"
shotarea=" Area screenshot"
shotwin=" Current window screenshot"

notify() {
	# -e is used to check for both directory and files
	if [ -e "$dir/$file" ]; then
		notify-send -i "$dir/$file" "Screenshot Saved" "$file"
	else
		notify-send -i "$dir/$file" "Something went wrong" "$file"
	fi
}

# take shots
shotnow() {
	sleep 1
	# If $dir doesn't exist the function early
	cd "${dir}" || return
	grim "$file"
	wl-copy --type image/png <"$file"
	notify
}

screenshot_menu() {
	shotarea() {
		sleep 1
		cd "${dir}" || return
		grim -g "$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)" "$file"
		wl-copy --type image/png <"$file"
		notify
	}

	shotwin() {
		sleep 1
		w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
		w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
		cd "${dir}" || return
		grim -g "$w_pos $w_size" "$file"
		wl-copy --type image/png <"$file"
		notify
	}

	selected_option=$(
		echo "$shotarea
$shotwin" | rofi -dmenu -i -p "Choose one"
	)
	if [ "$selected_option" = "$shotarea" ]; then
		shotarea
	elif [ "$selected_option" = "$shotwin" ]; then
		shotwin
	fi
}

case $1 in
now)
	shotnow
	;;
menu)
	screenshot_menu
	;;
*)
	echo "Error: Unknown argument '$1'"
	;;
esac
