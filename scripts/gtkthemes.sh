#!/bin/sh

## Set GTK Themes, Icons, Cursor and Fonts

THEME='Adwaita-dark'
ICONS='Papirus-Dark'
FONT='Noto Sans 12'
CURSOR='Adwaita'

SCHEMA='gsettings set org.gnome.desktop.interface'

apply_themes() {
	${SCHEMA} gtk-theme "$THEME"
	${SCHEMA} icon-theme "$ICONS"
	${SCHEMA} cursor-theme "$CURSOR"
	${SCHEMA} font-name "$FONT"
}

apply_themes
