#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

ram_usage_format="%3.1f"
ram_unit="G"

get_ram_data() {
  local used
  local total
  
  if is_linux; then
    # Linux: Get RAM info from the MiB Mem line in top
    mem_line=$(top -bn1 | grep -E "^MiB Mem")
    total=$(echo "$mem_line" | awk '{print $4}')
    used=$(echo "$mem_line" | awk '{print $8}')
    echo "$used $total"
  elif is_osx; then
    # macOS: Parse PhysMem line from top
    # Format: "PhysMem: 31G used (3773M wired, 7999M compressor), 210M unused."
    mem_line=$(top -l 1 | grep -E "^PhysMem:")
    
    # Extract used memory (removing the 'G' or 'M' suffix)
    used_str=$(echo "$mem_line" | sed -E 's/.*PhysMem: ([0-9]+[GM]) used.*/\1/')
    used_num=$(echo "$used_str" | sed -E 's/([0-9]+).*/\1/')
    used_unit=$(echo "$used_str" | sed -E 's/[0-9]+([GM]).*/\1/')
    
    # Extract unused memory (removing the 'G' or 'M' suffix)
    unused_str=$(echo "$mem_line" | sed -E 's/.* ([0-9]+[GM]) unused.*/\1/')
    unused_num=$(echo "$unused_str" | sed -E 's/([0-9]+).*/\1/')
    unused_unit=$(echo "$unused_str" | sed -E 's/[0-9]+([GM]).*/\1/')
    
    # Convert to MB if needed
    if [ "$used_unit" = "G" ]; then
      used=$(echo "$used_num * 1024" | bc)
    else
      used=$used_num
    fi
    
    if [ "$unused_unit" = "G" ]; then
      unused=$(echo "$unused_num * 1024" | bc)
    else
      unused=$unused_num
    fi
    
    # Calculate total
    total=$(echo "$used + $unused" | bc)
    
    echo "$used $total"
  else
    # Fallback for other systems
    echo "0 0"
  fi
}

print_ram_usage() {
  ram_usage_format=$(get_tmux_option "@ram_usage_format" "$ram_usage_format")
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  # Get RAM data
  ram_data=$(get_ram_data)
  used=$(echo "$ram_data" | awk '{print $1}')
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    # Convert from MB to GB 
    used_in_unit=$(echo "scale=1; $used / 1024" | bc)
  else
    # Already in MB
    used_in_unit=$used
  fi
  
  # Format with proper precision
  printf "$ram_usage_format$ram_unit" "$used_in_unit"
  
  # Ensure output ends with a newline
  echo ""
}

print_total_ram() {
  ram_unit=$(get_tmux_option "@ram_unit" "$ram_unit")
  
  # Get RAM data
  ram_data=$(get_ram_data)
  total=$(echo "$ram_data" | awk '{print $2}')
  
  # Convert to the requested unit
  if [ "$ram_unit" = "G" ]; then
    # Convert from MB to GB
    total_in_unit=$(echo "scale=1; $total / 1024" | bc)
  else
    # Already in MB
    total_in_unit=$total
  fi
  
  # Format with proper precision
  printf "%.1f$ram_unit" "$total_in_unit"
  
  # Ensure output ends with a newline
  echo ""
}

main() {
  if [ "$1" = "total" ]; then
    print_total_ram
  else
    print_ram_usage
  fi
}
main "$@" 