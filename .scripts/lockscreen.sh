#!/bin/bash

# Display Dependent
# "DisplayPort-0" = Monitor
# "eDP" = Steam Deck Built-in screen

display=$(xrandr --listmonitors | awk 'NR==2{print $4}')

if [ "$display" = "DisplayPort-0" ]; then
    /usr/lib/kscreenlocker_greet --immediateLock
else
    echo -e "\033[1mLockscreen disabled while only using Steam Deck built-in display\033[0m"
    text="External Display Not Detected."
    text_length=${#text}

    if [ "$text_length" -gt 50 ]; then
        width=600
        height=300
    elif [ "$text_length" -gt 20 ]; then
        width=300
        height=100
    else
        width=300
        height=100
    fi
    zenity --info --text="$text" --width="$width" --height="$height"
fi
