#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"

# One Dark Pro colors
onedark_black="#282c34"
onedark_blue="#61afef" 
onedark_yellow="#e5c07b"
onedark_red="#e06c75"
onedark_white="#aab2bf"
onedark_green="#98c379"
onedark_visual_grey="#3e4452"
onedark_comment_grey="#5c6370"
onedark_cyan="#56b6c2"
onedark_purple="#c678dd"

# Apply One Dark Pro theme by default - no separate theme file needed
# Theme is applied first, then scripts read the values from tmux options
# Users can override these values in their own .tmux.conf if desired
apply_one_dark_theme() {
  # Set status bar colors - using default for background allows terminal transparency
  tmux set-option -gq "status-style" "bg=default,fg=$onedark_white"
  
  # Window status format and colors
  tmux set-option -gq "window-status-format" "#[fg=$onedark_white,bg=default] #I:#W "
  tmux set-option -gq "window-status-current-format" "#[fg=$onedark_black,bg=$onedark_blue,bold] #I:#W "
  
  # Pane border colors
  tmux set-option -gq "pane-border-style" "fg=$onedark_comment_grey"
  tmux set-option -gq "pane-active-border-style" "fg=$onedark_blue"
  
  # Message colors
  tmux set-option -gq "message-style" "bg=$onedark_comment_grey,fg=$onedark_white"
  
  # CPU/GPU load bar appearance
  tmux set-option -gq "@cpu_progress_char" "■"
  tmux set-environment -g "@cpu_progress_char" "■"
  
  tmux set-option -gq "@cpu_empty_char" " "
  tmux set-environment -g "@cpu_empty_char" " "
  
  tmux set-option -gq "@cpu_progress_length" "8"
  tmux set-environment -g "@cpu_progress_length" "8"
  
  tmux set-option -gq "@cpu_left_bracket" "["
  tmux set-environment -g "@cpu_left_bracket" "["
  
  tmux set-option -gq "@cpu_right_bracket" "]"
  tmux set-environment -g "@cpu_right_bracket" "]"
  
  # Same for GPU
  tmux set-option -gq "@gpu_progress_char" "■"
  tmux set-environment -g "@gpu_progress_char" "■"
  
  tmux set-option -gq "@gpu_empty_char" " "
  tmux set-environment -g "@gpu_empty_char" " "
  
  tmux set-option -gq "@gpu_progress_length" "8"
  tmux set-environment -g "@gpu_progress_length" "8"
  
  tmux set-option -gq "@gpu_left_bracket" "["
  tmux set-environment -g "@gpu_left_bracket" "["
  
  tmux set-option -gq "@gpu_right_bracket" "]"
  tmux set-environment -g "@gpu_right_bracket" "]"
  
  # And RAM
  tmux set-option -gq "@ram_progress_char" "■"
  tmux set-environment -g "@ram_progress_char" "■"
  
  tmux set-option -gq "@ram_empty_char" " "
  tmux set-environment -g "@ram_empty_char" " "
  
  tmux set-option -gq "@ram_progress_length" "8"
  tmux set-environment -g "@ram_progress_length" "8"
  
  tmux set-option -gq "@ram_left_bracket" "["
  tmux set-environment -g "@ram_left_bracket" "["
  
  tmux set-option -gq "@ram_right_bracket" "]"
  tmux set-environment -g "@ram_right_bracket" "]"
  
  # And GRAM
  tmux set-option -gq "@gram_progress_char" "■"
  tmux set-environment -g "@gram_progress_char" "■"
  
  tmux set-option -gq "@gram_empty_char" " "
  tmux set-environment -g "@gram_empty_char" " "
  
  tmux set-option -gq "@gram_progress_length" "8"
  tmux set-environment -g "@gram_progress_length" "8"
  
  tmux set-option -gq "@gram_left_bracket" "["
  tmux set-environment -g "@gram_left_bracket" "["
  
  tmux set-option -gq "@gram_right_bracket" "]"
  tmux set-environment -g "@gram_right_bracket" "]"
  
  # Set theme colors for all indicators - CPU (using default for background)
  tmux set-option -gq "@cpu_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@cpu_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@cpu_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@cpu_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@cpu_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@cpu_high_color" "#[fg=$onedark_red,bg=default]"
  
  # GPU colors (using default for background)
  tmux set-option -gq "@gpu_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@gpu_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@gpu_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@gpu_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@gpu_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@gpu_high_color" "#[fg=$onedark_red,bg=default]"
  
  # RAM colors (using default for background)
  tmux set-option -gq "@ram_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@ram_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@ram_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@ram_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@ram_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@ram_high_color" "#[fg=$onedark_red,bg=default]"
  
  # GRAM colors (using default for background)
  tmux set-option -gq "@gram_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@gram_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@gram_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@gram_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@gram_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@gram_high_color" "#[fg=$onedark_red,bg=default]"
  
  # Temperature colors - CPU (using default for background)
  tmux set-option -gq "@cpu_temp_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@cpu_temp_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@cpu_temp_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@cpu_temp_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@cpu_temp_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@cpu_temp_high_color" "#[fg=$onedark_red,bg=default]"
  
  # Temperature colors - GPU (using default for background)
  tmux set-option -gq "@gpu_temp_low_color" "#[fg=$onedark_green,bg=default]"
  tmux set-environment -g "@gpu_temp_low_color" "#[fg=$onedark_green,bg=default]"
  
  tmux set-option -gq "@gpu_temp_medium_color" "#[fg=$onedark_yellow,bg=default]"
  tmux set-environment -g "@gpu_temp_medium_color" "#[fg=$onedark_yellow,bg=default]"
  
  tmux set-option -gq "@gpu_temp_high_color" "#[fg=$onedark_red,bg=default]"
  tmux set-environment -g "@gpu_temp_high_color" "#[fg=$onedark_red,bg=default]"
}

cpu_interpolation=(
  "\#{cpu_percentage}"
  "\#{cpu_load_bar}"
  "\#{gpu_percentage}"
  "\#{gpu_load_bar}"
  "\#{ram_percentage}"
  "\#{ram_load_bar}"
  "\#{gram_percentage}"
  "\#{gram_load_bar}"
  "\#{cpu_temp}"
  "\#{gpu_temp}"
  "\#{ram_usage}"
  "\#{total_ram}"
  "\#{gram_usage}"
  "\#{total_gram}"
)
cpu_commands=(
  "#($CURRENT_DIR/scripts/cpu_percentage.sh)"
  "#($CURRENT_DIR/scripts/cpu_load_bar.sh)"
  "#($CURRENT_DIR/scripts/gpu_percentage.sh)"
  "#($CURRENT_DIR/scripts/gpu_load_bar.sh)"
  "#($CURRENT_DIR/scripts/ram_percentage.sh)"
  "#($CURRENT_DIR/scripts/ram_load_bar.sh)"
  "#($CURRENT_DIR/scripts/gram_percentage.sh)"
  "#($CURRENT_DIR/scripts/gram_load_bar.sh)"
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

# Set up an attractive One Dark Pro formatted status line by default
setup_default_status_line() {
  local current_status_right
  current_status_right=$(tmux show-option -gv "status-right")
  
  # Only set the default if the user hasn't configured anything
  if [ -z "$current_status_right" ] || [ "$current_status_right" == "#{?window_zoomed_flag,[Z],} %H:%M %d-%b-%y" ]; then
    # Create a nice One Dark Pro themed status line with transparent background
    tmux set-option -gq "status-right" "\
#[fg=$onedark_white,bg=default]CPU #[fg=$onedark_cyan,bg=default]#{cpu_percentage} #[fg=$onedark_purple,bg=default]#{cpu_temp} #{cpu_load_bar} | \
#[fg=$onedark_white,bg=default]RAM #[fg=$onedark_cyan,bg=default]#{ram_usage} #{ram_load_bar} | \
#[fg=$onedark_white,bg=default]%a %h-%d %H:%M "
    
    # Set status line right length to accommodate our template
    tmux set-option -gq "status-right-length" "100"
  fi
}

main() {
  # First apply One Dark Pro theme settings
  apply_one_dark_theme
  
  # Set up default status line if user hasn't configured one
  setup_default_status_line
  
  # Update any template variables in status-right and status-left
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}
main
