#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Color settings
low_color=""
medium_color=""
high_color=""

low_default_color="#[fg=green]"
medium_default_color="#[fg=yellow]"
high_default_color="#[fg=red]"

# Progress bar settings
progress_bar_length=10
progress_char="|"
empty_char=" "
left_bracket="["
right_bracket="]"

get_settings() {
  # Get color settings
  low_color=$(get_tmux_option "@ram_low_color" "$low_default_color")
  medium_color=$(get_tmux_option "@ram_medium_color" "$medium_default_color")
  high_color=$(get_tmux_option "@ram_high_color" "$high_default_color")
  
  # Get progress bar settings
  progress_bar_length=$(get_tmux_option "@ram_progress_length" "$progress_bar_length")
  progress_char=$(get_tmux_option "@ram_progress_char" "$progress_char")
  empty_char=$(get_tmux_option "@ram_empty_char" "$empty_char")
  left_bracket=$(get_tmux_option "@ram_left_bracket" "$left_bracket")
  right_bracket=$(get_tmux_option "@ram_right_bracket" "$right_bracket")
}

print_load_bar() {
  local ram_percentage
  ram_percentage=$("$CURRENT_DIR"/ram_percentage.sh | sed -e 's/%//' | cut -d '.' -f 1)
  
  # Determine color based on percentage thresholds
  local load_bar_color=""
  local medium_thresh=$(get_tmux_option "@ram_medium_thresh" "30")
  local high_thresh=$(get_tmux_option "@ram_high_thresh" "80")
  
  if [ "$ram_percentage" -ge "$high_thresh" ]; then
    load_bar_color="$high_color"
  elif [ "$ram_percentage" -ge "$medium_thresh" ]; then
    load_bar_color="$medium_color"
  else
    load_bar_color="$low_color"
  fi
  
  # Calculate progress bar
  local filled_count=$((ram_percentage * progress_bar_length / 100))
  if [ "$filled_count" -gt "$progress_bar_length" ]; then
    filled_count=$progress_bar_length
  fi
  
  local empty_count=$((progress_bar_length - filled_count))
  
  # Build progress bar
  local progress_bar="$left_bracket"
  
  # Add filled section
  for ((i=0; i<filled_count; i++)); do
    progress_bar="${progress_bar}${progress_char}"
  done
  
  # Add empty section
  for ((i=0; i<empty_count; i++)); do
    progress_bar="${progress_bar}${empty_char}"
  done
  
  progress_bar="${progress_bar}${right_bracket}"
  
  # Output the colored progress bar
  echo "${load_bar_color}${progress_bar}#[fg=default]"
}

main() {
  get_settings
  print_load_bar "$1"
}
main "$@"
