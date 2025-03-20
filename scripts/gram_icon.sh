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
  low_color=$(get_tmux_option "@gram_low_color" "$low_default_color")
  medium_color=$(get_tmux_option "@gram_medium_color" "$medium_default_color")
  high_color=$(get_tmux_option "@gram_high_color" "$high_default_color")
  
  # Get progress bar settings
  progress_bar_length=$(get_tmux_option "@gram_progress_length" "$progress_bar_length")
  progress_char=$(get_tmux_option "@gram_progress_char" "$progress_char")
  empty_char=$(get_tmux_option "@gram_empty_char" "$empty_char")
  left_bracket=$(get_tmux_option "@gram_left_bracket" "$left_bracket")
  right_bracket=$(get_tmux_option "@gram_right_bracket" "$right_bracket")
}

print_icon() {
  local gram_percentage
  gram_percentage=$("$CURRENT_DIR"/gram_percentage.sh | sed -e 's/%//' | cut -d '.' -f 1)
  
  # Determine color based on percentage thresholds
  local icon_color=""
  local medium_thresh=$(get_tmux_option "@gram_medium_thresh" "30")
  local high_thresh=$(get_tmux_option "@gram_high_thresh" "80")
  
  if [ "$gram_percentage" -ge "$high_thresh" ]; then
    icon_color="$high_color"
  elif [ "$gram_percentage" -ge "$medium_thresh" ]; then
    icon_color="$medium_color"
  else
    icon_color="$low_color"
  fi
  
  # Calculate progress bar
  local filled_count=$((gram_percentage * progress_bar_length / 100))
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
  echo "${icon_color}${progress_bar}#[fg=default]"
}

main() {
  get_settings
  print_icon "$1"
}
main "$@"
