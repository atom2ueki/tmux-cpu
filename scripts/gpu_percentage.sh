#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gpu_percentage_format="%3.1f%%"

get_gpu_usage() {
  if command_exists "nvidia-smi"; then
    loads=$(cached_eval nvidia-smi)
  elif command_exists "cuda-smi"; then
    loads=$(cached_eval cuda-smi)
  else
    echo "No GPU"
    return 1
  fi
  echo "$loads" | sed -nr 's/.*\s([0-9]+)%.*/\1/p' | awk '{sum+=$1; n+=1} END {printf "%5.3f", sum/n}'
}

print_gpu_percentage() {
  gpu_percentage_format=$(get_tmux_option "@gpu_percentage_format" "$gpu_percentage_format")

  local gpu_usage
  gpu_usage=$(get_gpu_usage)
  
  # Check for errors
  if [[ $? -ne 0 || "$gpu_usage" == "No GPU" ]]; then
    echo -n "No GPU"
    return
  fi
  
  # Format and print
  printf "$gpu_percentage_format" "$gpu_usage"
}

# Make this value available for the load bar script
print_raw_gpu_percentage() {
  get_gpu_usage
  # Check for errors
  if [[ $? -ne 0 ]]; then
    echo "0"
  fi
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_gpu_percentage
  else
    print_gpu_percentage
  fi
}
main "$@"
