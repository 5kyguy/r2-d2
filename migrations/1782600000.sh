#!/bin/bash

echo "K-2SO install boundary: drop agent.k2so from opencode.json, register via k2so init"

user_config="${HOME}/.config/opencode/opencode.json"

if [[ -f $user_config ]] && command -v jq &>/dev/null; then
  if jq -e '.agent.k2so' "$user_config" &>/dev/null; then
    tmp="${user_config}.tmp.$$"
    jq 'del(.agent.k2so)' "$user_config" >"$tmp"
    mv "$tmp" "$user_config"
    echo "Removed agent.k2so from $user_config (markdown agent replaces it)"
  fi
fi

if command -v k2so &>/dev/null; then
  k2so init
else
  echo "k2so not on PATH — run k2so init after installing k2so" >&2
fi