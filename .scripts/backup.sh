#!/bin/bash

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

# If there are missing packages, install them and disable steamos-readonly
if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}"
    sudo steamos-readonly disable
    sudo pacman -Sy --noconfirm "${missing_packages[@]}"
    sudo steamos-readonly enable
else
    echo "Packages already installed."
fi

# Function to perform backup of a directory
perform_backup() {
    local source_directory=$1
    local destination_directory=$2

# Backup everything in $HOME to...
    konsole --hold -e "rsync -av --progress '$source_directory' '$destination_directory'"

    echo "Sync completed."
}

# Function to prompt for directory selection using Zenity
prompt_directory_selection() {
    local selected_directory=$(zenity --file-selection --directory --title="Select Directory")
    echo "$selected_directory"
}

# Function to display the menu options using Zenity
display_menu() {
    local options=("Backup: HOME" "Backup: SD CARD" "Backup: CUSTOM")
    local option_height=$(( ${#options[@]} * 50 + 90 ))

    local choice=$(zenity --list --title="Select Backup Option" --column="Options" --width=400 --height=$option_height "${options[@]}")

    echo "$choice"
}

# Perform action based on selected menu option
selected_option=$(display_menu)

case "$selected_option" in
    "Backup: HOME") # Backup everything in the Internal Storage to where you want to store the backup
        source_directory="$HOME"
        destination_directory=$(prompt_directory_selection)

        if [[ -n "$destination_directory" ]]; then
            perform_backup "$source_directory" "$destination_directory"
        else
            echo "No destination directory selected. Sync canceled."
        fi
        ;;
    "Backup: SD CARD") # Backup everything in the External Storage to where you want to store the backup
        source_directory="/run/media/mmcblk0p1/"
        destination_directory=$(prompt_directory_selection)

        if [[ -n "$destination_directory" ]]; then
            perform_backup "$source_directory" "$destination_directory"
        else
            echo "No destination directory selected. Sync canceled."
        fi
        ;;
    "Backup: CUSTOM") # Choose what to backup and where to backup
        source_directory=$(prompt_directory_selection)
        destination_directory=$(prompt_directory_selection)

        if [[ -n "$source_directory" && -n "$destination_directory" ]]; then
            perform_backup "$source_directory" "$destination_directory"
        else
            echo "Invalid directory selection. Sync canceled."
        fi
        ;;
    *)
        echo "Invalid option."
        ;;
esac
