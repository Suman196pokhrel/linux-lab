#!/bin/bash
# ~/.config/waybar/scripts/docker.sh
# Emits JSON: running container count. Icon is set in config (format).

if ! docker info >/dev/null 2>&1; then
  printf '{"text":"\u2013","class":"down","tooltip":"Docker daemon not running"}\n'
  exit 0
fi
running=$(docker ps -q 2>/dev/null | wc -l)
total=$(docker ps -aq 2>/dev/null | wc -l)
names=$(docker ps --format '{{.Names}}' 2>/dev/null | paste -sd ', ' -)
[ -z "$names" ] && names="none"
cls=""
[ "$running" -gt 0 ] && cls="active"
printf '{"text":"%s","class":"%s","tooltip":"Running: %s/%s\\n%s"}\n' \
  "$running" "$cls" "$running" "$total" "$names"
