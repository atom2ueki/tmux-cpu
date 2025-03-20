#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_percentage_format="%3.1f%%"

print_gram_percentage() {
  gram_percentage_format=$(get_tmux_option "@gram_percentage_format" "$gram_percentage_format")
  
  # Get values from existing scripts
  local used_gram
  local total_gram
  
  # Get raw output first to check if GPU exists
  local used_output
  local total_output
  
  used_output=$("$CURRENT_DIR"/gram_usage.sh)
  total_output=$("$CURRENT_DIR"/gram_usage.sh total)
  
  # Check if GPU is available
  if [[ "$used_output" == "No GPU" || "$total_output" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Extract numeric values from gram_usage output
  used_gram=$(echo "$used_output" | sed -e 's/[^0-9.]//g')
  total_gram=$(echo "$total_output" | sed -e 's/[^0-9.]//g')
  
  # Calculate percentage
  if [[ -n "$used_gram" && -n "$total_gram" && "$total_gram" != "0" ]]; then
    echo "$used_gram $total_gram" | awk -v format="$gram_percentage_format" '{printf(format, 100*$1/$2)}'
  else
    printf "$gram_percentage_format" 0
  fi
}

main() {
  print_gram_percentage
}
main "$@"
