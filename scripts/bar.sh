#!/usr/bin/env sh

if pgrep -x "waybar" >/dev/null; then
	systemctl kill --user waybar.service
else
	systemctl restart --user waybar.service
fi
