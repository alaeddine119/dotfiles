#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"

# --- CPU Helper Function ---
get_cpu_stats() {
    read -r cpu user nice system idle iowait irq softirq steal guest < /proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_sum=$((idle + iowait))
    echo $total $idle_sum
}

# Initialize CPU baseline
read prev_total prev_idle <<< $(get_cpu_stats)
sleep 0.5 

# Loop variables
timer=0
bat_text="Loading..."
wifi_text=""
bt_text=""

while true; do
    # ==========================================
    # 1. FAST UPDATES (Every 1 second)
    # ==========================================
    
    # --- CPU ---
    read curr_total curr_idle <<< $(get_cpu_stats)
    diff_idle=$((curr_idle - prev_idle))
    diff_total=$((curr_total - prev_total))
    
    if [ $diff_total -gt 0 ]; then
        usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
        # Fixed width: 3 characters (e.g., "  5%" or " 50%" or "100%")
        # We use %3d because CPU can hit 100
        cpu_pct=$(printf "%2d%%" $usage)
    else
        cpu_pct="  0%"
    fi
    prev_total=$curr_total
    prev_idle=$curr_idle

    # --- RAM ---
    # Fixed width: 3 characters (matches CPU)
    ram_pct=$(free -m | awk '/^Mem/ { printf("%2d%%", $3/$2 * 100) }')
    
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
                icon="🔋"
            elif [ "$status" = "Charging" ]; then
                seconds=$(cat "$BAT_PATH/time_to_full_now" 2>/dev/null || echo 0)
                icon="⚡"
            else
                icon="🔋"
            fi

            # --- Fixed Width Formatting ---
            
            # 1. Battery Percentage: Always 3 digits (e.g. " 50%" or "100%")
            cap_str=$(printf "%2d%%" "$capacity")

            # 2. Time Remaining: Fixed width "( 4h 05m)"
            time_str=""
            if [ "$seconds" -gt 0 ]; then
                h=$((seconds / 3600))
                m=$(( (seconds % 3600) / 60 ))
                # %2d adds space for hours < 10 (e.g. " 4h")
                # %02d adds zero for minutes < 10 (e.g. "05m")
                # Result: "( 4h 05m)"
                time_str=$(printf " (%2dh %02dm)" $h $m)
            fi
            
            bat_text="$icon $cap_str$time_str"
        else
            bat_text="No Bat"
        fi

        # --- Wi-Fi ---
        if [ -f "/sys/class/net/$WIFI_IFACE/operstate" ] && [ "$(cat /sys/class/net/$WIFI_IFACE/operstate)" = "up" ]; then
            ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
            [ -z "$ssid" ] && ssid=$(iwgetid -r 2>/dev/null) 
            [ -z "$ssid" ] && ssid="Connected"
            wifi_text="📡 $ssid"
        else
            wifi_text="📡 Off"
        fi

        # --- Bluetooth ---
        if bluetoothctl show | grep -q "Powered: yes"; then
            bt_dev=$(bluetoothctl info | grep "Alias" | head -n 1 | cut -d: -f2 | xargs)
            if [ -n "$bt_dev" ]; then
                bt_text="🎧 $bt_dev"
            else
                bt_text="🔵 On"
            fi
        else
            bt_text="⚪ Off"
        fi

    fi

    # ==========================================
    # OUTPUT
    # ==========================================
    echo "$wifi_text | $bt_text | 💻 $cpu_pct | 💾 $ram_pct | $bat_text | $date_time"
    
    timer=$(( (timer + 1) % 5 ))
    sleep 1
done
