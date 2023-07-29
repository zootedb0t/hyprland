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

# Restart waybar
"$HOME"/.config/hypr/scripts/bar.sh

# Generate zathura, dunst and rofi colorscheme
"$HOME"/.local/bin/pywalzathura &
"$HOME"/.local/bin/dunst_color.sh &
"$HOME"/.local/bin/pywalrofi &

swww img "$wall" --transition-fps 30 --transition-type any --transition-duration 3
