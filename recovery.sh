#!/bin/bash

#Check if sudo password has been set in the Steam Deck
if [ "$(passwd --status deck | tr -s " " | cut -d " " -f 2)" == "P" ]; then
    echo -e "\033[1m sudo password is already set\033[0m"
else
    echo -e "\033[1m Setting sudo password deck:deck\033[0m"
    echo -e "deck\ndeck" | passwd deck &>/dev/null
    echo -e "\033[1m sudo password has been set to 'deck'\033[0m"
    echo -e "\033[1m Set your own password after finishing\033[0m"
fi

#File to be checked in home directory
    file="steamdeck-recovery-4.img.bz2"
#Online source
    online="https://steamdeck-images.steamos.cloud/recovery/steamdeck-recovery-4.img.bz2"

#Check if file exists in the within home directories
    file_location=$(find "$HOME" -name "$file" 2>/dev/null)
if [ -n "$file_location" ]; then
    echo ""
    echo -e "\033[1m Recovery image file already exists:\033[0m $file_location"
else
#Download file
    echo ""
    echo -e "\033[1m File not found\033[0m"
    echo -e "\033[1m Downloading: $file\033[0m"
    echo -e "\033[1m From: "https://store.steampowered.com/steamos/download/?ver=steamdeck"\033[0m"
    echo ""
    wget -c "$online"
fi

#Prompt user for the device path
    echo ""
    echo -e "\033[1m Important:\033[0m"
    echo -e "\033[1m Before proceeding, make sure that you have the correct device path\033[0m"
    echo -e "\033[1m Exercise extreme caution when dealing with possible data loss\033[0m"
    echo -e "\033[1m Incorrect usage may result in negative emotions\033[0m"
    echo ""
    echo -e "\033[1m Available devices:\033[0m"
    lsblk
    echo ""
    echo -e "\033[1m Enter the device path: e.g. sda \033[0m"
    read device_path

#Ask for confirmation
    echo -e "\033[1m Valve recommends a minimum of 8GB for the USB\033[0m"
    echo ""
    echo -e "\033[1m You have entered: $device_path\033[0m"
    lsblk -i /dev/$device_path
    echo ""
    echo -e "\033[1m Is this the correct device path? (yes/no)\033[0m"
    read confirmation
    echo ""

#Check user confirmation
if [[ "$confirmation" == "yes" || "$confirmation" == "y" ]]; then
#Use user input in the command
    bzcat "$file_location" | sudo dd if=/dev/stdin of="/dev/$device_path" oflag=sync status=progress bs=128M
else
    echo "Aborting operation."
    exit 0
fi

#Ask the user if they want to change their default password
    echo ""
    read -p "Do you want to change your password? (yes/no): " choice

#Check the user's response
if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
#Execute the passwd command
    passwd
else
    echo "No changes made"
fi

#Site: https://help.steampowered.com/en/faqs/view/1B71-EDF2-EB6D-2BB3
