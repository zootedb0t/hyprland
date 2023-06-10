#!/bin/sh

grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png')"
