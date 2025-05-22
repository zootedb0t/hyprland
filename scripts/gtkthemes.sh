#!/usr/bin/env sh

GTK_SET='gsettings set org.gnome.desktop.interface'
GTK_GET='gsettings get org.gnome.desktop.interface'
DEFAULT_WALLPAPER="/home/stoney/Pictures/walls/vagabond.jpg"

get_wallpaper() {
	current_wallpaper=$(swww query 2>/dev/null) # Suppress stderr on failure
	if [[ -z "$current_wallpaper" ]]; then
		WALLPAPER_PATH="$DEFAULT_WALLPAPER"
	else
		WALLPAPER_PATH=$(echo "$current_wallpaper" | sed -n 's/.*image: //p')
	fi
}

set_theme_and_color() {
	local active_color=$(${GTK_GET} color-scheme)
	if [[ "$active_color" = "'prefer-dark'" ]]; then
		THEME='Materia-light'
		COLOR='prefer-light'
		# Matugen is color generation tool. https://github.com/InioX/matugen
		matugen -t scheme-content -m light image ${WALLPAPER_PATH}
	else
		THEME='Materia-dark'
		COLOR='prefer-dark'
		matugen -t scheme-content -m dark image ${WALLPAPER_PATH}
	fi
}

apply_themes() {
	set_theme_and_color
	${GTK_SET} gtk-theme "$THEME"
	${GTK_SET} color-scheme "$COLOR"
}

get_wallpaper
apply_themes
