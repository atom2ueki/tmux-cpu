#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_usage_format="%3.1f"
ram_unit="G"

get_used_ram() {
  if command_exists "free"; then
    # Use free command to get used memory in bytes
    cached_eval free -b | awk '$1 ~ /Mem/ {print $3}'
  else
    echo "0"
  fi
}

get_total_ram() {
  if command_exists "free"; then
    # Use free command to get total memory in bytes
    cached_eval free -b | awk '$1 ~ /Mem/ {print $2}'
  else
    echo "0"
  fi
}

print_ram_usage() {
  ram_usage_format=$(get_tmux_option "@ram_usage_format" "$ram_usage_format")
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  # Get used RAM in bytes
  used_ram=$(get_used_ram)
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3 for GB
  else
    divisor=1048576     # 1024^2 for MB
  fi
  
  # Convert bytes to the requested unit
  used_ram_in_unit=$(echo "scale=1; $used_ram / $divisor" | bc)
  
  # Format with proper precision
  printf "$ram_usage_format$ram_unit" "$used_ram_in_unit"
}

print_total_ram() {
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  # Get total RAM in bytes
  total_ram=$(get_total_ram)
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3 for GB
  else
    divisor=1048576     # 1024^2 for MB
  fi
  
  # Convert bytes to the requested unit
  total_ram_in_unit=$(echo "scale=1; $total_ram / $divisor" | bc)
  
  # Format with proper precision
  printf "%.1f$ram_unit" "$total_ram_in_unit"
}

main() {
  if [ "$1" = "total" ]; then
    print_total_ram
  else
    print_ram_usage
  fi
}
main "$@" 