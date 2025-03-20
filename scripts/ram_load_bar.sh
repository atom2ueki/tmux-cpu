#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get RAM usage and total
  local ram_usage
  local total_ram
  
  ram_usage=$("$CURRENT_DIR"/ram_usage.sh)
  total_ram=$("$CURRENT_DIR"/ram_usage.sh total)
  
  # Check for any error conditions
  if [[ -z "$ram_usage" || -z "$total_ram" ]]; then
    echo "RAM Usage Error"
    return
  fi
  
  # Modify units if needed (GB to G, MB to M)
  ram_unit=$(get_tmux_option "@ram_unit" "G")
  if [ "$ram_unit" = "GB" ]; then
    ram_usage=${ram_usage/GB/G}
    total_ram=${total_ram/GB/G}
  elif [ "$ram_unit" = "MB" ]; then
    ram_usage=${ram_usage/MB/M}
    total_ram=${total_ram/MB/M}
  fi
  
  # Use the shared load bar component with RAM parameters
  "$CURRENT_DIR"/load_bar.sh --type=ram --value="$ram_usage" --total="$total_ram"
}

main() {
  print_load_bar "$1"
}
main "$@"
