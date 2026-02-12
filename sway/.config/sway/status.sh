#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"

# --- CPU Helper Function ---
get_cpu_stats() {
    read -r cpu user nice system idle iowait irq softirq steal guest </proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_sum=$((idle + iowait))
    echo $total $idle_sum
}

# --- Network Helper: Initialize Baseline ---
# We read this once before the loop to calculate the delta correctly in the first second
if [ -r "/sys/class/net/$WIFI_IFACE/statistics/rx_bytes" ]; then
    read prev_rx <"/sys/class/net/$WIFI_IFACE/statistics/rx_bytes"
    read prev_tx <"/sys/class/net/$WIFI_IFACE/statistics/tx_bytes"
else
    prev_rx=0
    prev_tx=0
fi

# Initialize CPU baseline
read prev_total prev_idle <<<$(get_cpu_stats)
sleep 0.5

# Loop variables
timer=0
bat_text="Loading..."
wifi_text=""
bt_text=""
net_speed_text=""
wifi_up=0

while true; do
    # ==========================================
    # 1. FAST UPDATES (Every 1 second)
    # ==========================================

    # --- CPU ---
    read curr_total curr_idle <<<$(get_cpu_stats)
    diff_idle=$((curr_idle - prev_idle))
    diff_total=$((curr_total - prev_total))

    if [ $diff_total -gt 0 ]; then
        usage=$(((100 * (diff_total - diff_idle)) / diff_total))
        cpu_pct=$(printf "%2d%%" $usage)
    else
        cpu_pct="  0%"
    fi
    prev_total=$curr_total
    prev_idle=$curr_idle

    # --- RAM ---
    ram_pct=$(free -m | awk '/^Mem/ { printf("%2d%%", $3/$2 * 100) }')

    # --- Network Speed (Upload/Download) ---
    # Only calculate if Wifi was detected as UP in the slow loop
    if [ $wifi_up -eq 1 ] && [ -r "/sys/class/net/$WIFI_IFACE/statistics/rx_bytes" ]; then
        read curr_rx <"/sys/class/net/$WIFI_IFACE/statistics/rx_bytes"
        read curr_tx <"/sys/class/net/$WIFI_IFACE/statistics/tx_bytes"

        # Calculate bytes per second (since sleep is 1s)
        down_speed=$((curr_rx - prev_rx))
        up_speed=$((curr_tx - prev_tx))

        # Determine if we show Download or Upload (whichever is significant)
        if [ $down_speed -ge $up_speed ]; then
            bytes=$down_speed
            # Icon: Download ()
            icon=""
        else
            bytes=$up_speed
            # Icon: Upload ()
            icon=""
        fi

        # Format: 450Kb/s (no decimal) or 1.24Mb/s (2 decimals)
        formatted_speed=$(awk -v b="$bytes" 'BEGIN {
            if (b >= 1048576) {
                printf "%.2fMb/s", b/1048576
            } else {
                printf "%.0fKb/s", b/1024
            }
        }')

        net_speed_text="$formatted_speed $icon"

        # Update baselines
        prev_rx=$curr_rx
        prev_tx=$curr_tx
    else
        net_speed_text=""
    fi

    # --- Date ---
    date_time=$(date +'%Y-%m-%d %H:%M:%S')

    # ==========================================
    # 2. SLOW UPDATES (Every 5 seconds)
    # ==========================================
    if [ $timer -eq 0 ]; then

        # --- Battery ---
        if [ -d "$BAT_PATH" ]; then
            status=$(cat "$BAT_PATH/status")
            capacity=$(cat "$BAT_PATH/capacity")

            seconds=0
            if [ "$status" = "Discharging" ]; then
                seconds=$(cat "$BAT_PATH/time_to_empty_now" 2>/dev/null || echo 0)
                icon="󱟞"
            elif [ "$status" = "Charging" ]; then
                seconds=$(cat "$BAT_PATH/time_to_full_now" 2>/dev/null || echo 0)
                icon="󱟠"
            else
                icon="󰁹"
            fi

            cap_str=$(printf "%2d%%" "$capacity")

            time_str=""
            if [ "$seconds" -gt 0 ]; then
                h=$((seconds / 3600))
                m=$(((seconds % 3600) / 60))
                time_str=$(printf "(%dh %02dm)" $h $m)
            fi

            bat_text="$time_str $cap_str $icon"
        else
            bat_text="No Bat"
        fi

        # --- Wi-Fi ---
        if [ -f "/sys/class/net/$WIFI_IFACE/operstate" ] && [ "$(cat /sys/class/net/$WIFI_IFACE/operstate)" = "up" ]; then
            wifi_up=1
            ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
            [ -z "$ssid" ] && ssid=$(iwgetid -r 2>/dev/null)
            [ -z "$ssid" ] && ssid="Connected"
            wifi_text="$ssid 󰖩"
        else
            wifi_up=0
            wifi_text="󰖪 Off"
            net_speed_text="" # Clear speed immediately if wifi drops
        fi

        # --- Bluetooth ---
        if bluetoothctl show | grep -q "Powered: yes"; then
            bt_dev=$(bluetoothctl info | grep "Alias" | head -n 1 | cut -d: -f2 | xargs)
            if [ -n "$bt_dev" ]; then
                bt_text="$bt_dev 󰂱"
            else
                bt_text="On 󰂯"
            fi
        else
            bt_text="Off 󰂲"
        fi

    fi

    # ==========================================
    # OUTPUT
    # ==========================================
    # Added $net_speed_text next to $wifi_text
    echo "$net_speed_text | $wifi_text | $bt_text | $cpu_pct  | $ram_pct  | $bat_text | $date_time"

    timer=$(((timer + 1) % 5))
    sleep 1
done
