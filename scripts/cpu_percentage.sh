#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

cpu_percentage_format="%3.1f%%"

get_cpu_usage() {
  # Try using mpstat if available (most accurate)
  if command_exists "mpstat"; then
    # mpstat with 1 second delay, get the idle percentage from the last line
    idle=$(mpstat 1 1 | tail -n 1 | awk '{print $NF}')
    # Convert to usage percentage
    if [[ "$idle" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
      echo "scale=1; 100 - $idle" | bc
      return
    fi
  fi
  
  # Try using /proc/stat directly (Linux-specific but reliable)
  if [ -f "/proc/stat" ]; then
    # Get two samples of CPU stats with 1 second interval
    local cpu1 cpu2 idle1 idle2 total1 total2
    cpu1=$(grep '^cpu ' /proc/stat)
    sleep 1
    cpu2=$(grep '^cpu ' /proc/stat)
    
    # Extract the idle time values
    idle1=$(echo "$cpu1" | awk '{print $5}')
    idle2=$(echo "$cpu2" | awk '{print $5}')
    
    # Calculate the total CPU times
    total1=$(echo "$cpu1" | awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; print sum}')
    total2=$(echo "$cpu2" | awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; print sum}')
    
    # Calculate the CPU usage percentage
    if [[ "$idle1" =~ ^[0-9]+$ ]] && [[ "$idle2" =~ ^[0-9]+$ ]] && \
       [[ "$total1" =~ ^[0-9]+$ ]] && [[ "$total2" =~ ^[0-9]+$ ]]; then
      idle_diff=$((idle2 - idle1))
      total_diff=$((total2 - total1))
      
      if [ "$total_diff" -gt 0 ]; then
        echo "scale=1; 100 * (1 - $idle_diff / $total_diff)" | bc
        return
      fi
    fi
  fi
  
  # Try top as a fallback
  if command_exists "top"; then
    if is_linux; then
      # Extract CPU idle time from top
      idle=$(top -bn1 | grep "%Cpu" | awk '{print $8}')
      if [[ "$idle" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
        echo "scale=1; 100 - $idle" | bc
        return
      fi
    fi
  fi
  
  # Last resort: try ps to estimate CPU usage
  if command_exists "ps"; then
    load=$(ps -eo pcpu | tail -n+2 | awk '{sum+=$1} END {print sum}')
    cpus=$(cpus_number)
    
    if [[ "$load" =~ ^[0-9]+(\.)?[0-9]*$ ]] && [ "$cpus" -gt 0 ]; then
      echo "scale=1; if($load > 100 * $cpus) then 100 else $load / $cpus fi" | bc
      return
    fi
  fi
  
  # If all methods failed
  echo "0"
}

print_cpu_percentage() {
  cpu_percentage_format=$(get_tmux_option "@cpu_percentage_format" "$cpu_percentage_format")
  
  # Get the raw CPU usage value
  local cpu_usage
  cpu_usage=$(get_cpu_usage)
  
  # Make sure we have a valid number
  if ! [[ "$cpu_usage" =~ ^[0-9]+(\.)?[0-9]*$ ]]; then
    cpu_usage=0
  fi
  
  # Format the percentage
  printf "$cpu_percentage_format" "$cpu_usage"
}

# Make this value available for the load bar script
print_raw_cpu_percentage() {
  get_cpu_usage
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_cpu_percentage
  else
    print_cpu_percentage
  fi
}
main "$@"
