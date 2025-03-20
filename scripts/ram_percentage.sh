#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_percentage_format="%3.1f%%"

print_ram_percentage() {
  ram_percentage_format=$(get_tmux_option "@ram_percentage_format" "$ram_percentage_format")
  
  # Get values from existing scripts
  local used_ram
  local total_ram
  
  # Extract numeric values from ram_usage output
  used_ram=$("$CURRENT_DIR"/ram_usage.sh | sed -e 's/[^0-9.]//g')
  total_ram=$("$CURRENT_DIR"/ram_usage.sh total | sed -e 's/[^0-9.]//g')
  
  # Calculate percentage
  if [[ -n "$used_ram" && -n "$total_ram" && "$total_ram" != "0" ]]; then
    echo "$used_ram $total_ram" | awk -v format="$ram_percentage_format" '{printf(format, 100*$1/$2)}'
  else
    printf "$ram_percentage_format" 0
  fi
}

main() {
  print_ram_percentage
}
main
