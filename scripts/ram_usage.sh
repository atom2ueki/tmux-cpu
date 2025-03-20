#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_usage_format="%3.1f"
ram_unit="G"

sum_macos_vm_stats() {
  grep -Eo '[0-9]+' |
    awk '{ a += $1 * 4096 } END { print a }'
}

get_total_ram() {
  if command_exists "free"; then
    cached_eval free | awk '$1 ~ /Mem/ {print $2 * 1024}'
  elif command_exists "vm_stat"; then
    stats="$(cached_eval vm_stat)"
    
    used_and_cached=$(
      echo "$stats" |
        grep -E "(Pages active|Pages inactive|Pages speculative|Pages wired down|Pages occupied by compressor)" |
        sum_macos_vm_stats
    )

    free=$(
      echo "$stats" |
        grep -E "(Pages free)" |
        sum_macos_vm_stats
    )

    echo $((used_and_cached + free))
  fi
}

get_used_ram() {
  if command_exists "free"; then
    cached_eval free | awk '$1 ~ /Mem/ {print $3 * 1024}'
  elif command_exists "vm_stat"; then
    stats="$(cached_eval vm_stat)"
    
    used_and_cached=$(
      echo "$stats" |
        grep -E "(Pages active|Pages inactive|Pages speculative|Pages wired down|Pages occupied by compressor)" |
        sum_macos_vm_stats
    )

    cached=$(
      echo "$stats" |
        grep -E "(Pages purgeable|File-backed pages)" |
        sum_macos_vm_stats
    )

    echo $((used_and_cached - cached))
  fi
}

print_ram_usage() {
  ram_usage_format=$(get_tmux_option "@ram_usage_format" "$ram_usage_format")
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  used_ram=$(get_used_ram)
  total_ram=$(get_total_ram)
  
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3
  else
    divisor=1048576     # 1024^2
  fi
  
  used_ram_in_unit=$(echo "$used_ram $divisor" | awk '{printf "%f", $1 / $2}')
  
  printf "$ram_usage_format$ram_unit" "$used_ram_in_unit"
}

print_total_ram() {
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  total_ram=$(get_total_ram)
  
  if [ "$ram_unit" = "G" ]; then
    divisor=1073741824  # 1024^3
  else
    divisor=1048576     # 1024^2
  fi
  
  total_ram_in_unit=$(echo "$total_ram $divisor" | awk '{printf "%f", $1 / $2}')
  
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