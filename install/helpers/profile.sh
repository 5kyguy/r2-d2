#!/bin/bash

R2D2_PROFILE_FILE="${HOME}/.config/r2-d2/profile"

r2d2_profile() {
  local p
  p=$(<"${R2D2_PROFILE_FILE}" 2>/dev/null) || p=desktop
  case "$p" in
    server) echo server ;;
    *) echo desktop ;;
  esac
}

r2d2_is_server() {
  [[ $(r2d2_profile) == server ]]
}

r2d2_config_dir() {
  local root="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
  if r2d2_is_server; then
    echo "$root/config-server"
  else
    echo "$root/config"
  fi
}

r2d2_read_package_file() {
  grep -v '^#' "$1" | grep -v '^$'
}

r2d2_core_packages() {
  local root="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
  r2d2_read_package_file "$root/install/r2-d2-core.packages"
}

r2d2_desktop_packages() {
  local root="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
  r2d2_read_package_file "$root/install/r2-d2-desktop.packages"
}

r2d2_all_packages() {
  r2d2_core_packages
  if ! r2d2_is_server; then
    r2d2_desktop_packages
  fi
}

r2d2_aur_packages() {
  local root="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
  local file

  for file in "$root/install/r2-d2-core.aur.packages" "$root/install/r2-d2-desktop.aur.packages"; do
    if [[ $file == *desktop* ]] && r2d2_is_server; then
      continue
    fi
    if [[ -f $file ]]; then
      r2d2_read_package_file "$file"
    fi
  done
}

r2d2_skip_if_server() {
  r2d2_is_server && exit 0
}