#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get VRAM usage values
  local gram_usage
  local total_gram
  local gram_percentage
  
  gram_usage=$("$CURRENT_DIR"/gram_usage.sh)
  total_gram=$("$CURRENT_DIR"/gram_usage.sh total)
  gram_percentage=$("$CURRENT_DIR"/gram_percentage.sh raw)
  
  # Strip newlines from all values
  gram_usage=$(echo -n "$gram_usage" | tr -d '\n')
  total_gram=$(echo -n "$total_gram" | tr -d '\n')
  gram_percentage=$(echo -n "$gram_percentage" | tr -d '\n')
  
  # Check if GPU is available
  if [[ "$gram_usage" == "No GPU" || "$total_gram" == "No GPU" || "$gram_percentage" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Modify units if needed (GB to G, MB to M)
  local gram_unit=$(get_tmux_option "@gram_unit" "G")
  if [[ "$gram_unit" == "GB" ]]; then
    gram_usage=${gram_usage/GB/G}
    total_gram=${total_gram/GB/G}
  elif [[ "$gram_unit" == "MB" ]]; then
    gram_usage=${gram_usage/MB/M}
    total_gram=${total_gram/MB/M}
  fi
  
  # Use the shared load bar component with GRAM parameters and raw percentage
  "$CURRENT_DIR"/load_bar.sh --type=gram --value="$gram_usage" --total="$total_gram" --percentage="$gram_percentage"
}

main() {
  print_load_bar "$1"
}
main "$@"
