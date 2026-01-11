#!/bin/bash

# Define the icons and labels
lock="🔒 Lock"
suspend="💤 Suspend"
reboot="🔄 Reboot"
shutdown="⏻ Shutdown"
logout="🚪 Logout"

# Show the menu using Fuzzel
# -d: dmenu mode
# -p: prompt text
# -w: width (characters)
# -l: lines (height)
selected=$(echo -e "$lock\n$suspend\n$reboot\n$shutdown\n$logout" | fuzzel -d -p "Power: " -w 20 -l 5)

case $selected in
    "$lock")
        swaylock -f --screenshots --clock --indicator --effect-scale 0.5 --effect-blur 7x5 --effect-scale 2 ;;
    "$suspend")
        systemctl suspend ;;
    "$reboot")
        systemctl reboot ;;
    "$shutdown")
        systemctl poweroff ;;
    "$logout")
        swaymsg exit ;;
esac
