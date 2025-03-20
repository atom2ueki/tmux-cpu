#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# script global variables
tier1_icon=""
tier2_icon=""
tier3_icon=""
tier4_icon=""
tier5_icon=""
tier6_icon=""
tier7_icon=""
tier8_icon=""

tier1_default_icon="▁"
tier2_default_icon="▂"
tier3_default_icon="▃"
tier4_default_icon="▄"
tier5_default_icon="▅"
tier6_default_icon="▆"
tier7_default_icon="▇"
tier8_default_icon="█"

# icons are set as script global variables
get_icon_settings() {
  tier1_icon=$(get_tmux_option "@tier1_icon" "$tier1_default_icon")
  tier2_icon=$(get_tmux_option "@tier2_icon" "$tier2_default_icon")
  tier3_icon=$(get_tmux_option "@tier3_icon" "$tier3_default_icon")
  tier4_icon=$(get_tmux_option "@tier4_icon" "$tier4_default_icon")
  tier5_icon=$(get_tmux_option "@tier5_icon" "$tier5_default_icon")
  tier6_icon=$(get_tmux_option "@tier6_icon" "$tier6_default_icon")
  tier7_icon=$(get_tmux_option "@tier7_icon" "$tier7_default_icon")
  tier8_icon=$(get_tmux_option "@tier8_icon" "$tier8_default_icon")
}

print_icon() {
  local gpu_percentage
  gpu_percentage=$("$CURRENT_DIR"/gpu_percentage.sh | sed -e 's/%//' | cut -d '.' -f 1)
  
  if [ "$gpu_percentage" -ge 95 ]; then
    echo "$tier8_icon"
  elif [ "$gpu_percentage" -ge 80 ]; then
    echo "$tier7_icon"
  elif [ "$gpu_percentage" -ge 65 ]; then
    echo "$tier6_icon"
  elif [ "$gpu_percentage" -ge 50 ]; then
    echo "$tier5_icon"
  elif [ "$gpu_percentage" -ge 35 ]; then
    echo "$tier4_icon"
  elif [ "$gpu_percentage" -ge 20 ]; then
    echo "$tier3_icon"
  elif [ "$gpu_percentage" -ge 5 ]; then
    echo "$tier2_icon"
  else
    echo "$tier1_icon"
  fi
}

main() {
  get_icon_settings
  print_icon "$1"
}
main "$@"
