#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Color settings
low_color=""
medium_color=""
high_color=""
bracket_color=""

# Progress bar settings
progress_bar_length=10
progress_char="|"
empty_char=" "
left_bracket="["
right_bracket="]"

get_settings() {
  # Get color settings
  low_color=$(get_tmux_option "@gram_low_color" "")
  medium_color=$(get_tmux_option "@gram_medium_color" "")
  high_color=$(get_tmux_option "@gram_high_color" "")
  bracket_color=$(get_tmux_option "@gram_bracket_color" "")
  
  # Get progress bar settings
  progress_bar_length=$(get_tmux_option "@gram_progress_length" "$progress_bar_length")
  progress_char=$(get_tmux_option "@gram_progress_char" "$progress_char")
  empty_char=$(get_tmux_option "@gram_empty_char" "$empty_char")
  left_bracket=$(get_tmux_option "@gram_left_bracket" "$left_bracket")
  right_bracket=$(get_tmux_option "@gram_right_bracket" "$right_bracket")
}

print_load_bar() {
  local gram_percentage
  gram_percentage=$("$CURRENT_DIR"/gram_percentage.sh | sed -e 's/%//' | cut -d '.' -f 1)
  
  # Get used and total VRAM
  local gram_usage=$("$CURRENT_DIR"/gram_usage.sh)
  local total_gram=$("$CURRENT_DIR"/gram_usage.sh total)
  
  # Check if GPU is available
  if [[ "$gram_usage" == "No GPU" || "$total_gram" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Modify units from GB/MB to G/M
  local gram_unit=$(get_tmux_option "@gram_unit" "GB")
  if [[ "$gram_unit" == "GB" ]]; then
    gram_usage=${gram_usage/GB/G}
    total_gram=${total_gram/GB/G}
  elif [[ "$gram_unit" == "MB" ]]; then
    gram_usage=${gram_usage/MB/M}
    total_gram=${total_gram/MB/M}
  fi
  
  # Determine color based on percentage thresholds
  local load_bar_color=""
  local medium_thresh=$(get_tmux_option "@gram_medium_thresh" "30")
  local high_thresh=$(get_tmux_option "@gram_high_thresh" "80")
  
  if [ "$gram_percentage" -ge "$high_thresh" ]; then
    load_bar_color="$high_color"
  elif [ "$gram_percentage" -ge "$medium_thresh" ]; then
    load_bar_color="$medium_color"
  else
    load_bar_color="$low_color"
  fi
  
  # Calculate progress bar
  local filled_count=$((gram_percentage * progress_bar_length / 100))
  if [ "$filled_count" -gt "$progress_bar_length" ]; then
    filled_count=$progress_bar_length
  fi
  
  local empty_count=$((progress_bar_length - filled_count))
  
  # Build progress bar with colored brackets
  local progress_bar="${bracket_color}${left_bracket}"
  
  # Add filled section with load color
  for ((i=0; i<filled_count; i++)); do
    progress_bar="${progress_bar}${load_bar_color}${progress_char}"
  done
  
  # Add empty section
  for ((i=0; i<empty_count; i++)); do
    progress_bar="${progress_bar}${empty_char}"
  done
  
  # Add memory usage at the end inside bracket
  progress_bar="${progress_bar} ${gram_usage}/${total_gram}${bracket_color}${right_bracket}"
  
  # Output the progress bar
  echo "${progress_bar}#[fg=default]"
}

main() {
  get_settings
  print_load_bar "$1"
}
main "$@"
