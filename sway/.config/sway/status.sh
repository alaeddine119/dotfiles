#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"

# --- CPU Helper Function ---
get_cpu_stats() {
    # SC2034 Fix: Use '_' for unused 'cpu' and 'guest' variables
    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_sum=$((idle + iowait))
    # Quote to prevent word splitting
    echo "$total $idle_sum"
}

# --- Network Helper: Initialize Baseline ---
if [ -r "/sys/class/net/$WIFI_IFACE/statistics/rx_bytes" ]; then
    # SC2162 Fix: Add -r to read
    read -r prev_rx <"/sys/class/net/$WIFI_IFACE/statistics/rx_bytes"
    read -r prev_tx <"/sys/class/net/$WIFI_IFACE/statistics/tx_bytes"
else
    prev_rx=0
    prev_tx=0
fi

# Initialize CPU baseline
# SC2162 and SC2046 Fix: Add -r and quote the subshell
read -r prev_total prev_idle <<<"$(get_cpu_stats)"
sleep 0.5

# Loop variables
timer=0
bat_text="Loading..."
wifi_text=""
bt_text=""
net_speed_text=""
vol_text=""
disk_text=""
wifi_up=0

while true; do
    # ==========================================
    # 1. FAST UPDATES (Every 1 second)
    # ==========================================

    # --- CPU ---
    read -r curr_total curr_idle <<<"$(get_cpu_stats)"
    diff_idle=$((curr_idle - prev_idle))
    diff_total=$((curr_total - prev_total))

    if [ $diff_total -gt 0 ]; then
        usage=$(((100 * (diff_total - diff_idle)) / diff_total))
        cpu_pct=$(printf "%2d%%" "$usage")
    else
        cpu_pct="  0%"
    fi
    prev_total=$curr_total
    prev_idle=$curr_idle

    # --- RAM ---
    ram_pct=$(free -m | awk '/^Mem/ { printf("%2d%%", $3/$2 * 100) }')

    # --- Volume (wpctl) ---
    raw_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

    if [ -n "$raw_vol" ]; then
        vol_pct=$(echo "$raw_vol" | awk '{print int($2 * 100)}')

        if [[ "$raw_vol" == *"[MUTED]"* ]] || [ "$vol_pct" -eq 0 ]; then
            vol_icon=""
        elif [ "$vol_pct" -lt 30 ]; then
            vol_icon=""
        elif [ "$vol_pct" -lt 70 ]; then
            vol_icon=""
        else
            vol_icon=""
        fi

        vol_text="${vol_pct}% $vol_icon"
    else
        vol_text=" --%"
    fi

    # --- Network Speed ---
    if [ $wifi_up -eq 1 ] && [ -r "/sys/class/net/$WIFI_IFACE/statistics/rx_bytes" ]; then
        read -r curr_rx <"/sys/class/net/$WIFI_IFACE/statistics/rx_bytes"
        read -r curr_tx <"/sys/class/net/$WIFI_IFACE/statistics/tx_bytes"

        down_speed=$((curr_rx - prev_rx))
        up_speed=$((curr_tx - prev_tx))

        if [ $down_speed -ge $up_speed ]; then
            bytes=$down_speed
            icon=""
        else
            bytes=$up_speed
            icon=""
        fi

        formatted_speed=$(awk -v b="$bytes" 'BEGIN {
            if (b >= 1048576) { printf "%.2fMb/s", b/1048576 }
            else { printf "%.0fKb/s", b/1024 }
        }')

        net_speed_text="$icon $formatted_speed"
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
    if [ "$timer" -eq 0 ]; then

        # --- Disk Space ---
        disk_free=$(df -m / | awk 'NR==2 { printf "%.1f GB", $4/1024 }')
        disk_text="$disk_free "

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
                time_str=$(printf "(%dh %02dm)" "$h" "$m")
            fi
            bat_text="$time_str $cap_str $icon"
        else
            bat_text="No Bat"
        fi

        # --- Wi-Fi ---
        if [ -f "/sys/class/net/$WIFI_IFACE/operstate" ] && [ "$(cat "/sys/class/net/$WIFI_IFACE/operstate")" = "up" ]; then
            wifi_up=1
            ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
            [ -z "$ssid" ] && ssid=$(iwgetid -r 2>/dev/null)
            [ -z "$ssid" ] && ssid="Connected"
            wifi_text="$ssid 󰖩"
        else
            wifi_up=0
            wifi_text="󰖪 Off"
            net_speed_text=""
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
    echo "$net_speed_text | $wifi_text | $bt_text | $cpu_pct  | $ram_pct  | $disk_text | $vol_text | $bat_text | $date_time"

    timer=$(((timer + 1) % 5))
    sleep 1
done
