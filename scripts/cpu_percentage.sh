#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

cpu_percentage_format="%3.1f%%"

get_cpu_usage() {
  if command_exists "iostat"; then
    if is_linux_iostat; then
      cached_eval iostat -c 1 2 | sed '/^\s*$/d' | tail -n 1 | awk '{usage=100-$NF} END {print usage}' | sed 's/,/./'
    else
      echo "0"
    fi
  elif command_exists "sar"; then
    cached_eval sar -u 1 1 | sed '/^\s*$/d' | tail -n 1 | awk '{usage=100-$NF} END {print usage}' | sed 's/,/./'
  else
    # Fallback method using ps
    load=$(cached_eval ps aux | awk '{print $3}' | tail -n+2 | awk '{s+=$1} END {print s}')
    cpus=$(cpus_number)
    echo "$load $cpus" | awk '{print $1/$2}'
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
