#!/bin/bash

# --- Configuration ---
# Battery Path
BAT_PATH="/sys/class/power_supply/macsmc-battery"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

# Wifi Interface
WIFI_IFACE="wlan0"
# Auto-detect the exact Asahi Wi-Fi Interface (e.g., wlp1s0f0) using nmcli
WIFI_IFACE=$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi" {print $1; exit}')
[ -z "$WIFI_IFACE" ] && WIFI_IFACE="wlan0"

# --- Colors (Catppuccin Macchiato) ---
C_RED="#eeeeee"    # Alerts, High Temp, Low Battery
C_YELLOW="#eeeeee" # Charging
C_GREEN="#eeeeee"  # Power Group
C_BLUE="#eeeeee"   # Network & Wireless Group
C_MAUVE="#eeeeee"  # System Hardware Group
C_PEACH="#eeeeee"  # UI / Peripherals Group
C_TEXT="#eeeeee"   # Default Text / Date
C_SEP="#eeeeee"    # Muted grey for separators

# --- BiDi Isolation Controls (Fixes Arabic/RTL Layout Jumping) ---
LRM=$(printf '\u200E') # Left-to-Right Mark

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

# Inline initial CPU stats read to avoid fork
read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
prev_idle=$((idle + iowait))

timer=0
loop_count=0
weather_loop_count=0
media_scroll=0
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

# Find native backlight path to avoid invoking brightnessctl entirely
BL_DIR="/sys/class/backlight/apple_screen"
[ ! -d "$BL_DIR" ] && BL_DIR=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)

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
  raw_layout=$(swaymsg -t get_inputs 2>/dev/null)
  if [[ "$raw_layout" =~ \"xkb_active_layout_name\":[[:space:]]*\"([^\"]+)\" ]]; then
    parsed_layout="${BASH_REMATCH[1]}"
    if [[ "$parsed_layout" == *"Arabic"* ]] || [[ "$parsed_layout" == *"Morocco"* ]] || [[ "$parsed_layout" == *"ma"* ]]; then
      layout_text="<span color='$C_TEXT'>AR </span>"
    else
      layout_text="<span color='$C_TEXT'>EN </span>"
    fi
  else
    layout_text=""
  fi

  # --- CPU (System Group: Mauve) ---
  read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
  curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  curr_idle=$((idle + iowait))

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
  mem_total=0
  mem_avail=0
  while read -r key val _; do
    case "$key" in
      MemTotal:) mem_total=$val ;;
      MemAvailable:) mem_avail=$val ;;
    esac
  done </proc/meminfo

  if [ "$mem_total" -gt 0 ]; then
    ram_usage=$(((mem_total - mem_avail) * 100 / mem_total))
    ram_text="<span color='$C_MAUVE'>$(printf "%2d%%" "$ram_usage") </span>"
  else
    ram_text="<span color='$C_MAUVE'>--% </span>"
  fi

  # --- Brightness (UI Group: Peach) ---
  if [ -d "$BL_DIR" ]; then
    read -r bright_cur <"$BL_DIR/brightness"
    read -r bright_max <"$BL_DIR/max_brightness"
    bright_pct=$((bright_cur * 100 / bright_max))
    bright_text="<span color='$C_PEACH'>${bright_pct}% 󰃠</span>"
  else
    bright_text="<span color='$C_PEACH'>--% 󰃠</span>"
  fi

  # --- Volume (UI Group: Peach) ---
  raw_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  if [ -n "$raw_vol" ]; then
    vol_pct=0
    if [[ "$raw_vol" =~ Volume:[[:space:]]([0-9]+)\.([0-9]{2}) ]]; then
      vol_pct=$((10#${BASH_REMATCH[1]} * 100 + 10#${BASH_REMATCH[2]}))
    elif [[ "$raw_vol" =~ Volume:[[:space:]]([0-9]+)\.([0-9]{1}) ]]; then
      vol_pct=$((10#${BASH_REMATCH[1]} * 100 + 10#${BASH_REMATCH[2]} * 10))
    fi

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

  # --- Date (Neutral Text Color, Zero-Fork Bash Native) ---
  printf -v current_time '%(%a %-d %H:%M:%S)T' -1
  date_text="<span color='$C_TEXT'>$current_time</span>"

  # ==========================================
  # 2. SLOW UPDATES (Every 5 seconds)
  # ==========================================
  if [ "$timer" -eq 0 ]; then

    # --- Sensors (Temperature & Power) ---
    raw_temp=""
    raw_power=""
    while read -r line; do
      if [[ "$line" == *"Charge Regulator Temp"* ]]; then
        t="${line##*:}"
        t="${t//[^0-9.]/}"
        raw_temp=${t%.*}
      elif [[ "$line" == *"Total System Power"* ]]; then
        p="${line##*:}"
        p="${p//[^0-9.]/}"
        raw_power=${p%.*}
      fi
    done < <(sensors 2>/dev/null)

    if [ -n "$raw_temp" ]; then
      if [ "$raw_temp" -ge 70 ]; then
        temp_text="<span color='$C_RED'>${raw_temp}°C </span>"
      else
        temp_text="<span color='$C_MAUVE'>${raw_temp}°C </span>"
      fi
    else
      temp_text="<span color='$C_MAUVE'>--°C </span>"
    fi

    if [ -n "$raw_power" ]; then
      power_text="<span color='$C_GREEN'>${raw_power}W </span>"
    else
      power_text="<span color='$C_GREEN'>--W </span>"
    fi

    # --- Disk Space ---
    if [ "$((loop_count % 60))" -eq 0 ] || [ -z "$disk_text" ]; then
      disk_free=$(df -m / | awk 'NR==2 { v=$4/1024; print int(v) }')
      disk_text="<span color='$C_MAUVE'>${disk_free}GB </span>"
    fi

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
      # ONLY query nmcli if we just transitioned from disconnected to connected
      if [ $wifi_up -eq 0 ]; then
        ssid=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -n 1)
        [ -z "$ssid" ] && ssid="Connected"
        ssid=$(escape "$ssid")
      fi
      wifi_up=1
      wifi_text="<span color='$C_BLUE'>$ssid 󰖩</span>"
    else
      wifi_up=0
      wifi_text=""
      net_speed_text=""
    fi

    # --- Native Bluetooth + Battery ---
    bt_text=""
    # Grab the connected MAC directly. If empty, skip all heavy BT processing.
    bt_mac=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}' | head -n 1)

    if [ -n "$bt_mac" ]; then
      bt_info_cache=$(bluetoothctl info "$bt_mac" 2>/dev/null)
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

  # ==========================================
  # 3. ULTRA SLOW UPDATES (Every 5min / 300 loops)
  # ==========================================
  [ ! -f /tmp/sway_updates.txt ] && touch /tmp/sway_updates.txt

  if [ "$loop_count" -eq 0 ]; then
    (
      updates=$(dnf check-update -q | awk 'NF {count++} END {print count+0}')
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

  # --- Media Player (Media Group: Green) ---
  # Query both status and metadata in one single command separated by a pipe
  player_info=$(playerctl metadata --format "{{status}}|{{title}}" 2>/dev/null)

  if [ -n "$player_info" ]; then
    # Bash string manipulation to split the status and the title
    play_status="${player_info%%|*}"
    raw_media="${player_info#*|}"

    max_len=25
    len=${#raw_media}

    if [ "$len" -gt "$max_len" ]; then
      padded_media="${raw_media} • "
      pad_len=${#padded_media}
      offset=$((media_scroll % pad_len))
      scrolled="${padded_media:offset}${padded_media:0:offset}"
      display_media="${scrolled:0:max_len}"
      media_scroll=$((media_scroll + 6))
    else
      display_media="$raw_media"
      media_scroll=0
    fi

    escaped_media=$(escape "$display_media")

    if [ "$play_status" = "Playing" ]; then
      media_icon="󰎆"
    else
      media_icon="󰏤"
    fi

    media_text="${LRM}<span color='$C_GREEN'>${escaped_media} $media_icon</span>${LRM}"
  else
    media_text=""
    media_scroll=0
  fi

  # ==========================================
  # OUTPUT
  # ==========================================
  slots=()
  [ -n "$update_text" ] && slots+=("$update_text")
  [ -n "$media_text" ] && slots+=("$media_text")
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
      final_output="${LRM}${slot}${LRM}"
    else
      final_output="${final_output} ${LRM}<span color='$C_SEP'>•</span>${LRM} ${LRM}${slot}${LRM}"
    fi
  done

  safe_output="${final_output//$'\n'/ }"
  safe_output="${safe_output//\\/\\\\}"
  safe_output="${safe_output//\"/\\\"}"

  printf ',[{"full_text": "%s", "markup": "pango"}]\n' "$safe_output"

  timer=$(((timer + 1) % 5))
  loop_count=$(((loop_count + 1) % 300))
  weather_loop_count=$(((weather_loop_count + 1) % 1800))
  sleep 1
done
