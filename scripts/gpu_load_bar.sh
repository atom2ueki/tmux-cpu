#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get GPU percentage
  local gpu_percentage
  gpu_percentage=$("$CURRENT_DIR"/gpu_percentage.sh)
  
  # Check if GPU is available
  if [[ "$gpu_percentage" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Extract raw percentage value (without % sign)
  local gpu_raw=$(echo "$gpu_percentage" | sed -e 's/%//' | sed -e 's/,/./')
  
  # Use the shared load bar component with GPU parameters and raw percentage
  "$CURRENT_DIR"/load_bar.sh --type=gpu --value="$gpu_percentage" --percentage="$gpu_raw"
}

main() {
  print_load_bar "$1"
}
main "$@"
