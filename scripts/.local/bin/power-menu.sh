#!/bin/bash
lock="🔒 Lock"
suspend="💤 Suspend"
logout="🚪 Logout"
reboot="♻️ Reboot"
shutdown="🛑 Shutdown"

# Rofi Command
selected=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi -dmenu -p "Power")

case $selected in
  "$lock") hyprlock ;;
  "$suspend") systemctl suspend ;;
  "$logout") swaymsg exit ;;
  "$reboot") systemctl reboot ;;
  "$shutdown") systemctl poweroff ;;
esac
