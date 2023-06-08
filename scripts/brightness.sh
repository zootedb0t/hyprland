#!/bin/bash

function send_notification {
  currentBrightness="$(brightnessctl g)"
  # Send the notification
  dunstify "Brightness $currentBrightness%" -r 5555 -u normal -h int:value:$((currentBrightness))
}

case $1 in
  up)
    # increase the backlight by 5%
    brightnessctl set 5%+
    send_notification
    ;;
  down)
    # decrease the backlight by 5%
    brightnessctl set 5%-
    send_notification
    ;;
esac
