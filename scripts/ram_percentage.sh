#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_percentage_format="%3.1f%%"

get_ram_percentage() {
  # Extract numeric values from ram_usage output
  local used_ram
  local total_ram
  
  used_ram=$("$CURRENT_DIR"/ram_usage.sh | sed -e 's/[^0-9.]//g')
  total_ram=$("$CURRENT_DIR"/ram_usage.sh total | sed -e 's/[^0-9.]//g')
  
  # Calculate percentage
  if [[ -n "$used_ram" && -n "$total_ram" && "$total_ram" != "0" ]]; then
    echo "scale=1; 100 * $used_ram / $total_ram" | bc
  else
    echo "0"
  fi
}

print_ram_percentage() {
  ram_percentage_format=$(get_tmux_option "@ram_percentage_format" "$ram_percentage_format")
  
  # Get raw percentage
  local percentage
  percentage=$(get_ram_percentage)
  
  # Format the percentage
  printf "$ram_percentage_format" "$percentage"
}

# Print raw percentage value for the load bar component
print_raw_ram_percentage() {
  get_ram_percentage
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_ram_percentage
  else
    print_ram_percentage
  fi
}
main "$@"
