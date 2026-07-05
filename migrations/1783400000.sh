#!/bin/bash

# Add Alt+Enter / Alt+Shift+Enter tmux pane-split bindings on existing installs.
# Port of omarchy 2f56b525 (final form of the M-Enter migration).

TMUX_CONF="$HOME/.config/tmux/tmux.conf"

if [[ ! -f $TMUX_CONF ]]; then
  exit 0
fi

# Idempotent: only append if neither binding is present.
if ! grep -q 'bind -n M-Enter split-window' "$TMUX_CONF"; then
  cat >>"$TMUX_CONF" <<'EOF'

# Alt+Enter / Alt+Shift+Enter split without needing the prefix.
bind -n M-Enter split-window -v -c "#{pane_current_path}"
bind -n M-S-Enter split-window -h -c "#{pane_current_path}"
EOF
  echo "Added Alt+Enter / Alt+Shift+Enter pane splits to $TMUX_CONF"
fi

r2-d2-restart-tmux
