#!/bin/bash

# Get Status
STATUS=$(nmcli -t -f WIFI g)

if [ "$STATUS" = "enabled" ]; then
    # Get SSID and Signal Strength
    # This returns something like: yes:MyNetwork:85
    WIFI_INFO=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes')

    if [ -n "$WIFI_INFO" ]; then
        # Parse the info
        SSID=$(echo "$WIFI_INFO" | cut -d: -f2)
        SIGNAL=$(echo "$WIFI_INFO" | cut -d: -f3)

        # Optional: Get IP Address
        IP=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

        # JSON with Tooltip
        echo "{\"text\": \"$SSID\", \"alt\": \"connected\", \"class\": \"connected\", \"tooltip\": \"<b>SSID:</b> $SSID\n<b>Signal:</b> $SIGNAL%\n<b>IP:</b> $IP\"}"
    else
        # On but disconnected
        echo "{\"text\": \"Disconnected\", \"alt\": \"disconnected\", \"class\": \"disconnected\", \"tooltip\": \"WiFi On\nDisconnected\"}"
    fi
else
    # WiFi Off
    echo "{\"text\": \"Off\", \"alt\": \"off\", \"class\": \"off\", \"tooltip\": \"WiFi Off\"}"
fi
