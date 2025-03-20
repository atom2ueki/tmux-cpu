#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

# global vars
temp=""
gpu_temp_format="%2.0f"
gpu_temp_scale="C"
gpu_temp_medium_threshold="80"
gpu_temp_high_threshold="90"

# Color variables - will be set from tmux options
low_color=""
medium_color=""
high_color=""

print_gpu_temp() {
  gpu_temp_format=$(get_tmux_option "@gpu_temp_format" "$gpu_temp_format")
  gpu_temp_scale=$(get_tmux_option "@gpu_temp_scale" "$gpu_temp_scale")
  
  # Get color settings
  low_color=$(get_tmux_option "@gpu_temp_low_color" "")
  medium_color=$(get_tmux_option "@gpu_temp_medium_color" "")
  high_color=$(get_tmux_option "@gpu_temp_high_color" "")
  
  # Set the unit with degree symbol based on scale
  gpu_temp_unit="°$gpu_temp_scale"

  if command_exists "nvidia-smi"; then
    loads=$(cached_eval nvidia-smi)
  elif command_exists "cuda-smi"; then
    loads=$(cached_eval cuda-smi)
  else
    echo "No GPU"
    return
  fi
  
  # Get the temperature value
  local temp
  tempC=$(echo "$loads" | sed -nr 's/.*\s([0-9]+)C.*/\1/p' | awk '{sum+=$1; n+=1} END {printf "%5.3f", sum/n}')
  
  # Calculate temperature based on scale
  if [ "$gpu_temp_scale" == "C" ]; then
    temp="$tempC"
  else
    temp=$(echo "$tempC" | awk '{printf("%f", $1*9/5+32)}')
  fi
  
  # Determine color based on temperature thresholds
  local temp_color
  local medium_thresh=$(get_tmux_option "@gpu_temp_medium_thresh" "80")
  local high_thresh=$(get_tmux_option "@gpu_temp_high_thresh" "90")
  
  if (( $(echo "$temp >= $high_thresh" | bc -l) )); then
    temp_color="$high_color"
  elif (( $(echo "$temp >= $medium_thresh" | bc -l) )); then
    temp_color="$medium_color"
  else
    temp_color="$low_color"
  fi
  
  # Format and output the colored temperature
  local formatted_temp
  formatted_temp=$(printf "$gpu_temp_format" "$temp")
  echo "${temp_color}${formatted_temp}${gpu_temp_unit}#[fg=default]"
}

main() {
  print_gpu_temp
}
main "$@"
