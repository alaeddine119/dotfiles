#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"

# Invisible Left-To-Right Mark (U+200E)
LRM=$'\u200E'

# --- Colors (Catppuccin Macchiato) ---
C_RED="#ed8796"
C_YELLOW="#eed49f"
C_GREEN="#a6da95"
C_BLUE="#8aadf4"
C_MAUVE="#c6a0f6"
C_TEAL="#8bd5ca"
C_PEACH="#f5a97f"
C_ROSE="#f4dbd6"
C_LAVENDER="#b7bdf8"
C_FLAMINGO="#f0c6c6"
C_TEXT="#cad3f5"

# --- CPU Helper Function ---
get_cpu_stats() {
    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_sum=$((idle + iowait))
    echo "$total $idle_sum"
}

# --- Escaping for Pango & JSON ---
# Protects the renderer from crashing if a title contains <, >, &, \, or "
escape() {
    local t="$1"
    t="${t//&/&amp;}"
    t="${t//</&lt;}"
    t="${t//>/&gt;}"
    t="${t//\\/\\\\}"
    t="${t//\"/\\\"}"
    echo "$t"
}

# --- Network Helper: Initialize Baseline ---
if [ -r "/sys/class/net/$WIFI_IFACE/statistics/rx_bytes" ]; then
    read -r prev_rx <"/sys/class/net/$WIFI_IFACE/statistics/rx_bytes"
    read -r prev_tx <"/sys/class/net/$WIFI_IFACE/statistics/tx_bytes"
else
    prev_rx=0
    prev_tx=0
fi

read -r prev_total prev_idle <<<"$(get_cpu_stats)"
sleep 0.5

timer=0
loop_count=0
bat_text="Loading..."
wifi_text=""
bt_text=""
net_speed_text=""
vol_text=""
disk_text=""
bright_text=""
temp_text=""
power_text=""
media_text=""
update_text=""
wifi_up=0

# ==========================================
# JSON PROTOCOL HEADER (REQUIRED FOR COLORS)
# ==========================================
echo '{ "version": 1 }'
echo '['
echo '[]'

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
    cpu_text="<span color='$C_PEACH'>$cpu_pct </span>"
    prev_total=$curr_total
    prev_idle=$curr_idle

    # --- RAM ---
    ram_pct=$(free -m | awk '/^Mem/ { printf("%2d%%", $3/$2 * 100) }')
    ram_text="<span color='$C_MAUVE'>$ram_pct </span>"

    # --- Brightness ---
    raw_bright=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}')
    if [ -n "$raw_bright" ]; then
        bright_text="<span color='$C_ROSE'>$raw_bright 󰃠</span>"
    else
        bright_text="<span color='$C_ROSE'>--% 󰃠</span>"
    fi

    # --- Volume ---
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
        vol_text="<span color='$C_LAVENDER'>${vol_pct}% $vol_icon</span>"
    else
        vol_text="<span color='$C_LAVENDER'>--% </span>"
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
            if (b >= 10480517) { printf "%4.2f Gb/s", b/1073741824 }
            else if (b >= 10235) { printf "%4.2f Mb/s", b/1048576 }
            else if (b >= 10) { printf "%4.2f Kb/s", b/1024 }
            else { printf "%4.2f  B/s", b }
        }')

        net_speed_text="<span color='$C_TEXT'>$formatted_speed $icon</span>"
        prev_rx=$curr_rx
        prev_tx=$curr_tx
    else
        net_speed_text=""
    fi

    # --- Date ---
    date_text="<span color='$C_TEXT'>$(date +'%a %-d %H:%M:%S') </span>"

    # ==========================================
    # 2. SLOW UPDATES (Every 5 seconds)
    # ==========================================
    if [ "$timer" -eq 0 ]; then

        # --- Sensors (Temperature & Power) ---
        sensors_out=$(sensors 2>/dev/null)

        raw_temp=$(echo "$sensors_out" | awk -F: '/Charge Regulator Temp/ { gsub(/[^0-9.]/,"",$2); v=$2+0; print (v == int(v) ? v : int(v)+1) }')
        if [ -n "$raw_temp" ]; then
            if [ "$raw_temp" -ge 70 ]; then
                temp_text="<span color='$C_RED'>${raw_temp}°C </span>"
            else
                temp_text="<span color='$C_TEXT'>${raw_temp}°C </span>"
            fi
        else
            temp_text="<span color='$C_TEXT'>--°C </span>"
        fi

        raw_power=$(echo "$sensors_out" | awk -F: '/Total System Power/ { gsub(/[^0-9.]/,"",$2); v=$2+0; print (v == int(v) ? v : int(v)+1) }')
        if [ -n "$raw_power" ]; then
            power_text="<span color='$C_FLAMINGO'>${raw_power}W </span>"
        else
            power_text="<span color='$C_FLAMINGO'>--W </span>"
        fi

        # --- Disk Space ---
        disk_free=$(df -m / | awk 'NR==2 { v=$4/1024; print (v == int(v) ? v : int(v)-1) }')
        disk_text="<span color='$C_TEAL'>${disk_free}GB </span>"

        # --- Battery ---
        if [ -d "$BAT_PATH" ]; then
            status=$(cat "$BAT_PATH/status")
            capacity=$(cat "$BAT_PATH/capacity")
            seconds=0

            if [ "$status" = "Discharging" ]; then
                seconds=$(cat "$BAT_PATH/time_to_empty_now" 2>/dev/null || echo 0)
                icon="󱟞"
                if [ "$capacity" -le 20 ]; then
                    bat_color="$C_RED"
                else
                    bat_color="$C_GREEN"
                fi
            elif [ "$status" = "Charging" ]; then
                seconds=$(cat "$BAT_PATH/time_to_full_now" 2>/dev/null || echo 0)
                icon="󱟠"
                bat_color="$C_YELLOW"
            else
                icon="󰁹"
                bat_color="$C_GREEN"
            fi

            cap_str=$(printf "%2d%%" "$capacity")
            time_str=""
            if [ "$seconds" -gt 0 ]; then
                h=$((seconds / 3600))
                m=$(((seconds % 3600) / 60))
                time_str=$(printf "(%dh %02dm)" "$h" "$m")
            fi
            bat_text="<span color='$bat_color'>$time_str $cap_str $icon</span>"
        else
            bat_text=""
        fi

        # --- Wi-Fi ---
        if [ -f "/sys/class/net/$WIFI_IFACE/operstate" ] && [ "$(cat "/sys/class/net/$WIFI_IFACE/operstate")" = "up" ]; then
            wifi_up=1
            ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
            [ -z "$ssid" ] && ssid=$(iwgetid -r 2>/dev/null)
            [ -z "$ssid" ] && ssid="Connected"
            ssid=$(escape "$ssid")
            wifi_text="<span color='$C_GREEN'>$ssid 󰖩</span>"
        else
            wifi_up=0
            wifi_text=""
            net_speed_text=""
        fi

        # --- Bluetooth ---
        if bluetoothctl show | grep -q "Powered: yes"; then
            bt_dev=$(bluetoothctl info | grep "Alias" | head -n 1 | cut -d: -f2 | xargs)
            if [ -n "$bt_dev" ]; then
                bt_dev=$(escape "$bt_dev")
                bt_text="<span color='$C_BLUE'>$bt_dev 󰂱</span>"
            else
                bt_text=""
            fi
        else
            bt_text=""
        fi
    fi

    # ==========================================
    # 3. ULTRA SLOW UPDATES (Every 5min / 300 loops)
    # ==========================================
    if [ "$loop_count" -eq 0 ]; then
        updates=$(checkupdates 2>/dev/null | wc -l)
        if [ "$updates" -gt 0 ]; then
            update_text="<span color='$C_RED'>$updates 󰚰</span>"
        else
            update_text=""
        fi
    fi

    # ==========================================
    # OUTPUT
    # ==========================================

    slots=()
    [ -n "$media_text" ] && slots+=("$media_text")
    [ -n "$update_text" ] && slots+=("$update_text")
    [ -n "$net_speed_text" ] && slots+=("$net_speed_text")
    [ -n "$wifi_text" ] && slots+=("$wifi_text")
    [ -n "$bt_text" ] && slots+=("$bt_text")
    [ -n "$cpu_text" ] && slots+=("$cpu_text")
    [ -n "$ram_text" ] && slots+=("$ram_text")
    [ -n "$disk_text" ] && slots+=("$disk_text")
    [ -n "$temp_text" ] && slots+=("$temp_text")
    [ -n "$bright_text" ] && slots+=("$bright_text")
    [ -n "$vol_text" ] && slots+=("$vol_text")
    [ -n "$power_text" ] && slots+=("$power_text")
    [ -n "$bat_text" ] && slots+=("$bat_text")
    [ -n "$date_text" ] && slots+=("$date_text")

    final_output=""
    for slot in "${slots[@]}"; do
        if [ -z "$final_output" ]; then
            final_output="$slot"
        else
            final_output="${final_output} <span color='$C_TEXT'>${LRM}|${LRM}</span> ${slot}"
        fi
    done

    # Print using the robust i3bar JSON protocol
    printf ',[{"full_text": "%s", "markup": "pango"}]\n' "$final_output"

    timer=$(((timer + 1) % 5))
    loop_count=$(((loop_count + 1) % 300))
    sleep 1
done
