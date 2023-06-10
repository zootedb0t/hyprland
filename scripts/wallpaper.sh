#!/bin/sh

# Edit bellow to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=3

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

swww img "$wall"
