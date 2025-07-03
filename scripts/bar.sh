#!/usr/bin/env sh

# Toggle waybar service

set -e

if systemctl is-active --user waybar.service --quiet; then
	systemctl stop --user waybar.service
else
	systemctl start --user waybar.service
fi
