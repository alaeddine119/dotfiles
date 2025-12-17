#!/bin/bash

# Check if powered on
POWER=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$POWER" ]; then
    echo "{\"text\": \"Off\", \"alt\": \"off\", \"class\": \"off\", \"tooltip\": \"Bluetooth Off\"}"
    exit
fi

# Check connection info
# We grab Name and Battery Percentage if available
DEVICE_NAME=$(bluetoothctl info | grep "Name:" | cut -d ' ' -f 2-)
DEVICE_BATTERY=$(bluetoothctl info | grep "Battery Percentage:" | cut -d '(' -f 2 | cut -d ')' -f 1)

if [ -n "$DEVICE_NAME" ]; then
    if [ -n "$DEVICE_BATTERY" ]; then
         TOOLTIP="<b>Device:</b> $DEVICE_NAME\n<b>Battery:</b> $DEVICE_BATTERY%"
    else
         TOOLTIP="<b>Device:</b> $DEVICE_NAME"
    fi

    echo "{\"text\": \"$DEVICE_NAME\", \"alt\": \"connected\", \"class\": \"connected\", \"tooltip\": \"$TOOLTIP\"}"
else
    echo "{\"text\": \"On\", \"alt\": \"on\", \"class\": \"on\", \"tooltip\": \"Bluetooth On\nNo Device Connected\"}"
fi
