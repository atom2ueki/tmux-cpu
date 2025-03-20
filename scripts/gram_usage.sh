#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_usage_format="%3.1f"
gram_unit="G"

get_gram_data() {
  if command_exists "nvidia-smi"; then
    # Direct query for memory usage - returns CSV with values in MB
    nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -n1
  elif command_exists "cuda-smi"; then
    # Fallback for older CUDA systems
    cuda_output=$(cuda-smi | grep -E "^Global")
    if [[ -n "$cuda_output" ]]; then
      # Extract values in MB format
      used=$(echo "$cuda_output" | grep -Eo "[0-9.]+ of [0-9.]+ MB" | sed -E 's/([0-9.]+) of ([0-9.]+) MB/\1/')
      total=$(echo "$cuda_output" | grep -Eo "[0-9.]+ of [0-9.]+ MB" | sed -E 's/([0-9.]+) of ([0-9.]+) MB/\2/')
      echo "$used $total"
    else
      echo "0 0"
    fi
  else
    echo "0 0"
  fi
}

print_gram_usage() {
  gram_usage_format=$(get_tmux_option "@gram_usage_format" "$gram_usage_format")
  gram_unit=$(get_tmux_option "@gram_unit" "$gram_unit")
  
  # Get VRAM data directly from nvidia-smi
  gram_data=$(get_gram_data)
  
  # Check if valid data returned
  if [[ "$gram_data" == "0 0" ]]; then
    echo -n "No GPU"
    return
  fi
  
  # Extract used VRAM (first value in the output)
  used_gram=$(echo "$gram_data" | awk '{print $1}')
  
  # Convert to the requested unit
  if [ "$gram_unit" = "G" ]; then
    # Convert from MB to GB
    used_gram_in_unit=$(echo "scale=1; $used_gram / 1024" | bc)
  else
    # Already in MB
    used_gram_in_unit=$used_gram
  fi
  
  # Format with proper precision
  printf "$gram_usage_format$gram_unit" "$used_gram_in_unit"
}

print_total_gram() {
  gram_unit=$(get_tmux_option "@gram_unit" "$gram_unit")
  
  # Get VRAM data directly from nvidia-smi
  gram_data=$(get_gram_data)
  
  # Check if valid data returned
  if [[ "$gram_data" == "0 0" ]]; then
    echo -n "No GPU"
    return
  fi
  
  # Extract total VRAM (second value in the output)
  total_gram=$(echo "$gram_data" | awk '{print $2}')
  
  # Convert to the requested unit
  if [ "$gram_unit" = "G" ]; then
    # Convert from MB to GB
    total_gram_in_unit=$(echo "scale=1; $total_gram / 1024" | bc)
  else
    # Already in MB
    total_gram_in_unit=$total_gram
  fi
  
  # Format with proper precision
  printf "%.1f$gram_unit" "$total_gram_in_unit"
}

main() {
  if [ "$1" = "total" ]; then
    print_total_gram
  else
    print_gram_usage
  fi
  # Add a newline to properly terminate output
  echo ""
}
main "$@" 