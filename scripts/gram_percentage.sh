#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_percentage_format="%3.1f%%"

get_gram_percentage() {
  if ! command_exists "nvidia-smi" && ! command_exists "cuda-smi"; then
    echo "No GPU"
    return
  fi
  
  # Get direct values from memory query
  local gram_data
  
  if command_exists "nvidia-smi"; then
    # Get used and total memory directly
    gram_data=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -n1)
  else
    # Try cuda-smi as fallback
    cuda_output=$(cuda-smi | grep -E "^Global")
    if [[ -n "$cuda_output" ]]; then
      used=$(echo "$cuda_output" | grep -Eo "[0-9.]+ of [0-9.]+ MB" | sed -E 's/([0-9.]+) of ([0-9.]+) MB/\1/')
      total=$(echo "$cuda_output" | grep -Eo "[0-9.]+ of [0-9.]+ MB" | sed -E 's/([0-9.]+) of ([0-9.]+) MB/\2/')
      gram_data="$used $total"
    else
      echo "No GPU"
      return
    fi
  fi
  
  # Extract values and calculate percentage
  local used_gram
  local total_gram
  
  used_gram=$(echo "$gram_data" | awk '{print $1}')
  total_gram=$(echo "$gram_data" | awk '{print $2}')
  
  # Calculate percentage
  if [[ -n "$used_gram" && -n "$total_gram" && "$total_gram" != "0" ]]; then
    echo "scale=1; 100 * $used_gram / $total_gram" | bc
  else
    echo "0"
  fi
}

print_gram_percentage() {
  gram_percentage_format=$(get_tmux_option "@gram_percentage_format" "$gram_percentage_format")
  
  # Get the percentage
  local percentage
  percentage=$(get_gram_percentage)
  
  # Check if GPU is available
  if [[ "$percentage" == "No GPU" ]]; then
    echo -n "No GPU"
    return
  fi
  
  # Format the percentage
  printf "$gram_percentage_format" "$percentage"
}

# Print raw percentage value for the load bar component
print_raw_gram_percentage() {
  get_gram_percentage
}

main() {
  if [ "$1" = "raw" ]; then
    print_raw_gram_percentage
  else
    print_gram_percentage
  fi
}
main "$@"
