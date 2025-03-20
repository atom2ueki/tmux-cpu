#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_percentage_format="%3.1f%%"

get_gram_percentage() {
  if command_exists "nvidia-smi"; then
    used_total=$(cached_eval nvidia-smi | sed -nr 's/.*\s([0-9]+)MiB\s*\/\s*([0-9]+)MiB.*/\1 \2/p')
  elif command_exists "cuda-smi"; then
    used_total=$(cached_eval cuda-smi | sed -nr 's/.*\s([0-9.]+) of ([0-9.]+) MB.*/\1 \2/p')
  else
    echo "No GPU"
    return
  fi
  
  # Check if we got valid data
  if [ -z "$used_total" ]; then
    echo "0"
    return
  fi
  
  # Calculate percentage
  used=$(echo "$used_total" | awk '{sum += $1} END {print sum}')
  total=$(echo "$used_total" | awk '{sum += $2} END {print sum}')
  echo "$used $total" | awk '{printf "%.1f", 100 * $1 / $2}'
}

print_gram_percentage() {
  gram_percentage_format=$(get_tmux_option "@gram_percentage_format" "$gram_percentage_format")
  
  # Get the percentage
  local percentage
  percentage=$(get_gram_percentage)
  
  # Check if GPU is available
  if [[ "$percentage" == "No GPU" ]]; then
    echo "No GPU"
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
