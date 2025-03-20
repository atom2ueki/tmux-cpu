#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get VRAM usage values
  local gram_usage
  local total_gram
  
  gram_usage=$("$CURRENT_DIR"/gram_usage.sh)
  total_gram=$("$CURRENT_DIR"/gram_usage.sh total)
  
  # Check if GPU is available
  if [[ "$gram_usage" == "No GPU" || "$total_gram" == "No GPU" ]]; then
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
  
  # Use the shared load bar component with GRAM parameters
  "$CURRENT_DIR"/load_bar.sh --type=gram --value="$gram_usage" --total="$total_gram"
}

main() {
  print_load_bar "$1"
}
main "$@"
