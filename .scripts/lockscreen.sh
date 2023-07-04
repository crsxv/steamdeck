#!/bin/bash

# Display Dependent
# "DisplayPort-0" = Monitor
# "eDP" = Steam Deck Built-in screen

# It enables strict error handling and behavior for the script
set -euo pipefail

# List of required packages
required_packages=(
    "konsole"
    "rsync"
    "zenity"
)

# Function to check if a package is installed
is_package_installed() {
    local package="$1"
    pacman -Q "$package" &>/dev/null
}

# Check if any of the required packages are not installed
missing_packages=()
for package in "${required_packages[@]}"; do
    if ! is_package_installed "$package"; then
        missing_packages+=("$package")
    fi
done

# If there are missing packages, install them and disable steamos-readonly temporarily
if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}"
    sudo steamos-readonly disable
    sudo pacman -Sy --noconfirm "${missing_packages[@]}"
    sudo steamos-readonly enable
else
    echo "Packages already installed."
fi

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
