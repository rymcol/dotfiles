#!/usr/bin/env bash
# Brightness control for both internal (backlight) and external (DDC/CI) monitors
# Usage: brightness.sh up|down [step]
#   step defaults to 10 (percent)

direction="${1:?Usage: brightness.sh up|down [step]}"
step="${2:-10}"

# Internal display (eDP-1) via brightnessctl
case "$direction" in
    up)   brightnessctl --class=backlight set "+${step}%" ;;
    down) brightnessctl --class=backlight set "${step}%-" ;;
esac

# External displays via ddcutil (DDC/CI feature 0x10 = brightness)
# Run in background so key response stays snappy — ddcutil can be slow
for display_num in $(ddcutil detect --brief 2>/dev/null | grep -oP '(?<=Display )\d+'); do
    case "$direction" in
        up)   ddcutil --display "$display_num" setvcp 10 + "$step" &;;
        down) ddcutil --display "$display_num" setvcp 10 - "$step" &;;
    esac
done

wait
