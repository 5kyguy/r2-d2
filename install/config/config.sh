#!/bin/bash

# Copy over user-editable R2-D2 configs
CONFIG_DIR=$(r2d2_config_dir)

if [[ -z $CONFIG_DIR || ! -d $CONFIG_DIR ]]; then
  echo "Config directory missing: ${CONFIG_DIR:-<empty>}" >&2
  exit 1
fi

mkdir -p ~/.config

shopt -s nullglob
config_items=("$CONFIG_DIR"/*)
shopt -u nullglob

if ((${#config_items[@]} == 0)); then
  echo "No config entries found in $CONFIG_DIR" >&2
  exit 1
fi

for item in "${config_items[@]}"; do
  cp -R "$item" ~/.config/
done

# Use bashrc from config
cp ~/.config/bashrc ~/.bashrc