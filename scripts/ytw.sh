#!/usr/bin/env bash

# Dependencies jq, yt-dlp, rofi, xclip

audio=" Play Audio"
video=" Play Video"
download=" Download Video"
session="$XDG_SESSION_TYPE"
term=alacritty

# -z return true if $1(length of 1st argumnent) is zero
if [[ -z "$1" ]]; then
	url=$(wl-paste)
else
	url="$1"
fi

selected_option=$(
	echo "$audio
$video
$download" | rofi -dmenu \
		-i \
		-p "What do you want to do?" \
		-theme "$HOME/.config/rofi/yt.rasi"
)

# This slows down the script
# title="$(yt-dlp --skip-download --print-json --no-warnings "$url" | jq .title)"

if [[ "$selected_option" = "$audio" ]]; then
	$term -e mpv --no-video "$url" 2>&1
elif [[ "$selected_option" = "$video" ]]; then
	mpv --ytdl-format=bestvideo+bestaudio/best "$url" 2>&1
elif [[ "$selected_option" = "$download" ]]; then
	$term -e yt-dlp -f 'bv[ext=mp4]+ba' "$url" && notify-send -i "$icon_complete" -t 3000 "Download Completed" 2>&1
else
	printf "No choice"
fi
