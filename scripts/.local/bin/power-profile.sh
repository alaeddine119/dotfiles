#!/bin/bash

# Get current active profile to display in the Rofi prompt
active=$(tuned-adm active | awk '{print $4}')

# Define the options with emojis
asahi="🍏 Asahi Battery (Custom Zero-Error)"
default="🍎 Asahi Default (Pure Kernel)"
powersave="🔋 Powersave (Max Endurance)"
smart="⚡ Smart Battery (balanced-battery)"
balanced="⚖️ Balanced (Daily Driver)"
performance="🚀 Performance (Max Power)"

# Rofi Command
selected=$(echo -e "$asahi\n$default\n$powersave\n$smart\n$balanced\n$performance" | rofi -dmenu -i -p "TuneD ($active)")

case $selected in
  "$asahi")
    tuned-adm profile asahi-battery
    notify-send -u normal "TuneD" "Profile set to 🍏 Asahi Battery"
    ;;
  "$default")
    tuned-adm profile default
    notify-send -u normal "TuneD" "Profile set to 🍎 Asahi Default"
    ;;
  "$powersave")
    tuned-adm profile powersave
    notify-send -u normal "TuneD" "Profile set to 🔋 Powersave"
    ;;
  "$smart")
    tuned-adm profile balanced-battery
    notify-send -u normal "TuneD" "Profile set to ⚡ Smart Battery"
    ;;
  "$balanced")
    tuned-adm profile balanced
    notify-send -u normal "TuneD" "Profile set to ⚖️ Balanced"
    ;;
  "$performance")
    tuned-adm profile throughput-performance
    notify-send -u normal "TuneD" "Profile set to 🚀 Performance"
    ;;
esac
