# Tmux CPU and GPU status

Enables displaying CPU and GPU information in Tmux `status-right` and `status-left`.
Configurable percentage and icon display.

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

## Usage

Add any of the supported format strings (see below) to the existing `status-right` tmux option.
Example:

```shell
# in .tmux.conf
set -g status-right '#{cpu_bg_color} CPU: #{cpu_icon} #{cpu_percentage} | %a %h-%d %H:%M '
```

### Supported Options

This is done by introducing format strings that can be added to
`status-right` option:

- `#{cpu_icon}` - will display a CPU usage progress bar (colored based on load)
- `#{cpu_percentage}` - will show CPU percentage (averaged across cores)
- `#{ram_icon}` - will display a RAM usage progress bar (colored based on usage)
- `#{ram_percentage}` - will show RAM percentage (averaged across cores)
- `#{ram_usage}` - will show RAM usage in GB or MB
- `#{total_ram}` - will show total RAM available in GB or MB
- `#{cpu_temp}` - will show CPU temperature (averaged across cores, colored based on temperature)

GPU equivalents also exist:

- `#{gpu_icon}` - will display a GPU usage progress bar (colored based on load)
- `#{gpu_percentage}` - will show GPU percentage (averaged across devices)
- `#{gram_icon}` - will display a GPU RAM usage progress bar (colored based on usage)
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

Here are all available options with their default values:

```shell
# Progress bar settings (for cpu, gpu, ram, gram icons)
@cpu_progress_length "10" # length of the progress bar
@cpu_progress_char "|" # character for the filled portion of the bar
@cpu_empty_char " " # character for the empty portion of the bar
@cpu_left_bracket "[" # left bracket for the progress bar
@cpu_right_bracket "]" # right bracket for the progress bar

# Color settings
@cpu_low_color "#[fg=green]" # color when usage is low
@cpu_medium_color "#[fg=yellow]" # color when usage is medium
@cpu_high_color "#[fg=red]" # color when usage is high

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

### Tmux Plugins

This plugin is part of the [tmux-plugins](https://github.com/tmux-plugins) organisation. Checkout plugins as [battery](https://github.com/tmux-plugins/tmux-battery), [logging](https://github.com/tmux-plugins/tmux-logging), [online status](https://github.com/tmux-plugins/tmux-online-status), and many more over at the [tmux-plugins](https://github.com/tmux-plugins) organisation page.

### Maintainers

- [Camille Tjhoa](https://github.com/ctjhoa)
- [Casper da Costa-Luis](https://github.com/casperdcl)

### License

[MIT](LICENSE.md)