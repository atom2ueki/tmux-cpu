# Tmux CPU and GPU status

Enables displaying CPU and GPU information in Tmux `status-right` and `status-left`.
Configurable percentage and load bar display with One Dark Pro theme styling.

## Features

- Automatically applies an elegant One Dark Pro theme by default
- Shows CPU, RAM, GPU and VRAM usage with load bars
- Temperature monitoring for CPU and GPU
- Fully customizable colors, thresholds, and formatting
- CPU usage percentage
- CPU temperature
- CPU load bar visualizing usage
- RAM usage percentage
- RAM load bar visualizing usage
- GPU usage percentage (requires nvidia-smi or cuda-smi)
- GPU temperature (requires nvidia-smi)
- GPU load bar visualizing usage
- VRAM (Graphics RAM) usage (requires nvidia-smi or cuda-smi)
- VRAM load bar visualizing usage

## Enhanced Load Bar Format

The load bars now display information inside the brackets:
- CPU and GPU load bars: `[||| 6.2%]` - Shows percentage inside brackets
- RAM and VRAM load bars: `[||| 10G/22G]` - Shows usage/total inside brackets

The numbers are colored based on the defined thresholds, and the brackets can be customized with a different color.

## Installation
### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```shell
set -g @plugin 'tmux-plugins/tmux-cpu'
```

Hit `prefix + I` to fetch the plugin and source it.

If format strings are added to `status-right`, they should now be visible.

### Manual Installation

Clone the repo:

```shell
$ git clone https://github.com/tmux-plugins/tmux-cpu ~/clone/path
```

Add this line to the bottom of `.tmux.conf`:

```shell
run-shell ~/clone/path/cpu.tmux
```

Reload TMUX environment:

```shell
# type this in terminal
$ tmux source-file ~/.tmux.conf
```

If format strings are added to `status-right`, they should now be visible.

### Optional requirements (Linux, BSD, OSX)

- `iostat` or `sar` are the best way to get an accurate CPU percentage.
A fallback is included using `ps aux` but could be inaccurate.
- `free` is used for obtaining system RAM status.
- `lm-sensors` is used for CPU temperature.
- `nvidia-smi` is required for GPU information.
For OSX, `cuda-smi` is required instead (but only shows GPU memory use rather than load).
If "No GPU" is displayed, it means the script was not able to find `nvidia-smi`/`cuda-smi`.
Please make sure the appropriate command is installed and in the `$PATH`.

## For Developers

The project now uses a reusable load bar component that can be used consistently across all resource types.

### Using the Load Bar Component

The load bar component (`scripts/load_bar.sh`) provides a consistent way to display resource usage with a progress bar. It can be used as follows:

```bash
# For percentage-based resources (CPU, GPU)
./load_bar.sh --type=cpu --value="5.3%"

# For memory-based resources (RAM, GRAM)
./load_bar.sh --type=ram --value="8.2G" --total="16.0G"

# With custom thresholds
./load_bar.sh --type=cpu --value="5.3%" --threshold-med=30 --threshold-high=80

# With direct percentage value
./load_bar.sh --type=cpu --value="5.3%" --percentage=5.3
```

The component automatically reads tmux settings for colors and formatting based on the specified type.

### Parameters

- `--type`: Resource type (cpu, ram, gpu, gram)
- `--value`: The value to display (with unit if applicable)
- `--total`: Total value (for memory resources)
- `--percentage`: Direct percentage value (optional)
- `--threshold-med`: Medium load threshold (default: 30)
- `--threshold-high`: High load threshold (default: 80)

## Usage

The plugin automatically applies a stylish One Dark Pro theme to your tmux status bar. You can add any of the supported format strings (see below) to customize your `status-right` tmux option.

Example:

```shell
# in .tmux.conf
set -g status-right 'CPU: #{cpu_load_bar} #{cpu_percentage} | %a %h-%d %H:%M '
```

If you don't customize the status line, a default One Dark Pro styled status line will be applied automatically.

### Supported Options

This is done by introducing format strings that can be added to
`status-right` option:

- `#{cpu_load_bar}` - will display a CPU usage progress bar (colored based on load)
- `#{cpu_percentage}` - will show CPU percentage (averaged across cores)
- `#{ram_load_bar}` - will display a RAM usage progress bar (colored based on usage)
- `#{ram_percentage}` - will show RAM percentage (averaged across cores)
- `#{ram_usage}` - will show RAM usage in GB or MB
- `#{total_ram}` - will show total RAM available in GB or MB
- `#{cpu_temp}` - will show CPU temperature (averaged across cores, colored based on temperature)

GPU equivalents also exist:

- `#{gpu_load_bar}` - will display a GPU usage progress bar (colored based on load)
- `#{gpu_percentage}` - will show GPU percentage (averaged across devices)
- `#{gram_load_bar}` - will display a GPU RAM usage progress bar (colored based on usage)
- `#{gram_percentage}` - will show GPU RAM percentage (total across devices)
- `#{gram_usage}` - will show GPU RAM usage in GB or MB
- `#{total_gram}` - will show total GPU RAM available in GB or MB
- `#{gpu_temp}` - will show GPU temperature (average across devices, colored based on temperature)

## Examples

CPU usage lower than 30%:<br/>
![low_fg](/screenshots/low_fg.png)
![low_bg](/screenshots/low_bg.png)
![low_icon](/screenshots/low_icon.png)

CPU usage between 30% and 80%:<br/>
![medium_fg](/screenshots/medium_fg.png)
![medium_bg](/screenshots/medium_bg.png)
![medium_icon](/screenshots/medium_icon.png)

CPU usage higher than 80%:<br/>
![high_fg](/screenshots/high_fg.png)
![high_bg](/screenshots/high_bg.png)
![high_icon](/screenshots/high_icon.png)

## Customization

The plugin applies One Dark Pro theme by default with elegant styling for all metrics. It uses a transparent background (`bg=default`) that inherits your terminal's background settings. If you want to customize any of the settings, here are all available options:

```shell
# Progress bar settings (load bars use "■" character by default)
@cpu_progress_length "8" # length of the progress bar
@cpu_progress_char "■" # character for the filled portion of the bar
@cpu_empty_char " " # character for the empty portion of the bar
@cpu_left_bracket "[" # left bracket for the progress bar
@cpu_right_bracket "]" # right bracket for the progress bar

# One Dark Pro theme colors are applied by default with transparent backgrounds
# You can override them with your own custom colors:
@cpu_low_color "#[fg=green,bg=default]" # color when usage is low (with transparent background)
@cpu_medium_color "#[fg=yellow,bg=default]" # color when usage is medium (with transparent background)
@cpu_high_color "#[fg=red,bg=default]" # color when usage is high (with transparent background)

@cpu_percentage_format "%3.1f%%" # printf format to use to display percentage

@cpu_medium_thresh "30" # medium percentage threshold
@cpu_high_thresh "80" # high percentage threshold

@ram_(progress_length,high_color,etc...) # same defaults as above

@cpu_temp_format "%2.0f" # printf format to use to display temperature
@cpu_temp_scale "C" # temperature scale, supports C or F (unit will display as °C or °F)

@cpu_temp_medium_thresh "80" # medium temperature threshold
@cpu_temp_high_thresh "90" # high temperature threshold

@cpu_temp_(low_color,medium_color,high_color) # controls temperature text colors

@ram_usage_format "%3.1f" # printf format for RAM usage display (without unit)
@ram_unit "GB" # unit for RAM display, either "GB" or "MB"

@gram_usage_format "%3.1f" # printf format for GPU RAM usage display (without unit)
@gram_unit "GB" # unit for GPU RAM display, either "GB" or "MB"
```

All `@cpu_*` options are valid with `@gpu_*` (except `@cpu_*_thresh` which apply to both CPU and GPU). Additionally, `@ram_*` options become `@gram_*` for GPU equivalents.

Note that these colors depend on your terminal / X11 config.

You can can customize each one of these options in your `.tmux.conf`, for example:

```shell
set -g @cpu_low_color "#[fg=#00ff00]" # Set a custom color for low CPU usage
set -g @cpu_percentage_format "%5.1f%%" # Add left padding
set -g @cpu_progress_char "■" # Use a different character for the progress bar
set -g @cpu_progress_length "8" # Set a custom length for progress bars
set -g @cpu_temp_scale "F" # Use Fahrenheit temperature scale (will display as °F)
```

Don't forget to reload the tmux environment (`$ tmux source-file ~/.tmux.conf`) after you do this.

### Troubleshooting

#### Transparency in Status Bar

By default, the plugin uses `bg=default` for the status bar background, which enables transparency if your terminal supports it. This allows the status bar to inherit your terminal's background settings.

If you prefer a solid background, add the following to your `.tmux.conf`:

```shell
# Set a solid background color
set -g status-style bg=black  # Or any other color you prefer
```

#### Green Background in Status Bar

If your status bar has unwanted background colors when using the load bar or percentage indicators, add the following to your `.tmux.conf`:

```shell
# Fix background color issue
set -g status-style bg=black  # Or any other color you prefer
```

### Tmux Plugins

This plugin is part of the [tmux-plugins](https://github.com/tmux-plugins) organisation. Checkout plugins as [battery](https://github.com/tmux-plugins/tmux-battery), [logging](https://github.com/tmux-plugins/tmux-logging), [online status](https://github.com/tmux-plugins/tmux-online-status), and many more over at the [tmux-plugins](https://github.com/tmux-plugins) organisation page.

### Maintainers

- [Camille Tjhoa](https://github.com/ctjhoa)
- [Casper da Costa-Luis](https://github.com/casperdcl)

### License

[MIT](LICENSE.md)