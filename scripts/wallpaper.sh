#!/bin/sh

wal_dir=/home/stoney/Pictures/walls/

if [ -z "$1" ]; then
	wall="$(fd . "$wal_dir" -e jpg -e jpeg -e png --type f | shuf -n 1)"
else
	wall="$1"
fi

convert "$wall" ~/.local/share/bg.jpg
wal -nqsic ~/.local/share/bg.jpg

# Generate zathura, dunst and rofi colorscheme
"$HOME"/.local/bin/pywalzathura &
"$HOME"/.local/bin/dunst_color.sh &
"$HOME"/.local/bin/pywalrofi &

if pgrep -x "swaybg" >/dev/null; then
	killall swaybg
fi

swaybg -i ~/.local/share/bg.jpg -m fill &
