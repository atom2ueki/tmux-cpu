#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

cpu_temp_format="%2.0f"
cpu_temp_scale="C"

# Color settings
low_color=""
medium_color=""
high_color=""

low_default_color="#[fg=green]"
medium_default_color="#[fg=yellow]"
high_default_color="#[fg=red]"

print_cpu_temp() {
  cpu_temp_format=$(get_tmux_option "@cpu_temp_format" "$cpu_temp_format")
  cpu_temp_scale=$(get_tmux_option "@cpu_temp_scale" "$cpu_temp_scale")
  
  # Get color settings
  low_color=$(get_tmux_option "@cpu_temp_low_color" "$low_default_color")
  medium_color=$(get_tmux_option "@cpu_temp_medium_color" "$medium_default_color")
  high_color=$(get_tmux_option "@cpu_temp_high_color" "$high_default_color")
  
  # Set the unit with degree symbol based on scale
  cpu_temp_unit="°$cpu_temp_scale"
  
  if command_exists "sensors"; then
    local val
    if [[ "$cpu_temp_scale" == "F" ]]; then
      val="$(sensors -f)"
    else
      val="$(sensors)"
    fi
    
    # Get the temperature value
    local temp
    temp=$(echo "$val" | sed -e 's/^Tccd/Core /' | awk '/^Core [0-9]+/ {gsub("[^0-9.]", "", $3); sum+=$3; n+=1} END {printf("%f", sum/n)}')
    
    # Determine color based on temperature thresholds
    local temp_color
    local medium_thresh=$(get_tmux_option "@cpu_temp_medium_thresh" "80")
    local high_thresh=$(get_tmux_option "@cpu_temp_high_thresh" "90")
    
    if (( $(echo "$temp >= $high_thresh" | bc -l) )); then
      temp_color="$high_color"
    elif (( $(echo "$temp >= $medium_thresh" | bc -l) )); then
      temp_color="$medium_color"
    else
      temp_color="$low_color"
    fi
    
    # Format and output the colored temperature
    local formatted_temp
    formatted_temp=$(printf "$cpu_temp_format" "$temp")
    echo "${temp_color}${formatted_temp}${cpu_temp_unit}#[fg=default]"
  fi
}

main() {
  print_cpu_temp
}
main
