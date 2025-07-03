#!/usr/bin/env bash

# YouTube player/downloader with rofi menu
# Dependencies: yt-dlp, rofi, wl-clipboard, mpv, libnotify

set -euo pipefail

# Configuration
readonly TERM="foot"
readonly ROFI_THEME="$HOME/.config/rofi/yt.rasi"

# Menu options
readonly AUDIO=" Play Audio"
readonly VIDEO=" Play Video"
readonly DOWNLOAD=" Download Video"

# Get URL from argument or clipboard
get_url() {
	if [[ $# -gt 0 ]]; then
		echo "$1"
	else
		wl-paste 2>/dev/null || {
			echo "Error: No URL provided and clipboard is empty" >&2
			exit 1
		}
	fi
}

# Show rofi menu
show_menu() {
	printf "%s\n%s\n%s\n" "$AUDIO" "$VIDEO" "$DOWNLOAD" |
		rofi -dmenu -i -p "What do you want to do?" -theme "$ROFI_THEME" 2>/dev/null ||
		rofi -dmenu -i -p "What do you want to do?"
}

# Main function
main() {
	local url selection

	url=$(get_url "$@")
	[[ -z "$url" ]] && {
		echo "Error: No URL provided" >&2
		exit 1
	}

	selection=$(show_menu)
	[[ -z "$selection" ]] && {
		echo "No selection made"
		exit 0
	}

	case "$selection" in
	"$AUDIO")
		"$TERM" -e mpv --no-video --ytdl-format=bestaudio/best "$url"
		;;
	"$VIDEO")
		mpv --ytdl-format='bestvideo+bestaudio/best' "$url"
		;;
	"$DOWNLOAD")
		"$TERM" -e bash -c "
                yt-dlp -f 'bv[ext=mp4]+ba/best[ext=mp4]/best' '$url' && 
                notify-send -t 3000 'Download Completed' ||
                notify-send -t 5000 'Download Failed'
            "
		;;
	*)
		echo "Invalid selection" >&2
		exit 1
		;;
	esac
}

main "$@"
