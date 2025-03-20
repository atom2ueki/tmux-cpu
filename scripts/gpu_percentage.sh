#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gpu_percentage_format="%3.1f%%"

get_gpu_usage() {
  if command_exists "nvidia-smi"; then
    # Direct query for GPU utilization - more reliable than parsing text output
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{sum+=$1} END {printf "%.1f", sum/NR}'
  elif command_exists "cuda-smi"; then
    # Fallback for older CUDA systems
    cuda-smi | grep -Eo "[0-9]+%" | head -n1 | tr -d '%'
  else
    echo "No GPU"
    return 1
  fi
}

print_gpu_percentage() {
  gpu_percentage_format=$(get_tmux_option "@gpu_percentage_format" "$gpu_percentage_format")

  local gpu_usage
  gpu_usage=$(get_gpu_usage)
  
  # Check for errors
  if [[ $? -ne 0 || "$gpu_usage" == "No GPU" ]]; then
    echo "No GPU"
    return
  fi
  
  # Format and print
  printf "$gpu_percentage_format" "$gpu_usage"
  
  # Ensure output ends with a newline
  echo ""
}

# Make this value available for the load bar script
print_raw_gpu_percentage() {
  get_gpu_usage
  # Check for errors
  if [[ $? -ne 0 ]]; then
    echo "0"
  fi
  
  # Ensure output ends with a newline
  echo ""
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_gpu_percentage
  else
    print_gpu_percentage
  fi
}
main "$@"
