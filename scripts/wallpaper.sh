#!/usr/bin/env sh

# Dependency matugen(https://github.com/InioX/matugen) and swww

# Set variable
wal_dir=/home/stoney/Pictures/walls/

# Active color mode
active_color=$(gsettings get org.gnome.desktop.interface color-scheme)

# Color mode
mode="dark"

# Select wallpaper
if [ -z "$1" ]; then
	wall="$(fd . "$wal_dir" -e jpg -e jpeg -e png -e gif --type f | shuf -n 1)"
else
	wall="$1"
fi

# Generate colors using matugen. INFO: for other options see matugen --help
if [[ "$active_color" == "'prefer-light'" ]]; then
	mode="light"
fi
matugen -t scheme-content -m "$mode" image "$wall"
