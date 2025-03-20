#!/usr/bin/env bash

# This is a shared/reusable load bar component that can be used
# by CPU, RAM, GPU, and GRAM monitor scripts

# Usage examples:
# ./load_bar.sh --type=cpu --value=5.3% --threshold-med=30 --threshold-high=80
# ./load_bar.sh --type=ram --value=8.2G --total=16.0G --threshold-med=30 --threshold-high=80

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# Default settings
type=""
value=""
total=""
threshold_med=30
threshold_high=80
percentage=0
progress_bar_length=10
progress_char="|"
empty_char=" "
left_bracket="["
right_bracket="]"

# Initialize color variables
low_color=""
medium_color=""
high_color=""
bracket_color=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --type=*)
      type="${arg#*=}"
      shift
      ;;
    --value=*)
      value="${arg#*=}"
      shift
      ;;
    --total=*)
      total="${arg#*=}"
      shift
      ;;
    --percentage=*)
      percentage="${arg#*=}"
      shift
      ;;
    --threshold-med=*)
      threshold_med="${arg#*=}"
      shift
      ;;
    --threshold-high=*)
      threshold_high="${arg#*=}"
      shift
      ;;
  esac
done

# Exit if required args are missing
if [[ -z "$type" || -z "$value" ]]; then
  echo "Error: Required arguments missing"
  echo "Usage: $0 --type=cpu|ram|gpu|gram --value=X [--total=Y] [--percentage=Z] [--threshold-med=30] [--threshold-high=80]"
  exit 1
fi

# Clean up input values - remove newlines and spaces
value=$(echo -n "$value" | tr -d '\n')
if [[ -n "$total" ]]; then
  total=$(echo -n "$total" | tr -d '\n')
fi
if [[ -n "$percentage" ]]; then
  percentage=$(echo -n "$percentage" | tr -d '\n' | tr -d ' ')
fi

get_settings() {
  # Get settings based on resource type
  progress_bar_length=$(get_tmux_option "@${type}_progress_length" "$progress_bar_length")
  progress_char=$(get_tmux_option "@${type}_progress_char" "$progress_char")
  empty_char=$(get_tmux_option "@${type}_empty_char" "$empty_char")
  left_bracket=$(get_tmux_option "@${type}_left_bracket" "$left_bracket")
  right_bracket=$(get_tmux_option "@${type}_right_bracket" "$right_bracket")
  
  # Color settings - directly from tmux without fallbacks
  low_color=$(get_tmux_option "@${type}_low_color" "")
  medium_color=$(get_tmux_option "@${type}_medium_color" "")
  high_color=$(get_tmux_option "@${type}_high_color" "")
  bracket_color=$(get_tmux_option "@${type}_bracket_color" "")
  
  # Thresholds
  threshold_med=$(get_tmux_option "@${type}_medium_thresh" "$threshold_med")
  threshold_high=$(get_tmux_option "@${type}_high_thresh" "$threshold_high")
}

extract_percentage() {
  # If percentage is provided directly, use it
  if [[ -n "$percentage" && "$percentage" != "0" ]]; then
    return
  fi
  
  # Otherwise, extract it from the value
  if [[ "$value" == *"%" ]]; then
    # Extract percentage from value (e.g., "5.3%")
    percentage=$(echo "$value" | sed -e 's/%//' | sed -e 's/,/./')
  elif [[ -n "$total" ]]; then
    # Calculate percentage from value/total
    value_num=$(echo "$value" | sed -e 's/[^0-9.]//g')
    total_num=$(echo "$total" | sed -e 's/[^0-9.]//g')
    if [[ -n "$value_num" && -n "$total_num" && "$total_num" != "0" ]]; then
      percentage=$(echo "scale=1; 100 * $value_num / $total_num" | bc)
    fi
  fi
  
  # Ensure we have a valid number
  if ! [[ "$percentage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
    percentage=0
  fi
}

determine_color() {
  # Select color based on thresholds
  if (( $(echo "$percentage >= $threshold_high" | bc -l) )); then
    load_bar_color="$high_color"
  elif (( $(echo "$percentage >= $threshold_med" | bc -l) )); then
    load_bar_color="$medium_color"
  else
    load_bar_color="$low_color"
  fi
}

build_progress_bar() {
  # Calculate filled and empty segments based on percentage
  # Ensure non-zero percentages show at least one character
  local filled_count
  
  # Check if percentage is a valid number
  if ! [[ "$percentage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
    percentage=0
  fi
  
  if (( $(echo "$percentage > 0" | bc -l) )) && (( $(echo "$percentage < 100 / $progress_bar_length" | bc -l) )); then
    # For very small percentages (but not zero), always show at least one character
    filled_count=1
  else
    # Normal calculation for larger percentages with proper rounding
    filled_count=$(echo "scale=0; ($percentage * $progress_bar_length / 100) + 0.5" | bc)
    filled_count=${filled_count:-0}  # Default to 0 if empty
  fi
  
  # Force to integer with awk
  filled_count=$(echo "$filled_count" | awk '{printf "%d", $1}')
  
  # Ensure filled_count is within bounds
  if [[ "$filled_count" -lt 0 ]]; then
    filled_count=0
  elif [[ "$filled_count" -gt "$progress_bar_length" ]]; then
    filled_count=$progress_bar_length
  fi
  
  local empty_count=$((progress_bar_length - filled_count))
  
  # Start with brackets
  local progress_bar="${bracket_color}${left_bracket}"
  
  # Add filled section with appropriate color
  if [[ "$filled_count" -gt 0 ]]; then
    progress_bar="${progress_bar}${load_bar_color}"
    for ((i=0; i<filled_count; i++)); do
      progress_bar="${progress_bar}${progress_char}"
    done
    progress_bar="${progress_bar}#[fg=default]"
  fi
  
  # Add empty section
  for ((i=0; i<empty_count; i++)); do
    progress_bar="${progress_bar}${empty_char}"
  done
  
  # Add the value display (with or without total)
  if [[ -n "$total" ]]; then
    progress_bar="${progress_bar} ${value}/${total}"
  else
    progress_bar="${progress_bar} ${value}"
  fi
  
  # Add closing bracket and reset color
  progress_bar="${progress_bar}${bracket_color}${right_bracket}#[fg=default]"
  
  echo -n "${progress_bar}"
}

main() {
  get_settings
  extract_percentage
  determine_color
  build_progress_bar
}

main 