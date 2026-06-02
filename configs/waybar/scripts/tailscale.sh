#!/bin/bash
# ~/.config/waybar/scripts/tailscale.sh
# Emits JSON for waybar showing Tailscale connection state.
# Icon: nf-md-vpn (shield) — clear "secure network" glyph.

ICON_UP="󰖂"      # U+F0582 nf-md-vpn
ICON_DOWN="󰖂"    # same glyph, dimmed via .down class in CSS

status=$(tailscale status --json 2>/dev/null)
if [ -z "$status" ]; then
  printf '{"text":"%s","class":"down","tooltip":"Tailscale: not running"}\n' "$ICON_DOWN"
  exit 0
fi

state=$(echo "$status" | jq -r '.BackendState')
if [ "$state" != "Running" ]; then
  printf '{"text":"%s","class":"down","tooltip":"Tailscale: %s"}\n' "$ICON_DOWN" "$state"
  exit 0
fi

self_ip=$(echo "$status" | jq -r '.TailscaleIPs[0] // "n/a"')
peers=$(echo "$status" | jq -r '[.Peer[]? | select(.Online==true)] | length')
printf '{"text":"%s","class":"active","tooltip":"Tailscale: connected\\nIP: %s\\nOnline peers: %s"}\n' \
  "$ICON_UP" "$self_ip" "$peers"
