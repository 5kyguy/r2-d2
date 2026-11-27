#!/bin/bash

# Track if we're already handling an error to prevent double-trapping
ERROR_HANDLING=false

# Cursor is usually hidden while we install
show_cursor() {
  printf "\033[?25h"
}

# Display signal lines from the install log (failures, errors, warnings),
# preferring them over the raw tail so the cause isn't buried under package
# noise. Falls back to the raw tail when nothing matches.
show_log_tail() {
  if [[ ! -f ${R2D2_INSTALL_LOG_FILE:-} ]]; then
    return 0
  fi

  local log_lines=$((TERM_HEIGHT - LOGO_HEIGHT - 8))
  ((log_lines < 1)) && log_lines=20
  local max_line_width=${LOG_LINE_WIDTH:-$((LOGO_WIDTH - 4))}

  local recent lines
  recent=$(tail -n 50 "$R2D2_INSTALL_LOG_FILE" 2>/dev/null | sanitize_log_lines)

  # Tool error/warning lines first (pacman, makepkg, helpers). The Failed:
  # marker is skipped on purpose — the failed script is shown separately below
  lines=$(grep -E '^(ERROR:|Error:|error:|WARNING:|warning:|==> (ERROR:|error:))' <<<"$recent" | tail -n "$log_lines")
  if [[ -z $lines ]]; then
    lines=$(tail -n "$log_lines" <<<"$recent")
  fi

  if [[ -n $lines ]]; then
    while IFS= read -r line; do
      if ((${#line} > max_line_width)); then
        local truncated_line="${line:0:max_line_width-3}..."
      else
        local truncated_line="$line"
      fi

      gum style "$truncated_line"
    done <<<"$lines"
  fi

  gum style "Full log: $R2D2_INSTALL_LOG_FILE"
  echo
}

# Display the failed command or script name
show_failed_script_or_command() {
  if [[ -n ${CURRENT_SCRIPT:-} ]]; then
    gum style "Failed script: $CURRENT_SCRIPT"
  else
    # Truncate long command lines to fit the display
    local cmd="$BASH_COMMAND"
    local max_cmd_width=${LOG_LINE_WIDTH:-$((LOGO_WIDTH - 4))}

    if ((${#cmd} > max_cmd_width)); then
      cmd="${cmd:0:max_cmd_width-3}..."
    fi

    gum style "$cmd"
  fi
}

# Save original stdout and stderr for trap to use
save_original_outputs() {
  exec 3>&1 4>&2
}

# Restore stdout and stderr to original (saved in FD 3 and 4)
# This ensures output goes to screen, not log file
restore_outputs() {
  if [[ -e /proc/self/fd/3 ]] && [[ -e /proc/self/fd/4 ]]; then
    exec 1>&3 2>&4
  fi
}

# Error handler
catch_errors() {
  # Prevent recursive error handling
  if [[ $ERROR_HANDLING == "true" ]]; then
    return
  else
    ERROR_HANDLING=true
  fi

  # Store exit code immediately before it gets overwritten
  local exit_code=$?

  set +e
  set +o pipefail

  stop_log_output
  # Nothing from the install may touch sudo while the menu owns the tty in
  # raw mode: a background sudo prompt would race the menu's key reader and
  # eat the typed password. Retries re-authenticate visibly via begin.sh.
  stop_sudo_keeper
  restore_outputs

  clear_logo
  show_cursor

  gum style --foreground 1 --padding "1 0 1 $PADDING_LEFT" "R2-D2 installation stopped!"
  show_log_tail

  gum style "This command halted with exit code $exit_code:"
  show_failed_script_or_command

  # Offer options menu
  while true; do
    options=()
    options+=("Retry installation")
    options+=("View full log")
    options+=("Exit")

    choice=$(gum choose "${options[@]}" --header "What would you like to do?" --height 5 --padding "1 $PADDING_LEFT")

    case "$choice" in
    "Retry installation")
      bash ~/.local/share/r2-d2/install.sh
      break
      ;;
    "View full log")
      if command -v less &>/dev/null; then
        less "$R2D2_INSTALL_LOG_FILE"
      else
        tail "$R2D2_INSTALL_LOG_FILE"
      fi
      ;;
    "Exit" | "")
      exit 1
      ;;
    esac
  done
}

# Keep sudo credentials warm for the whole install. Long phases (AUR builds
# and their downloads, the whisper model fetch) outlast sudo's timestamp; the
# run_logged children read stdin from /dev/null and the live monitor owns the
# screen, so a mid-install sudo prompt is invisible and times out — which
# kills yay's internal 'sudo pacman' dependency installs. -n never prompts.
SUDO_KEEPER_PID=""

start_sudo_keeper() {
  if [[ -n $SUDO_KEEPER_PID ]]; then
    return 0
  fi

  (
    while true; do
      sudo -n -v 2>/dev/null || true
      sleep 60
    done
  ) &
  SUDO_KEEPER_PID=$!
}

stop_sudo_keeper() {
  if [[ -n ${SUDO_KEEPER_PID:-} ]]; then
    kill $SUDO_KEEPER_PID 2>/dev/null || true
    wait $SUDO_KEEPER_PID 2>/dev/null || true
    unset SUDO_KEEPER_PID
  fi
}

# Exit handler - ensures cleanup happens on any exit
exit_handler() {
  local exit_code=$?

  stop_sudo_keeper

  # Only run if we're exiting with an error and haven't already handled it
  if ((exit_code != 0)) && [[ $ERROR_HANDLING != "true" ]]; then
    catch_errors
  else
    stop_log_output
    show_cursor
  fi
}

# Set up traps
trap catch_errors ERR INT TERM
trap exit_handler EXIT

# Save original outputs in case we trap
save_original_outputs
