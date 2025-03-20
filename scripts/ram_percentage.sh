#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_percentage_format="%3.1f%%"

get_ram_percentage() {
  # Get RAM data directly from ram_usage.sh
  local used_output
  local total_output
  
  # Strip any units from the output
  used_output=$("$CURRENT_DIR"/ram_usage.sh | tr -d 'GM')
  total_output=$("$CURRENT_DIR"/ram_usage.sh total | tr -d 'GM')
  
  # Ensure values are valid
  if [[ -z "$used_output" || -z "$total_output" || "$total_output" == "0" ]]; then
    echo "0"
    return
  fi
  
  # Calculate percentage
  echo "scale=1; 100 * $used_output / $total_output" | bc
}

print_ram_percentage() {
  ram_percentage_format=$(get_tmux_option "@ram_percentage_format" "$ram_percentage_format")
  
  # Get raw percentage
  local percentage
  percentage=$(get_ram_percentage)
  
  # Ensure percentage is valid
  if [[ -z "$percentage" ]]; then
    percentage=0
  fi
  
  # Sanity check - ensure percentage is not over 100
  if (( $(echo "$percentage > 100" | bc -l) )); then
    percentage=100
  fi
  
  # Format the percentage
  printf "$ram_percentage_format" "$percentage"
  
  # Ensure output ends with a newline
  echo ""
}

# Print raw percentage value for the load bar component
print_raw_ram_percentage() {
  get_ram_percentage
  
  # Ensure output ends with a newline
  echo ""
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_ram_percentage
  else
    print_ram_percentage
  fi
}
main "$@"
