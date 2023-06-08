#!/bin/bash

if pgrep -x "waybar" >/dev/null; then
	killall waybar
else
	setsid waybar -c "$HOME/.config/hypr/waybar/config.jsonc" -s "$HOME/.config/hypr/waybar/style.css"
fi
