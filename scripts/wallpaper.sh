#!/bin/sh

wal_dir=/home/stoney/Pictures/walls/

if [ -z "$1" ]; then
	wall="$(fd . "$wal_dir" -e jpg -e jpeg -e png -e gif --type f | shuf -n 1)"
else
	wall="$1"
fi

# Generate colors using pywal
wal -c
wal -nqsi "$wall"

# Generate zathura, dunst and rofi colorscheme
"$HOME"/.local/bin/pywalzathura &
"$HOME"/.local/bin/dunst_color.sh &
"$HOME"/.local/bin/pywalrofi &

swww img "$wall" --transition-fps 30 --transition-type any --transition-duration 3

# Restart waybar
if pgrep -x "waybar" >/dev/null; then
	killall waybar
	waybar -c "$HOME/.config/hypr/waybar/config.jsonc" -s "$HOME/.config/hypr/waybar/style.css" > /dev/null 2>&1 &
fi
