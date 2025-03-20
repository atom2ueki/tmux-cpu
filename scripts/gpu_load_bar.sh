#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get GPU percentage
  local gpu_percentage
  local gpu_raw
  
  gpu_percentage=$("$CURRENT_DIR"/gpu_percentage.sh)
  gpu_raw=$("$CURRENT_DIR"/gpu_percentage.sh raw)
  
  # Strip newlines from both values
  gpu_percentage=$(echo -n "$gpu_percentage" | tr -d '\n')
  gpu_raw=$(echo -n "$gpu_raw" | tr -d '\n')
  
  # Check if gpu_percentage is empty or "No GPU"
  if [[ -z "$gpu_percentage" || "$gpu_percentage" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Use the shared load bar component with GPU parameters and raw percentage value
  "$CURRENT_DIR"/load_bar.sh --type=gpu --value="$gpu_percentage" --percentage="$gpu_raw"
}

main() {
  print_load_bar "$1"
}
main "$@"
