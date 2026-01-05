#!/usr/bin/env bash

# Define the rofi command with custom theme
ROFI_CMD="rofi -dmenu -i -theme ~/.config/rofi/powermenu.rasi"

# Main menu with better formatting
choice=$(printf "🌠 Switch Theme\n💀 Kill Process\n🔒 Lock Session\n💤 Suspend\n🔄 Reboot\n🔌 Shutdown" | $ROFI_CMD -p "Power Menu")

case "$choice" in
*"Switch Theme")
	current_theme=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
	if [ "$current_theme" = "prefer-dark" ]; then
		~/.config/hypr/scripts/theme.sh -m light && notify-send "💡 Switching to Light Mode" "Theme updated successfully" || notify-send "Error" "Can't generate theme'..." -u critical
	else
		~/.config/hypr/scripts/theme.sh -m dark && notify-send "🌙 Switching to Dark Mode" "Theme updated successfully!" || notify-send "Error" "Can't generate theme'..." -u critical
	fi
	;;
*"Kill Process")
	selected_process=$(ps -u "$USER" -o pid,comm,%cpu,rss --sort=-rss --no-headers |
		awk '{printf "%-8s %-20s CPU: %4.1f%% MEM: %6.1fMB\n", $1, $2, $3, $4/1024}' |
		$ROFI_CMD -p "Select Process to Kill")

	[ -z "$selected_process" ] && exit

	pid=$(echo "$selected_process" | awk '{print $1}')
	name=$(echo "$selected_process" | awk '{print $2}')

	# Confirmation with custom styling
	confirm=$(printf "✅ Yes, kill it\n❌ No, cancel" | $ROFI_CMD -p "Kill $name (PID: $pid)?")

	case "$confirm" in
	*"Yes"*)
		if kill "$pid" 2>/dev/null; then
			notify-send "Process Killed" "$name (PID: $pid) terminated successfully" -u normal
		else
			kill -9 "$pid" 2>/dev/null
			notify-send "Process Force Killed" "$name (PID: $pid) force terminated" -u normal
		fi
		;;
	*)
		notify-send "Cancelled" "Process kill cancelled" -u low
		;;
	esac
	;;
*"Lock Session")
	if command -v loginctl >/dev/null 2>&1; then
		loginctl lock-session
	else
		notify-send "Lock Error" "No suitable lock command found" -u critical
		exit 1
	fi
	;;
*"Suspend")
	confirm=$(printf "✓ Yes, suspend\n✗ No, cancel" | $ROFI_CMD -p "Suspend System?")
	case "$confirm" in
	*"Yes"*)
		notify-send "System Suspending" "System will suspend in 3 seconds..." -u normal
		sleep 3
		systemctl suspend
		;;
	*)
		notify-send "Cancelled" "Suspend cancelled" -u low
		;;
	esac
	;;
*"Reboot")
	confirm=$(printf "✓ Yes, reboot\n✗ No, cancel" | $ROFI_CMD -p "Reboot System?")
	case "$confirm" in
	*"Yes"*)
		notify-send "System Rebooting" "System will reboot in 3 seconds..." -u critical
		sleep 3
		systemctl reboot
		;;
	*)
		notify-send "Cancelled" "Reboot cancelled" -u low
		;;
	esac
	;;
*"Shutdown")
	confirm=$(printf "✓ Yes, shutdown\n✗ No, cancel" | $ROFI_CMD -p "Shutdown System?")
	case "$confirm" in
	*"Yes"*)
		notify-send "System Shutting Down" "System will shutdown in 3 seconds..." -u critical
		sleep 3
		shutdown now
		;;
	*)
		notify-send "Cancelled" "Shutdown cancelled" -u low
		;;
	esac
	;;
*)
	exit 1
	;;
esac
