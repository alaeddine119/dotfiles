#!/bin/bash

# Dependency Check
if ! command -v yad &> /dev/null; then
    echo "Error: yad is not installed. Run 'sudo pacman -S yad'"
    exit 1
fi

# --- DATA GATHERING ---

# Get Current Defaults
CUR_SINK=$(pactl get-default-sink)
CUR_SOURCE=$(pactl get-default-source)

# Get Current Volumes (Parse percentages, e.g., "50")
# We use head -n1 because stereo signals return left/right volume separately
VOL_SINK=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1 | tr -d '%')
VOL_SOURCE=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -n1 | tr -d '%')

# Get Mute Status (Returns "yes" or "no")
MUTE_SINK=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
MUTE_SOURCE=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

# Convert yes/no to TRUE/FALSE for Yad Checkboxes
if [ "$MUTE_SINK" == "yes" ]; then CHK_SINK="TRUE"; else CHK_SINK="FALSE"; fi
if [ "$MUTE_SOURCE" == "yes" ]; then CHK_SOURCE="TRUE"; else CHK_SOURCE="FALSE"; fi

# Generate Lists for Dropdowns (Format: Item1!Item2!Item3)
# We put the Current Device FIRST so it appears as the default selected option
LIST_SINKS=$(pactl list short sinks | cut -f2)
LIST_SOURCES=$(pactl list short sources | cut -f2)

# Format Sinks: Put current first, then the rest, joined by '!'
FORMATTED_SINKS="$CUR_SINK!$(echo "$LIST_SINKS" | grep -v "$CUR_SINK" | tr '\n' '!')"

# Format Sources: Put current first, then the rest, joined by '!'
FORMATTED_SOURCES="$CUR_SOURCE!$(echo "$LIST_SOURCES" | grep -v "$CUR_SOURCE" | tr '\n' '!')"

# --- YAD GUI ---

OUTPUT=$(yad --form --title="Audio Control" \
    --width=400 --center \
    --window-icon="multimedia-volume-control" \
    --image="multimedia-volume-control" \
    --separator="|" \
    --field="<b>OUTPUT (Speakers)</b>":LBL "" \
    --field="Device":CB "$FORMATTED_SINKS" \
    --field="Volume":SCL "$VOL_SINK" \
    --field="Mute":CHK "$CHK_SINK" \
    --field="<b>INPUT (Microphone)</b>":LBL "" \
    --field="Device":CB "$FORMATTED_SOURCES" \
    --field="Volume":SCL "$VOL_SOURCE" \
    --field="Mute":CHK "$CHK_SOURCE" \
    --button="Cancel":1 \
    --button="Apply":0)

# Exit if user canceled
STATUS=$?
if [ $STATUS -ne 0 ]; then exit 0; fi

# --- PARSE & APPLY ---

# Read the pipe-delimited output
# Fields: Label | Sink_Name | Sink_Vol | Sink_Mute | Label | Source_Name | Source_Vol | Source_Mute |
NEW_SINK=$(echo "$OUTPUT" | awk -F'|' '{print $2}')
NEW_SINK_VOL=$(echo "$OUTPUT" | awk -F'|' '{print $3}')
NEW_SINK_MUTE=$(echo "$OUTPUT" | awk -F'|' '{print $4}')

NEW_SOURCE=$(echo "$OUTPUT" | awk -F'|' '{print $6}')
NEW_SOURCE_VOL=$(echo "$OUTPUT" | awk -F'|' '{print $7}')
NEW_SOURCE_MUTE=$(echo "$OUTPUT" | awk -F'|' '{print $8}')

# 1. Set Defaults
pactl set-default-sink "$NEW_SINK"
pactl set-default-source "$NEW_SOURCE"

# 2. Set Volumes
pactl set-sink-volume "$NEW_SINK" "${NEW_SINK_VOL}%"
pactl set-source-volume "$NEW_SOURCE" "${NEW_SOURCE_VOL}%"

# 3. Set Mute States
if [ "$NEW_SINK_MUTE" == "TRUE" ]; then
    pactl set-sink-mute "$NEW_SINK" 1
else
    pactl set-sink-mute "$NEW_SINK" 0
fi

if [ "$NEW_SOURCE_MUTE" == "TRUE" ]; then
    pactl set-source-mute "$NEW_SOURCE" 1
else
    pactl set-source-mute "$NEW_SOURCE" 0
fi

