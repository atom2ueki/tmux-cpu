#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get CPU percentage
  local cpu_percentage
  cpu_percentage=$("$CURRENT_DIR"/cpu_percentage.sh)
  
  # Check if cpu_percentage is empty or "No CPU"
  if [[ -z "$cpu_percentage" || "$cpu_percentage" == "No CPU" ]]; then
    echo "No CPU"
    return
  fi
  
  # Use the shared load bar component with CPU parameters
  "$CURRENT_DIR"/load_bar.sh --type=cpu --value="$cpu_percentage"
}

main() {
  print_load_bar "$1"
}
main "$@"
