#!/usr/bin/env bash

export LANG=C
export LC_ALL=C

# Simple cache mechanism using files instead of associative arrays
# Cached values to avoid repeated identical commands 
# declare -A _cached_values  # Removed as it's incompatible with older bash

# Gets tmux option
# Usage: get_tmux_option <option_name> <default_value>
get_tmux_option() {
  local option_value
  
  # Try to get the option value from tmux
  if tmux_is_running; then
    option_value=$(tmux show-option -gqv "$1" 2>/dev/null)
  else
    option_value=""
  fi

  # If the option is not set or tmux is not running, use the default
  if [[ -z "$option_value" ]]; then
    echo "$2"
  else
    echo "$option_value"
  fi
}

# Returns true if tmux is running
tmux_is_running() {
  if command -v tmux >/dev/null 2>&1 && [ -n "${TMUX-}" ]; then
    return 0
  fi
  return 1
}

# Determines if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_osx() {
  [ $(uname) == "Darwin" ]
}

is_linux() {
  [ $(uname) == "Linux" ]
}

is_freebsd() {
  [ $(uname) == "FreeBSD" ]
}

is_openbsd() {
  [ $(uname) == "OpenBSD" ]
}

is_cygwin() {
  command -v WMIC >/dev/null 2>&1
}

is_linux_iostat() {
  # Linux iostat shows CPU (system, user, IOwait, idle) at first line
  iostat | awk 'NR == 1 { print $0 }' | grep -q "CPU" && grep -q "system" || false
}

# is second float bigger or equal?
fcomp() {
  awk -v n1="$1" -v n2="$2" 'BEGIN {if (n1<=n2) exit 0; exit 1}'
}

load_status() {
  local percentage=$1
  local prefix=$2
  medium_thresh=$(get_tmux_option "@${prefix}_medium_thresh" "30")
  high_thresh=$(get_tmux_option "@${prefix}_high_thresh" "80")
  if fcomp "$high_thresh" "$percentage"; then
    echo "high"
  elif fcomp "$medium_thresh" "$percentage" && fcomp "$percentage" "$high_thresh"; then
    echo "medium"
  else
    echo "low"
  fi
}

temp_status() {
  local temp
  temp=$1
  cpu_temp_medium_thresh=$(get_tmux_option "@cpu_temp_medium_thresh" "80")
  cpu_temp_high_thresh=$(get_tmux_option "@cpu_temp_high_thresh" "90")
  if fcomp "$cpu_temp_high_thresh" "$temp"; then
    echo "high"
  elif fcomp "$cpu_temp_medium_thresh" "$temp" && fcomp "$temp" "$cpu_temp_high_thresh"; then
    echo "medium"
  else
    echo "low"
  fi
}

cpus_number() {
  if is_linux; then
    echo $(nproc 2>/dev/null || lscpu -p | grep -c "^[0-9]" 2>/dev/null || grep -c "^processor" /proc/cpuinfo 2>/dev/null)
  elif is_osx; then
    echo $(sysctl -n hw.ncpu)
  elif is_freebsd || is_openbsd; then
    echo $(sysctl -n hw.ncpu)
  else
    echo 1
  fi
}

get_tmp_dir() {
  local tmpdir
  tmpdir="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
  [ -d "$tmpdir" ] || local tmpdir=~/tmp
  echo "$tmpdir/tmux-$EUID-cpu"
}

get_time() {
  date +%s.%N
}

get_cache_val() {
  local key
  local timeout
  local cache
  key="$1"
  # seconds after which cache is invalidated
  timeout="${2:-2}"
  cache="$(get_tmp_dir)/$key"
  if [ -f "$cache" ]; then
    awk -v cache="$(head -n1 "$cache")" -v timeout="$timeout" -v now="$(get_time)" \
      'BEGIN {if (now - timeout < cache) exit 0; exit 1}' &&
      tail -n+2 "$cache"
  fi
}

put_cache_val() {
  local key
  local val
  local tmpdir
  key="$1"
  val="${*:2}"
  tmpdir="$(get_tmp_dir)"
  [ ! -d "$tmpdir" ] && mkdir -p "$tmpdir" && chmod 0700 "$tmpdir"
  (
    get_time
    echo -n "$val"
  ) >"$tmpdir/$key"
  echo -n "$val"
}

# Cached evaluation of a command - uses file-based caching
# Usage: cached_eval <command> [cache_key]
cached_eval() {
  local command="$1"
  local cache_key="${2:-$command}"
  local result
  
  # Try to get cached value
  result=$(get_cache_val "$cache_key")
  
  # If not cached, evaluate and cache
  if [ -z "$result" ]; then
    result=$(eval "$command")
    put_cache_val "$cache_key" "$result"
  fi
  
  echo "$result"
}
