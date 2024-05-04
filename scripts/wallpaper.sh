#!/usr/bin/env sh

# Set variable
wal_dir=/home/stoney/Pictures/walls/
# local_bin_dir=/home/stoney/.local/bin/
# current_wallpaper=/home/stoney/.local/share/bg.jpg

# Select wallpaper
if [ -z "$1" ]; then
	wall="$(fd . "$wal_dir" -e jpg -e jpeg -e png -e gif --type f | shuf -n 1)"
else
	wall="$1"
fi

# Generate colors using pywal or matugen
matugen -t scheme-rainbow image "$wall"

# ln -sf "$wall" "$current_wallpaper"
# wal -c
# wal -nqsi "$wall"

# Generate zathura and dunst colorscheme
# "$local_bin_dir/pywalzathura"
# "$local_bin_dir/dunst_color.sh"

# Restart hyprpaper if running
# if pgrep -x "hyprpaper" >/dev/null; then
# 	killall hyprpaper
# 	hyprpaper &
# fi

# Restart waybar if running
# if pgrep -x "waybar" >/dev/null; then
# 	killall waybar
# 	waybar >/dev/null 2>&1 &
# fi
