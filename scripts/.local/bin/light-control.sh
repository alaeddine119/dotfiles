#!/bin/bash

# --- 1. Define Devices ---
DEV_SCREEN="apple-panel-bl"
DEV_TOUCHBAR="228600000.dsi.0"
DEV_KBD="kbd_backlight"

# --- 2. Get Current Values ---
# We use 'g' (get) and 'm' (max)
VAL_S=$(brightnessctl -d "$DEV_SCREEN" g)
MAX_S=$(brightnessctl -d "$DEV_SCREEN" m)

VAL_T=$(brightnessctl -d "$DEV_TOUCHBAR" g)
MAX_T=$(brightnessctl -d "$DEV_TOUCHBAR" m)

VAL_K=$(brightnessctl -d "$DEV_KBD" g)
MAX_K=$(brightnessctl -d "$DEV_KBD" m)

# --- 3. The Dialog ---
# --width=500  : Sets a fixed wide width so sliders are long enough
# --fixed      : Prevents the window from auto-shrinking or resizing weirdly
# --center     : Forces it to the middle of the screen
# --undecorated: (Optional) Removes window borders for a cleaner "floating box" look

OUTPUT=$(yad --form \
	--title="System Brightness" \
	--center \
	--width=500 \
	--height=200 \
	--window-icon="preferences-system" \
	--text="<span size='large' weight='bold'>Brightness Controls</span>" \
	--text-align=center \
	--field="Screen":SCL "$VAL_S:0:$MAX_S:1" \
	--field="Touch Bar":SCL "$VAL_T:0:$MAX_T:1" \
	--field="Keyboard":SCL "$VAL_K:0:$MAX_K:1" \
	--button="Cancel:1" \
	--button="Apply:0")

# --- 4. Apply Changes ---
if [ $? -eq 0 ]; then
	# Extract values (yad returns: val1|val2|val3|)
	NEW_S=$(echo "$OUTPUT" | awk -F'|' '{print $1}')
	NEW_T=$(echo "$OUTPUT" | awk -F'|' '{print $2}')
	NEW_K=$(echo "$OUTPUT" | awk -F'|' '{print $3}')

	brightnessctl -q -d "$DEV_SCREEN" s "$NEW_S"
	brightnessctl -q -d "$DEV_TOUCHBAR" s "$NEW_T"
	brightnessctl -q -d "$DEV_KBD" s "$NEW_K"
fi
