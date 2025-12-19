#!/bin/bash

# INTERFACE NAME
IFACE="wlp1s0f0"

# Get raw status from iwd
RAW_OUTPUT=$(iwctl station "$IFACE" show)

# Parse the State (connected, disconnected, etc.)
STATE=$(echo "$RAW_OUTPUT" | grep "State" | awk '{$1=""; print $0}' | xargs)

if [[ "$STATE" == "connected" ]]; then
    # Extract SSID (Take the rest of the line after "Connected network")
    SSID=$(echo "$RAW_OUTPUT" | grep "Connected network" | sed 's/.*Connected network\s*//')
    
    # Extract RSSI (Use head -n 1 to prevent getting "Average RSSI" too)
    RSSI_DBM=$(echo "$RAW_OUTPUT" | grep "RSSI" | head -n 1 | awk '{print $2}')
    
    # Default to -100 if empty to prevent math errors
    if [[ -z "$RSSI_DBM" ]]; then RSSI_DBM=-100; fi

    # Calculate Signal %
    SIGNAL=$(( 2 * (RSSI_DBM + 100) ))
    if [ "$SIGNAL" -gt 100 ]; then SIGNAL=100; fi
    if [ "$SIGNAL" -lt 0 ]; then SIGNAL=0; fi

    # Get IP Address
    IP=$(ip -4 addr show "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
    if [[ -z "$IP" ]]; then IP="No IP"; fi

    # Escape quotes in SSID just in case
    SSID_ESCAPED=${SSID//\"/\\\"}

    # JSON Output
    printf '{"text": "%s", "alt": "connected", "class": "connected", "tooltip": "<b>SSID:</b> %s\\n<b>Signal:</b> %s%% (%s dBm)\\n<b>IP:</b> %s"}\n' \
        "$SSID_ESCAPED" "$SSID_ESCAPED" "$SIGNAL" "$RSSI_DBM" "$IP"

elif [[ "$STATE" == "disconnected" || "$STATE" == "scanning" ]]; then
    printf '{"text": "Disconnected", "alt": "disconnected", "class": "disconnected", "tooltip": "WiFi On\\nState: %s"}\n' "$STATE"

else
    printf '{"text": "Off", "alt": "off", "class": "off", "tooltip": "WiFi Off"}\n'
fi
