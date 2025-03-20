#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"

cpu_interpolation=(
  "\#{cpu_percentage}"
  "\#{cpu_icon}"
  "\#{gpu_percentage}"
  "\#{gpu_icon}"
  "\#{ram_percentage}"
  "\#{ram_icon}"
  "\#{gram_percentage}"
  "\#{gram_icon}"
  "\#{cpu_temp}"
  "\#{gpu_temp}"
  "\#{ram_usage}"
  "\#{total_ram}"
  "\#{gram_usage}"
  "\#{total_gram}"
)
cpu_commands=(
  "#($CURRENT_DIR/scripts/cpu_percentage.sh)"
  "#($CURRENT_DIR/scripts/cpu_icon.sh)"
  "#($CURRENT_DIR/scripts/gpu_percentage.sh)"
  "#($CURRENT_DIR/scripts/gpu_icon.sh)"
  "#($CURRENT_DIR/scripts/ram_percentage.sh)"
  "#($CURRENT_DIR/scripts/ram_icon.sh)"
  "#($CURRENT_DIR/scripts/gram_percentage.sh)"
  "#($CURRENT_DIR/scripts/gram_icon.sh)"
  "#($CURRENT_DIR/scripts/cpu_temp.sh)"
  "#($CURRENT_DIR/scripts/gpu_temp.sh)"
  "#($CURRENT_DIR/scripts/ram_usage.sh)"
  "#($CURRENT_DIR/scripts/ram_usage.sh total)"
  "#($CURRENT_DIR/scripts/gram_usage.sh)"
  "#($CURRENT_DIR/scripts/gram_usage.sh total)"
)

set_tmux_option() {
  local option=$1
  local value=$2
  tmux set-option -gq "$option" "$value"
}

do_interpolation() {
  local all_interpolated="$1"
  for ((i = 0; i < ${#cpu_commands[@]}; i++)); do
    all_interpolated=${all_interpolated//${cpu_interpolation[$i]}/${cpu_commands[$i]}}
  done
  echo "$all_interpolated"
}

update_tmux_option() {
  local option
  local option_value
  local new_option_value
  option=$1
  option_value=$(get_tmux_option "$option")
  new_option_value=$(do_interpolation "$option_value")
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}
main
