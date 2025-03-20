#!/usr/bin/env bash

# This is a shared/reusable load bar component that can be used
# by CPU, RAM, GPU, and GRAM monitor scripts

# Usage examples:
# ./load_bar.sh --type=cpu --value=5.3% --threshold-med=30 --threshold-high=80
# ./load_bar.sh --type=ram --value=8.2G --total=16.0G --threshold-med=30 --threshold-high=80

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Script arguments
type="$1"       # cpu, ram, or gram
percentage="$2" # Raw percentage value
value="$3"      # Optional display value (e.g. "16G/32G")

# Get tmux options
bar_length=$(get_tmux_option "@${type}_bar_length" "10")
bar_color=$(get_tmux_option "@${type}_bar_color" "colour136")
bg_color=$(get_tmux_option "@${type}_bg_color" "default")
show_percentage=$(get_tmux_option "@${type}_percentage" "true")
show_value=$(get_tmux_option "@${type}_show_value" "true")

# Convert percentage to number of filled positions in the bar
if [[ -z "$percentage" || "$percentage" == "No GPU" || ! "$percentage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
  filled=0
else
  filled=$(echo "($percentage * $bar_length) / 100" | bc -l | awk '{printf "%.0f", $0}')
  
  # Ensure filled is within valid range
  if [ "$filled" -gt "$bar_length" ]; then
    filled=$bar_length
  elif [ "$filled" -lt 0 ]; then
    filled=0
  fi
fi

# Calculate unfilled positions
unfilled=$((bar_length - filled))

# Generate the bar
bar=""
if [ "$filled" -gt 0 ]; then
  bar="#[fg=$bar_color,bg=$bg_color]"
  for ((i=0; i<filled; i++)); do
    bar="${bar}|"
  done
fi

# Add the unfilled positions if any
if [ "$unfilled" -gt 0 ]; then
  bar="${bar}#[fg=default,bg=$bg_color]"
  for ((i=0; i<unfilled; i++)); do
    bar="${bar}|"
  done
fi

# Reset colors after the bar
bar="${bar}#[fg=default]"

# Generate output content
content=""
if [ "$show_percentage" = "true" ] && [[ "$percentage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
  content=" $(printf "%.1f%%" "$percentage")"
elif [ -n "$value" ] && [ "$show_value" = "true" ]; then
  content=" $value"
fi

# Final output
echo "[$bar$content]#[fg=default]" 