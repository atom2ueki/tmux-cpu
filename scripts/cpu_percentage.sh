#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

cpu_percentage_format="%3.1f%%"

get_cpu_usage() {
  local cpu_usage=0
  
  # Try method 1: top command (more universal)
  if command_exists "top"; then
    if is_linux; then
      # Extract CPU usage from top on Linux (100 - idle%)
      cpu_usage=$(top -bn1 | grep "%Cpu" | awk '{print 100 - $8}')
    elif is_osx; then
      # Extract CPU usage from top on macOS
      cpu_usage=$(top -l 1 | grep -E "^CPU" | awk '{print $3}' | tr -d '%')
    fi
  fi
  
  # If top didn't work or returned 0, try iostat
  if [[ -z "$cpu_usage" || "$cpu_usage" = "0" ]] && command_exists "iostat"; then
    if is_linux_iostat; then
      cpu_usage=$(cached_eval iostat -c 1 2 | sed '/^\s*$/d' | tail -n 1 | awk '{usage=100-$NF} END {print usage}' | sed 's/,/./')
    fi
  fi
  
  # If iostat didn't work or returned 0, try sar
  if [[ -z "$cpu_usage" || "$cpu_usage" = "0" ]] && command_exists "sar"; then
    cpu_usage=$(cached_eval sar -u 1 1 | sed '/^\s*$/d' | tail -n 1 | awk '{usage=100-$NF} END {print usage}' | sed 's/,/./')
  fi
  
  # If all else failed, use ps as last resort
  if [[ -z "$cpu_usage" || "$cpu_usage" = "0" ]]; then
    # Fallback method using ps
    load=$(cached_eval ps aux | awk '{print $3}' | tail -n+2 | awk '{s+=$1} END {print s}')
    cpus=$(cpus_number)
    if [[ -n "$load" && -n "$cpus" && "$cpus" != "0" ]]; then
      cpu_usage=$(echo "$load $cpus" | awk '{print $1/$2}')
    fi
  fi
  
  # Final sanity check
  if [[ -z "$cpu_usage" ]]; then
    echo "0"
  else
    echo "$cpu_usage"
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
