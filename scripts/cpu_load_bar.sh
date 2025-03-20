#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get CPU percentage
  local cpu_percentage
  local cpu_raw
  
  cpu_percentage=$("$CURRENT_DIR"/cpu_percentage.sh)
  cpu_raw=$("$CURRENT_DIR"/cpu_percentage.sh raw)
  
  # Strip newlines from both values
  cpu_percentage=$(echo -n "$cpu_percentage" | tr -d '\n')
  cpu_raw=$(echo -n "$cpu_raw" | tr -d '\n')
  
  # Check if cpu_percentage is empty or "No CPU"
  if [[ -z "$cpu_percentage" || "$cpu_percentage" == "No CPU" ]]; then
    echo "No CPU"
    return
  fi
  
  # Use the shared load bar component with CPU parameters and raw percentage value
  "$CURRENT_DIR"/load_bar.sh --type=cpu --value="$cpu_percentage" --percentage="$cpu_raw"
}

main() {
  print_load_bar "$1"
}
main "$@"
