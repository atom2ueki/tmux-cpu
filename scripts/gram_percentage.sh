#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_percentage_format="%3.1f%%"

get_gram_percentage() {
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
  local used_gram
  local total_gram
  
  used_gram=$(echo "$used_output" | sed -e 's/[^0-9.]//g')
  total_gram=$(echo "$total_output" | sed -e 's/[^0-9.]//g')
  
  # Calculate percentage using bc for better precision
  if [[ -n "$used_gram" && -n "$total_gram" && "$total_gram" != "0" ]]; then
    echo "scale=1; 100 * $used_gram / $total_gram" | bc
  else
    echo "0"
  fi
}

print_gram_percentage() {
  gram_percentage_format=$(get_tmux_option "@gram_percentage_format" "$gram_percentage_format")
  
  # Get the percentage
  local percentage
  percentage=$(get_gram_percentage)
  
  # Check if GPU is available
  if [[ "$percentage" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Format the percentage
  printf "$gram_percentage_format" "$percentage"
}

# Print raw percentage value for the load bar component
print_raw_gram_percentage() {
  get_gram_percentage
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_gram_percentage
  else
    print_gram_percentage
  fi
}
main "$@"
