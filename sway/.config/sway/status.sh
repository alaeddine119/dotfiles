#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"

# --- Colors (Catppuccin Macchiato) ---
C_RED="#eeeeee"    # Alerts, High Temp, Low Battery
C_YELLOW="#eeeeee" # Charging
C_GREEN="#eeeeee"  # Power Group
C_BLUE="#eeeeee"   # Network & Wireless Group
C_MAUVE="#eeeeee"  # System Hardware Group
C_PEACH="#eeeeee"  # UI / Peripherals Group
C_TEXT="#eeeeee"   # Default Text / Date
C_SEP="#eeeeee"    # Muted grey for separators

# --- CPU Helper Function ---
get_cpu_stats() {
  read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
  total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle_sum=$((idle + iowait))
  echo "$total $idle_sum"
}

# --- Escaping for Pango & JSON ---
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
weather_loop_count=0
bat_text="Loading..."
wifi_text=""
bt_text=""
net_speed_text=""
vol_text=""
disk_text=""
bright_text=""
temp_text=""
power_text=""
update_text=""
weather_text=""
layout_text=""
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

  # --- Keyboard Layout (UI Group: Peach) ---
  raw_layout=$(swaymsg -t get_inputs 2>/dev/null | grep -m1 'xkb_active_layout_name' | cut -d '"' -f4)
  if [[ "$raw_layout" == *"Arabic"* ]] || [[ "$raw_layout" == *"Morocco"* ]] || [[ "$raw_layout" == *"ma"* ]]; then
    layout_text="<span color='$C_TEXT'>AR </span>"
  elif [[ -n "$raw_layout" ]]; then
    layout_text="<span color='$C_TEXT'>EN </span>"
  else
    layout_text=""
  fi

  # --- CPU (System Group: Mauve) ---
  read -r curr_total curr_idle <<<"$(get_cpu_stats)"
  diff_idle=$((curr_idle - prev_idle))
  diff_total=$((curr_total - prev_total))

  if [ $diff_total -gt 0 ]; then
    usage=$(((100 * (diff_total - diff_idle)) / diff_total))
    cpu_pct=$(printf "%2d%%" "$usage")
  else
    cpu_pct="  0%"
  fi
  cpu_text="<span color='$C_MAUVE'>$cpu_pct </span>"
  prev_total=$curr_total
  prev_idle=$curr_idle

  # --- RAM (System Group: Mauve) ---
  ram_pct=$(free -m | awk '/^Mem/ { printf("%2d%%", $3/$2 * 100) }')
  ram_text="<span color='$C_MAUVE'>$ram_pct </span>"

  # --- Brightness (UI Group: Peach) ---
  raw_bright=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}')
  if [ -n "$raw_bright" ]; then
    bright_text="<span color='$C_PEACH'>$raw_bright 󰃠</span>"
  else
    bright_text="<span color='$C_PEACH'>--% 󰃠</span>"
  fi

  # --- Volume (UI Group: Peach) ---
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
    vol_text="<span color='$C_PEACH'>${vol_pct}% $vol_icon</span>"
  else
    vol_text="<span color='$C_PEACH'>--% </span>"
  fi

  # --- Network Speed (Network Group: Blue) ---
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

    net_speed_text="<span color='$C_BLUE'>$formatted_speed $icon</span>"
    prev_rx=$curr_rx
    prev_tx=$curr_tx
  else
    net_speed_text=""
  fi

  # --- Date (Neutral Text Color, No Icon) ---
  date_text="<span color='$C_TEXT'>$(date +'%a %-d %H:%M:%S')</span>"

  # ==========================================
  # 2. SLOW UPDATES (Every 5 seconds)
  # ==========================================
  if [ "$timer" -eq 0 ]; then

    # --- Sensors (Temperature & Power) ---
    sensors_out=$(sensors 2>/dev/null)

    raw_temp=$(echo "$sensors_out" | awk -F: '/Charge Regulator Temp/ { gsub(/[^0-9.]/,"",$2); v=$2+0; print int(v) }')
    if [ -n "$raw_temp" ]; then
      if [ "$raw_temp" -ge 70 ]; then
        temp_text="<span color='$C_RED'>${raw_temp}°C </span>"
      else
        temp_text="<span color='$C_MAUVE'>${raw_temp}°C </span>"
      fi
    else
      temp_text="<span color='$C_MAUVE'>--°C </span>"
    fi

    raw_power=$(echo "$sensors_out" | awk -F: '/Total System Power/ { gsub(/[^0-9.]/,"",$2); v=$2+0; print int(v) }')
    if [ -n "$raw_power" ]; then
      power_text="<span color='$C_GREEN'>${raw_power}W </span>"
    else
      power_text="<span color='$C_GREEN'>--W </span>"
    fi

    # --- Disk Space ---
    disk_free=$(df -m / | awk 'NR==2 { v=$4/1024; print int(v) }')
    disk_text="<span color='$C_MAUVE'>${disk_free}GB </span>"

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

    # --- Wi-Fi (PERFORMANCE FIX: Prioritize iwgetid over nmcli) ---
    if [ -f "/sys/class/net/$WIFI_IFACE/operstate" ] && [ "$(cat "/sys/class/net/$WIFI_IFACE/operstate")" = "up" ]; then
      wifi_up=1
      # Blazing fast direct query
      ssid=$(iwgetid -r 2>/dev/null)
      # Fallback to slow nmcli ONLY if iwgetid fails
      [ -z "$ssid" ] && ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
      [ -z "$ssid" ] && ssid="Connected"
      ssid=$(escape "$ssid")
      wifi_text="<span color='$C_BLUE'>$ssid 󰖩</span>"
    else
      wifi_up=0
      wifi_text=""
      net_speed_text=""
    fi

    # --- Native Bluetooth + Battery (PERFORMANCE FIX: Single D-Bus query) ---
    bt_text=""
    if bluetoothctl show | grep -q "Powered: yes"; then
      bt_mac=$(bluetoothctl devices Connected | awk '{print $2}' | head -n 1)

      if [ -n "$bt_mac" ]; then
        # Cache the info block in memory so we don't query D-Bus twice!
        bt_info_cache=$(bluetoothctl info "$bt_mac")

        bt_dev=$(echo "$bt_info_cache" | grep "Alias:" | sed 's/.*Alias: //')
        bt_bat=$(echo "$bt_info_cache" | awk -F'[()]' '/Battery Percentage/ {print $2}')

        if [ -n "$bt_dev" ]; then
          bt_dev_escaped=$(escape "$bt_dev")

          if [ -n "$bt_bat" ]; then
            if [ "$bt_bat" -le 20 ]; then
              bt_color="$C_RED"
            else
              bt_color="$C_GREEN"
            fi
            bt_text="<span color='$bt_color'>(${bt_bat}% 󰥉)</span> <span color='$C_BLUE'>$bt_dev_escaped 󰂱</span>"
          else
            bt_text="<span color='$C_BLUE'>$bt_dev_escaped 󰂱</span>"
          fi
        fi
      fi
    fi
  fi

  # ==========================================
  # 3. ULTRA SLOW UPDATES (Every 5min / 300 loops)
  # ==========================================
  # PERFORMANCE FIX: Make checkupdates asynchronous so it never freezes the bar!
  [ ! -f /tmp/sway_updates.txt ] && touch /tmp/sway_updates.txt

  if [ "$loop_count" -eq 0 ]; then
    (
      updates=$(checkupdates 2>/dev/null | wc -l)
      echo "$updates" >/tmp/sway_updates.txt
    ) &
  fi

  if [ -s /tmp/sway_updates.txt ]; then
    cached_updates=$(cat /tmp/sway_updates.txt)
    if [ "$cached_updates" -gt 0 ]; then
      update_text="<span color='$C_RED'>$cached_updates 󰚰</span>"
    else
      update_text=""
    fi
  else
    update_text=""
  fi

  # ==========================================
  # 4. WEATHER UPDATES (Asynchronous & Strict)
  # ==========================================
  if [ "$weather_loop_count" -eq 0 ]; then
    (
      raw_weather=$(curl -s -m 5 "https://wttr.in/Naples?format=%t%c" 2>/dev/null)
      if [[ "$raw_weather" == *"°"* ]]; then
        clean_weather=$(echo "$raw_weather" | sed 's/ //g' | sed \
          -e 's/☀️/ 󰖙/g' -e 's/⛅️\|⛅\|🌤️\|🌤/ 󰖕/g' -e 's/☁️\|☁/󰖐/g' \
          -e 's/🌧️\|🌧\|🌦️\|🌦/ 󰖖/g' -e 's/🌨️\|🌨/ 󰖘/g' -e 's/❄️\|❄/ /g' \
          -e 's/⛈️\|⛈\|🌩️\|🌩/ 󰖓/g' -e 's/🌫️\|🌫/ 󰖑/g' -e 's/🌙\|🌑/ 󰖔/g')
        echo "$clean_weather" >/tmp/sway_weather.txt
      else
        true >/tmp/sway_weather.txt
      fi
    ) &
  fi

  if [ -s /tmp/sway_weather.txt ]; then
    weather_text="<span color='$C_TEXT'>$(cat /tmp/sway_weather.txt)</span>"
  else
    weather_text=""
  fi

  # ==========================================
  # OUTPUT
  # ==========================================

  slots=()
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
  [ -n "$layout_text" ] && slots+=("$layout_text")
  [ -n "$weather_text" ] && slots+=("$weather_text")
  [ -n "$date_text" ] && slots+=("$date_text")

  final_output=""
  for slot in "${slots[@]}"; do
    if [ -z "$final_output" ]; then
      final_output="$slot"
    else
      final_output="${final_output} <span color='$C_SEP'>•</span> ${slot}"
    fi
  done

  # --- JSON SANITIZER ---
  safe_output="${final_output//$'\n'/ }"
  safe_output="${safe_output//\\/\\\\}"
  safe_output="${safe_output//\"/\\\"}"

  # Print using the robust i3bar JSON protocol
  printf ',[{"full_text": "%s", "markup": "pango"}]\n' "$safe_output"

  timer=$(((timer + 1) % 5))
  loop_count=$(((loop_count + 1) % 300))
  weather_loop_count=$(((weather_loop_count + 1) % 1800))
  sleep 1
done
