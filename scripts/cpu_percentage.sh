#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

cpu_percentage_format="%3.1f%%"

get_cpu_usage() {
  if is_linux; then
    # Linux: Parse CPU idle percentage from top and convert to used percentage
    top -bn1 | grep "%Cpu" | awk '{print 100 - $8}'
  elif is_osx; then
    # macOS: Parse CPU idle percentage from top and convert to used percentage
    top -l 1 | grep -E "^CPU usage" | sed -E 's/.*([0-9]+\.[0-9]+)% idle.*/\1/' | awk '{print 100 - $1}'
  else
    # Fallback for other systems
    echo "0"
  fi
}

print_cpu_percentage() {
  cpu_percentage_format=$(get_tmux_option "@cpu_percentage_format" "$cpu_percentage_format")
  
  # Get the raw CPU usage value
  local cpu_usage
  cpu_usage=$(get_cpu_usage)
  
  # Format the percentage
  if [[ -n "$cpu_usage" && "$cpu_usage" != "0" ]]; then
    printf "$cpu_percentage_format" "$cpu_usage"
  else
    printf "$cpu_percentage_format" 0
  fi
  
  # Ensure output ends with a newline
  echo ""
}

# Make this value available for the load bar script
print_raw_cpu_percentage() {
  get_cpu_usage
  
  # Ensure output ends with a newline
  echo ""
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_cpu_percentage
  else
    print_cpu_percentage
  fi
}
main "$@"
