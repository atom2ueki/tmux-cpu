#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

print_load_bar() {
  # Get RAM usage and total
  local ram_usage
  local total_ram
  local ram_percentage
  
  ram_usage=$("$CURRENT_DIR"/ram_usage.sh)
  total_ram=$("$CURRENT_DIR"/ram_usage.sh total)
  ram_percentage=$("$CURRENT_DIR"/ram_percentage.sh raw)
  
  # Strip newlines from all values
  ram_usage=$(echo -n "$ram_usage" | tr -d '\n')
  total_ram=$(echo -n "$total_ram" | tr -d '\n')
  ram_percentage=$(echo -n "$ram_percentage" | tr -d '\n')
  
  # Check for any error conditions
  if [[ -z "$ram_usage" || -z "$total_ram" ]]; then
    echo "RAM Usage Error"
    return
  fi
  
  # Debug - make sure used is not greater than total
  ram_usage_num=$(echo "$ram_usage" | sed -e 's/[^0-9.]//g')
  total_ram_num=$(echo "$total_ram" | sed -e 's/[^0-9.]//g')
  if (( $(echo "$ram_usage_num > $total_ram_num" | bc -l) )); then
    # If usage > total, swap them as they're likely reversed
    local temp=$ram_usage
    ram_usage=$total_ram
    total_ram=$temp
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
  
  # Use the shared load bar component with RAM parameters and raw percentage
  "$CURRENT_DIR"/load_bar.sh --type=ram --value="$ram_usage" --total="$total_ram" --percentage="$ram_percentage"
}

main() {
  print_load_bar "$1"
}
main "$@"
