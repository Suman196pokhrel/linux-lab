#!/bin/bash
MAX=28
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  printf '{"text":"","class":"stopped","tooltip":""}\n'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
if [ -n "$artist" ]; then info="$artist - $title"; else info="$title"; fi
# truncate
display="$info"
if [ "${#display}" -gt "$MAX" ]; then
  display="${display:0:$((MAX-1))}…"
fi
icon=""
[ "$status" = "Paused" ] && icon=""
# escape quotes/backslashes for JSON
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
printf '{"text":"%s %s","class":"%s","tooltip":"%s"}\n' \
  "$icon" "$(esc "$display")" "$(echo "$status" | tr '[:upper:]' '[:lower:]')" "$(esc "$info")"
