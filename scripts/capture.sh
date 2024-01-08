#!/usr/bin/env sh

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}.png"

if [ ! -d "$dir" ]; then
	mkdir -p "$dir"
fi

# Options for screenshots
shotnow=" Screenshot"
shotarea=" Area screenshot"
shotwin=" Current window screenshot"
# shot5="󰄉 Screenshot in 5 sec"

selected_option=$(
	echo "$shotnow
$shotarea
$shotwin
" | wofi --show dmenu -i -p "Choose one"
)

notify() {
  # -e is used to check for both directory and files
	if [ -e "$dir/$file" ]; then
		dunstify -u low --replace=699 -i "$dir/$file" "Screenshot Saved" "$file"
	else
		dunstify -u low --replace=699 -i "$dir/$file" "Something went wrong" "$file"
	fi
}

# take shots
shotnow() {
	sleep 1
	cd "${dir}" && grim - | tee "$file" | wl-copy
	notify
}

shotwin() {
  sleep 1
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	cd "${dir}" && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
}

shotarea() {
  sleep 1
	cd "${dir}" && grim -g "$(slurp -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)" - | tee "$file" | wl-copy
}

if [ "$selected_option" = "$shotnow" ]; then
	shotnow
elif [ "$selected_option" = "$shotarea" ]; then
	shotarea
elif [ "$selected_option" = "$shotwin" ]; then
	shotwin
else
	echo "Available Options : --now  --win --area"
fi

exit 0
