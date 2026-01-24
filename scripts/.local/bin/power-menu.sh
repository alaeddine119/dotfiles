#!/bin/bash
lock="🔒 Lock"
suspend="💤 Suspend"
logout="🚪 Logout"
reboot="♻️ Reboot"
shutdown="🛑 Shutdown"

# Rofi Command
selected=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi -dmenu -p "Power")

case $selected in
    "$lock") swaylock -f --screenshots --clock --indicator --effect-scale 0.5 --effect-blur 7x5 --effect-scale 2 ;;
    "$suspend") systemctl suspend ;;
    "$logout") swaymsg exit ;;
    "$reboot") systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
