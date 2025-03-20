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
  
  # Make sure we have a valid number
  if ! [[ "$used_ram" =~ ^[0-9]+$ ]]; then
    used_ram=0
  fi
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3 for GB
  else
    divisor=1048576     # 1024^2 for MB
  fi
  
  # Convert bytes to the requested unit (if used_ram is 0, skip calculation)
  if [ "$used_ram" -eq 0 ]; then
    used_ram_in_unit=0
  else
    used_ram_in_unit=$(echo "scale=1; $used_ram / $divisor" | bc)
  fi
  
  # Format with proper precision
  printf "$ram_usage_format$ram_unit" "$used_ram_in_unit"
}

print_total_ram() {
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  # Get total RAM in bytes
  total_ram=$(get_total_ram)
  
  # Make sure we have a valid number
  if ! [[ "$total_ram" =~ ^[0-9]+$ ]]; then
    total_ram=0
  fi
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3 for GB
  else
    divisor=1048576     # 1024^2 for MB
  fi
  
  # Convert bytes to the requested unit (if total_ram is 0, skip calculation)
  if [ "$total_ram" -eq 0 ]; then
    total_ram_in_unit=0
  else
    total_ram_in_unit=$(echo "scale=1; $total_ram / $divisor" | bc)
  fi
  
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