#!/bin/bash
# ~/.config/waybar/scripts/cava.sh
# Reads cava raw ascii output and emits JSON lines for waybar.
#
# Visibility logic (bug-3 fix):
#   - Bars stay visible the WHOLE time a player is Playing, even during
#     quiet passages (we check `playerctl status`, not just audio level).
#   - When playback stops/pauses, we keep showing flat idle bars for a
#     short grace period, then mark the module "silent" so CSS can fade
#     it out gently (transition handled in style.css, not an abrupt drop).

CAVA_CONFIG="$HOME/.config/waybar/cava.conf"

# Block characters for levels 0..7
bars=" ▁▂▃▄▅▆▇"

# Build a sed script mapping each digit 0-7 to its block char.
dict="s/;//g;"
i=0
while [ $i -lt ${#bars} ]; do
  dict="${dict}s/$i/${bars:$i:1}/g;"
  i=$((i + 1))
done

# Number of bars (keep in sync with cava.conf `bars =`)
NBARS=18
# Flat idle row (all lowest blocks) shown while a player is active but quiet
IDLE=$(printf '▁%.0s' $(seq 1 $NBARS))

# How many consecutive silent frames (after playback stops) before hiding.
# cava runs ~30fps; 30 frames ≈ 1s grace so it fades, not snaps.
GRACE=30
silent_count=0

# Cache playerctl status briefly so we don't fork it every single frame.
last_check=0
player_active=0

is_player_active() {
  local now
  now=$(date +%s%N)
  # Re-check at most ~5x/sec
  if (( (now - last_check) > 200000000 )); then
    last_check=$now
    if playerctl status 2>/dev/null | grep -q "Playing"; then
      player_active=1
    else
      player_active=0
    fi
  fi
  return $((1 - player_active))
}

stdbuf -oL cava -p "$CAVA_CONFIG" 2>/dev/null | while read -r line; do
  # Is the raw frame all-zero (no sound right now)?
  if [[ "$line" =~ ^[0\;]*$ ]]; then
    audio_zero=1
  else
    audio_zero=0
  fi

  if is_player_active; then
    # A player is actively playing.
    silent_count=0
    if [ "$audio_zero" -eq 1 ]; then
      # Quiet passage mid-track: show flat idle bars, stay visible.
      printf '{"text":"%s","class":"playing","tooltip":"Audio visualizer"}\n' "$IDLE"
    else
      glyphs=$(echo "$line" | sed "$dict")
      printf '{"text":"%s","class":"playing","tooltip":"Audio visualizer"}\n' "$glyphs"
    fi
  else
    # No player playing (paused/stopped/none).
    if [ "$audio_zero" -eq 0 ]; then
      # System audio without a known player (e.g. a game) — still visualize.
      silent_count=0
      glyphs=$(echo "$line" | sed "$dict")
      printf '{"text":"%s","class":"playing","tooltip":"Audio visualizer"}\n' "$glyphs"
    else
      # Truly silent. Grace period, then fade out via "silent" class.
      if [ "$silent_count" -lt "$GRACE" ]; then
        silent_count=$((silent_count + 1))
        printf '{"text":"%s","class":"fading","tooltip":"Audio visualizer"}\n' "$IDLE"
      else
        printf '{"text":"","class":"silent","tooltip":"Audio visualizer"}\n'
      fi
    fi
  fi
done
