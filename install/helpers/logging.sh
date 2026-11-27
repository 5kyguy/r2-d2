#!/bin/bash

# Strip ANSI escapes and collapse \r progress bars (pacman/yay) to their final
# segment, for display only. The log file itself stays raw; this runs on the
# read path (live monitor and error tail).
sanitize_log_lines() {
  sed -e 's/\x1b\[[0-9;?]*[A-Za-z]//g' -e 's/^.*\r//'
}

# Compose the status bar line: current script, progress bar, elapsed time.
build_install_status() {
  local scripts_done=$1 total_scripts=$2 current_script=$3 start_epoch=$4
  local pad=${PADDING_LEFT:-0}
  local width=${LOG_LINE_WIDTH:-80}

  local name
  name=$(basename "${current_script:-starting...}")
  if ((${#name} > 24)); then
    name="${name:0:21}..."
  fi

  local elapsed=0
  if ((start_epoch > 0)); then
    elapsed=$(date +%s)
    elapsed=$((elapsed - start_epoch))
  fi
  local mins=$((elapsed / 60))
  local secs=$((elapsed % 60))

  # Fit the bar into the width left over after the fixed text
  local text="Installing: $name  ["
  local suffix="]  ${scripts_done}/${total_scripts}  ${mins}m ${secs}s"
  local bar_width=$((width - pad - ${#text} - ${#suffix}))
  ((bar_width < 10)) && bar_width=10
  ((total_scripts < 1)) && total_scripts=1

  local filled=$((bar_width * scripts_done / total_scripts))
  ((filled > bar_width)) && filled=$bar_width

  local bar="" i
  for ((i = 0; i < filled; i++)); do
    bar+="█"
  done
  for ((i = filled; i < bar_width; i++)); do
    bar+="░"
  done

  printf '%s%s%s' "$text" "$bar" "$suffix"
}

start_log_output() {
  local ANSI_CLEAR_LINE="\033[2K"
  local ANSI_HIDE_CURSOR="\033[?25l"
  local ANSI_RESET="\033[0m"
  local ANSI_GRAY="\033[90m"
  local ANSI_RED="\033[31m"
  local ANSI_GREEN="\033[32m"
  local ANSI_CYAN="\033[36m"

  # Hide cursor while the monitor owns the screen
  printf $ANSI_HIDE_CURSOR

  (
    # Row 0 is the status bar; the remaining rows show the log.
    # Paint from an absolute row and budget the rows so the last one painted
    # is at most TERM_HEIGHT - 1: a frame that ends with a newline on the
    # bottom row scrolls the terminal, and at 10 Hz that is a 10 rows/second
    # roll that wrecks the display. Absolute positioning also survives stray
    # lines above (prompts, echoes) that would stale a saved cursor.
    local start_row=$((LOGO_HEIGHT + 2))
    local log_lines=$((TERM_HEIGHT - start_row))
    ((log_lines < 2)) && log_lines=2

    # Use full terminal width (bounded by LOG_LINE_WIDTH)
    local max_line_width=${LOG_LINE_WIDTH:-$TERM_WIDTH}

    # Total scripts in the pipeline: one run_logged line per script in the
    # phase all.sh files — self-maintaining as scripts are added or removed
    local total_scripts=0
    total_scripts=$(grep -ch '^run_logged' "$R2D2_INSTALL"/*/all.sh 2>/dev/null | awk '{s+=$1} END{print s+0}' || true)

    # Elapsed time anchor, set by start_install_log
    local start_epoch=0
    if [[ -n ${R2D2_START_TIME:-} ]]; then
      start_epoch=$(date -d "$R2D2_START_TIME" +%s 2>/dev/null || echo 0)
    fi

    # Progress state, refreshed about once a second: the scan walks the log
    # backwards to the attempt marker, while the display tail reads only the
    # last few lines
    local status="" status_tick=0 scripts_done=0 current_script=""

    while true; do
      # Read the last N-1 log lines into an array, sanitized for display
      mapfile -t current_lines < <(tail -n $((log_lines - 1)) "$R2D2_INSTALL_LOG_FILE" 2>/dev/null | sanitize_log_lines)

      if ((status_tick % 10 == 0)); then
        # Scripts started since the last attempt marker (retry-safe) and the
        # most recent one
        read -r scripts_done current_script < <(
          tac "$R2D2_INSTALL_LOG_FILE" 2>/dev/null | awk '
            /\] Starting: / {
              count++
              if (current == "") {
                current = $0
                sub(/.*\] Starting: /, "", current)
              }
            }
            /=== R2-D2 Installation Started/ { exit }
            END { print count, current }
          '
        ) || true
        scripts_done=${scripts_done:-0}
        status=$(build_install_status "$scripts_done" "$total_scripts" "$current_script" "$start_epoch")
      fi
      status_tick=$((status_tick + 1))

      # Build complete output buffer with escape sequences
      output=""

      # Row 0: the status bar, aligned under the logo like the old header
      status_display=$status
      if ((${#status_display} > max_line_width)); then
        status_display="${status_display:0:max_line_width}..."
      fi
      output+="${ANSI_CLEAR_LINE}${ANSI_CYAN}${PADDING_LEFT_SPACES}${status_display}${ANSI_RESET}\n"

      for ((i = 0; i < log_lines - 1; i++)); do
        line="${current_lines[i]:-}"

        # Truncate if needed
        if ((${#line} > max_line_width)); then
          line="${line:0:max_line_width}..."
        fi

        # Add clear line escape and formatted output for each line (full width,
        # no centering). Marker lines get a render color; the file stays plain.
        if [[ -n $line ]]; then
          # run_logged markers carry a "[timestamp] " prefix — strip it for matching
          bare=${line#\[*\] }
          color=$ANSI_GRAY
          case $bare in
          "Failed:"* | "ERROR:"* | "Error:"* | "error:"*)
            color=$ANSI_RED
            ;;
          "Completed:"*)
            color=$ANSI_GREEN
            ;;
          "Starting:"*)
            color=$ANSI_CYAN
            ;;
          esac

          output+="${ANSI_CLEAR_LINE}${color}${line}${ANSI_RESET}\n"
        else
          output+="${ANSI_CLEAR_LINE}\n"
        fi
      done

      printf "\033[${start_row};1H%b" "$output"

      sleep 0.1
    done
  ) &
  monitor_pid=$!
}

stop_log_output() {
  if [[ -n ${monitor_pid:-} ]]; then
    kill $monitor_pid 2>/dev/null || true
    wait $monitor_pid 2>/dev/null || true
    unset monitor_pid
  fi
}

start_install_log() {
  sudo touch "$R2D2_INSTALL_LOG_FILE"
  sudo chmod 666 "$R2D2_INSTALL_LOG_FILE"

  export R2D2_START_TIME
  R2D2_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

  echo "=== R2-D2 Installation Started: $R2D2_START_TIME ===" >>"$R2D2_INSTALL_LOG_FILE"
  start_log_output
}

stop_install_log() {
  stop_log_output
  show_cursor

  if [[ -n ${R2D2_INSTALL_LOG_FILE:-} ]]; then
    R2D2_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== R2-D2 Installation Completed: $R2D2_END_TIME ===" >>"$R2D2_INSTALL_LOG_FILE"
    echo "" >>"$R2D2_INSTALL_LOG_FILE"
    echo "=== Installation Time Summary ===" >>"$R2D2_INSTALL_LOG_FILE"

    if [[ -f "/var/log/archinstall/install.log" ]]; then
      ARCHINSTALL_START=$(grep -m1 '^\[' /var/log/archinstall/install.log 2>/dev/null | sed 's/^\[\([^]]*\)\].*/\1/' || true)
      ARCHINSTALL_END=$(grep 'Installation completed without any errors' /var/log/archinstall/install.log 2>/dev/null | sed 's/^\[\([^]]*\)\].*/\1/' || true)

      if [[ -n $ARCHINSTALL_START ]] && [[ -n $ARCHINSTALL_END ]]; then
        ARCH_START_EPOCH=$(date -d "$ARCHINSTALL_START" +%s)
        ARCH_END_EPOCH=$(date -d "$ARCHINSTALL_END" +%s)
        ARCH_DURATION=$((ARCH_END_EPOCH - ARCH_START_EPOCH))

        ARCH_MINS=$((ARCH_DURATION / 60))
        ARCH_SECS=$((ARCH_DURATION % 60))

        echo "Archinstall: ${ARCH_MINS}m ${ARCH_SECS}s" >>"$R2D2_INSTALL_LOG_FILE"
      fi
    fi

    if [[ -n $R2D2_START_TIME ]]; then
      R2D2_START_EPOCH=$(date -d "$R2D2_START_TIME" +%s)
      R2D2_END_EPOCH=$(date -d "$R2D2_END_TIME" +%s)
      R2D2_DURATION=$((R2D2_END_EPOCH - R2D2_START_EPOCH))

      R2D2_MINS=$((R2D2_DURATION / 60))
      R2D2_SECS=$((R2D2_DURATION % 60))

      echo "R2-D2:     ${R2D2_MINS}m ${R2D2_SECS}s" >>"$R2D2_INSTALL_LOG_FILE"

      if [[ -n ${ARCH_DURATION:-} ]]; then
        TOTAL_DURATION=$((ARCH_DURATION + R2D2_DURATION))
      else
        TOTAL_DURATION=$R2D2_DURATION
      fi
      TOTAL_MINS=$((TOTAL_DURATION / 60))
      TOTAL_SECS=$((TOTAL_DURATION % 60))
      echo "Total:       ${TOTAL_MINS}m ${TOTAL_SECS}s" >>"$R2D2_INSTALL_LOG_FILE"
    fi
    echo "=================================" >>"$R2D2_INSTALL_LOG_FILE"

    echo "Rebooting system..." >>"$R2D2_INSTALL_LOG_FILE"
  fi
}

ensure_install_log() {
  if [[ ! -f $R2D2_INSTALL_LOG_FILE ]]; then
    sudo touch "$R2D2_INSTALL_LOG_FILE"
    sudo chmod 666 "$R2D2_INSTALL_LOG_FILE"
  fi
}

run_logged() {
  local script="$1"

  export CURRENT_SCRIPT="$script"

  ensure_install_log
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" >>"$R2D2_INSTALL_LOG_FILE"

  # Fail fast inside the script: without set -e, a mid-script failure is
  # swallowed and the child exits with the last command's status, so the
  # Completed/Failed markers can lie. The ERR trap logs the failing command
  # as a signal line for the live log and the error tail.
  bash -c "
    set -eEo pipefail
    export PATH=\"$R2D2_PATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\${PATH}\"
    export R2D2_PATH=\"$R2D2_PATH\"
    export R2D2_INSTALL=\"$R2D2_INSTALL\"
    export R2D2_INSTALL_LOG_FILE=\"$R2D2_INSTALL_LOG_FILE\"
    trap 'echo \"ERROR: command failed (exit \$?): \$BASH_COMMAND\" >&2' ERR
    sudo -n -v 2>/dev/null || {
      echo \"ERROR: sudo credentials expired — select 'Retry installation' to re-authenticate\"
      exit 1
    }
    source '$R2D2_INSTALL/helpers/chroot.sh'
    source '$script'
  " </dev/null >>"$R2D2_INSTALL_LOG_FILE" 2>&1

  local exit_code=$?

  if ((exit_code == 0)); then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script" >>"$R2D2_INSTALL_LOG_FILE"
    unset CURRENT_SCRIPT
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)" >>"$R2D2_INSTALL_LOG_FILE"
  fi

  return $exit_code
}
