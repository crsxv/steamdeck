#!/bin/bash

# Get the display names using `xrandr`
display_names=$(xrandr | awk '/ connected / {print $1}')

# Loop through the display names
for display in $display_names; do
  # Check if the display name is not "Built-in Screen"
  if [ "$display" != "DisplayPort-0" ]; then
# Set the primary display to the current display and disable built-in screen
    xrandr --output $display --primary
    xrandr --output eDP --off
    break
  fi
done
