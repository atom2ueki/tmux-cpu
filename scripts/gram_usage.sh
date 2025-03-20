#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/helpers.sh
source "$CURRENT_DIR/helpers.sh"

gram_usage_format="%3.1f"
gram_unit="GB"

get_gram_data() {
  if command_exists "nvidia-smi"; then
    # Returns "used total" in MiB
    cached_eval nvidia-smi | sed -nr 's/.*\s([0-9]+)MiB\s*\/\s*([0-9]+)MiB.*/\1 \2/p'
  elif command_exists "cuda-smi"; then
    # Returns "used total" in MB
    cached_eval cuda-smi | sed -nr 's/.*\s([0-9.]+) of ([0-9.]+) MB.*/\1 \2/p'
  else
    echo "0 0"
    return
  fi
}

print_gram_usage() {
  gram_usage_format=$(get_tmux_option "@gram_usage_format" "$gram_usage_format")
  gram_unit=$(get_tmux_option "@gram_unit" "$gram_unit")
  
  gram_data=$(get_gram_data)
  
  if [ "$gram_data" = "0 0" ]; then
    echo "No GPU"
    return
  fi
  
  used_gram=$(echo "$gram_data" | awk '{sum += $1} END {print sum}')
  
  # Convert from MiB or MB to the requested unit
  if [ "$gram_unit" = "GB" ]; then
    used_gram=$(echo "$used_gram" | awk '{printf "%f", $1 / 1024}')
  fi
  
  printf "$gram_usage_format$gram_unit" "$used_gram"
}

print_total_gram() {
  gram_unit=$(get_tmux_option "@gram_unit" "$gram_unit")
  
  gram_data=$(get_gram_data)
  
  if [ "$gram_data" = "0 0" ]; then
    echo "No GPU"
    return
  fi
  
  total_gram=$(echo "$gram_data" | awk '{sum += $2} END {print sum}')
  
  # Convert from MiB or MB to the requested unit
  if [ "$gram_unit" = "GB" ]; then
    total_gram=$(echo "$total_gram" | awk '{printf "%f", $1 / 1024}')
  fi
  
  printf "%.1f$gram_unit" "$total_gram"
}

main() {
  if [ "$1" = "total" ]; then
    print_total_gram
  else
    print_gram_usage
  fi
}
main "$@" 