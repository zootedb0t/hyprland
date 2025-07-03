#!/usr/bin/env sh

choice=$(printf "🔒 Lock Session\n💀 Kill Process\n💤 Suspend\n🔄 Reboot\n🔌 Shutdown" |
	rofi -dmenu -i -p "Choose action:")

case "$choice" in
*"Lock Session")
	if command -v loginctl >/dev/null 2>&1; then
		loginctl lock-session
	else
		notify-send "Lock Error" "No suitable lock command found"
		exit 1
	fi
	;;
*"Kill Process")
	selected_process=$(ps -u "$USER" -o pid,comm,%cpu,rss --sort=-rss --no-headers |
		awk '{printf "%-8s %-20s %6.1fMB\n", $1, $2, $4/1024}' |
		rofi -dmenu -i -p "Kill Process:")

	[ -z "$selected_process" ] && exit

	pid=$(echo "$selected_process" | awk '{print $1}')
	name=$(echo "$selected_process" | awk '{print $2}')

	confirm=$(printf "Yes\nNo" | rofi -dmenu -i -p "Kill $name (PID: $pid)?")

	[ "$confirm" != "Yes" ] && exit

	if kill "$pid" 2>/dev/null; then
		notify-send "Process Killed" "$name (PID: $pid)"
	else
		kill -9 "$pid" 2>/dev/null
		notify-send "Process Force Killed" "$name (PID: $pid)"
	fi
	;;
*"Suspend")
	# Confirm suspend action
	confirm=$(printf "Yes\nNo" | rofi -dmenu -i -p "Suspend system?")
	if [ "$confirm" = "Yes" ]; then
		systemctl suspend
	fi
	;;
*"Reboot")
	# Confirm reboot action
	confirm=$(printf "Yes\nNo" | rofi -dmenu -i -p "Reboot system?")
	if [ "$confirm" = "Yes" ]; then
		systemctl reboot
	fi
	;;
*"Shutdown")
	# Confirm shutdown action
	confirm=$(printf "Yes\nNo" | rofi -dmenu -i -p "Shutdown system?")
	if [ "$confirm" = "Yes" ]; then
		shutdown now
	fi
	;;
*)
	exit 1
	;;
esac
