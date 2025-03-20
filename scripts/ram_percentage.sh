#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_percentage_format="%3.1f%%"

get_ram_percentage() {
  if command_exists "free"; then
    cached_eval free | awk -v format="%3.1f" '$1 ~ /Mem/ {printf(format, 100*$3/$2)}'
  else
    echo "0"
  fi
}

print_ram_percentage() {
  ram_percentage_format=$(get_tmux_option "@ram_percentage_format" "$ram_percentage_format")
  
  # Get raw percentage
  local percentage
  percentage=$(get_ram_percentage)
  
  # Format the percentage
  printf "$ram_percentage_format" "$percentage"
}

# Print raw percentage value for the load bar component
print_raw_ram_percentage() {
  if command_exists "free"; then
    cached_eval free | awk '$1 ~ /Mem/ {print 100*$3/$2}'
  else
    echo "0"
  fi
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_ram_percentage
  else
    print_ram_percentage
  fi
}
main "$@"
