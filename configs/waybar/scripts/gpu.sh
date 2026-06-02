#!/bin/bash
read -r util mem_used mem_total temp < <(nvidia-smi \
  --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu \
  --format=csv,noheader,nounits | tr ',' ' ')
util=$(echo "$util" | xargs)
mem_used=$(echo "$mem_used" | xargs)
mem_total=$(echo "$mem_total" | xargs)
temp=$(echo "$temp" | xargs)
mem_pct=$(( mem_used * 100 / mem_total ))
cls=""
[ "$util" -ge 80 ] && cls="critical"
printf '{"text":"%s%%","class":"%s","tooltip":"GPU %s%% | VRAM %sMiB/%sMiB (%s%%) | %s°C"}\n' \
  "$util" "$cls" "$util" "$mem_used" "$mem_total" "$mem_pct" "$temp"
