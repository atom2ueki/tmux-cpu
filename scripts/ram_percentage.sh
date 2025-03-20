#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_percentage_format="%3.1f%%"

get_ram_percentage() {
  if command_exists "free"; then
    # Get used and total RAM
    local used_ram total_ram
    
    # Get both values in one call to ensure they're from the same snapshot
    read -r used_ram total_ram <<< "$(cached_eval free -b | awk '$1 ~ /Mem/ {print $3, $2}')"
    
    # Validate numbers and calculate percentage
    if [[ "$used_ram" =~ ^[0-9]+$ ]] && [[ "$total_ram" =~ ^[0-9]+$ ]] && [ "$total_ram" -gt 0 ]; then
      echo "scale=1; 100 * $used_ram / $total_ram" | bc
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

print_ram_percentage() {
  ram_percentage_format=$(get_tmux_option "@ram_percentage_format" "$ram_percentage_format")
  
  # Get raw percentage
  local percentage
  percentage=$(get_ram_percentage)
  
  # Make sure we have a valid number
  if ! [[ "$percentage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
    percentage=0
  fi
  
  # Format the percentage
  printf "$ram_percentage_format" "$percentage"
}

# Print raw percentage value for the load bar component
print_raw_ram_percentage() {
  # Get used and total RAM
  local used_ram total_ram percentage
  
  # Get both values in one call to ensure they're from the same snapshot
  read -r used_ram total_ram <<< "$(cached_eval free -b | awk '$1 ~ /Mem/ {print $3, $2}')"
  
  # Validate numbers and calculate percentage
  if [[ "$used_ram" =~ ^[0-9]+$ ]] && [[ "$total_ram" =~ ^[0-9]+$ ]] && [ "$total_ram" -gt 0 ]; then
    percentage=$(echo "scale=3; 100 * $used_ram / $total_ram" | bc)
    echo "$percentage"
  else
    echo "0"
  fi
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_ram_percentage
  else
    print_ram_percentage
  fi
}
main "$@"
