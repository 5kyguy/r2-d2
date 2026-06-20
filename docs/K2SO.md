# K-2SO on R2-D2

K-2SO is the **brains** (background agent). R2-D2 is the **body** (`r2d2-mcp` tools, hotkeys, install).

## Install

```bash
r2-d2-install-k2so
```

Clones [k-2so](https://github.com/5kyguy/k-2so) into `$R2D2_PATH/k-2so` when missing (override with `K2SO_DIR` / `K2SO_REPO` / `K2SO_BRANCH`).

1. Builds `k2so` and links `~/.local/bin/k2so`
2. Builds `mcp/r2d2`
3. Syncs `~/.config/k2so/profile.toml` and `~/.config/opencode/opencode.json`
4. Enables `k2so.service` (user systemd)

## API key

```bash
$EDITOR ~/.config/r2-d2/k2so.env
```

Set `ZAI_API_KEY` for the Z.AI GLM Coding Plan (used by OpenCode).

## Usage

| Input | Action |
| ----- | ------ |
| **Super + A** | Text prompt → `k2so ask` |
| **Super + Shift + A** | Voice via Voxtype → `k2so ask` |
| `k2so open` | Dashboard via on-demand HTTP bridge (Unix socket daemon) |
| `k2so status` | List tasks in terminal |
| `k2so abort <id>` | Abort a queued or running task |
| `k2so open-task <id>` | Open task workspace folder |
| `k2so prune` | Remove old task workspaces |

The daemon listens on a Unix socket (`~/.local/state/k2so/k2so.sock`) — only local processes running as your user can submit tasks. There is no long-lived TCP listener.

## MCP tools

Registered in OpenCode as `r2d2_*`. Enabled tools are controlled by `config/r2-d2/mcp.toml`:

- `lock_screen`, `screenshot`, `battery_remaining`
- `toggle_nightlight`, `toggle_waybar`, `toggle_notification_silencing`
- `theme_set_background`, `theme_set_accent`, `desktop_windows`
- `open_application`, `volume_set`, `volume_toggle_mute`, `media_play_pause`, `clipboard_set`
- `system_reboot`, `system_shutdown` (require `confirm: true`)

## Bench presets

Example tasks in `config/k2so/bench-presets.json` for manual benchmarking:

```bash
r2-d2-k2so-bench-preset lock_screen
k2so bench
```

## Workspace retention

Old task workspaces are pruned with:

```bash
k2so prune
```

Defaults: 14 days / 200 tasks (see `[retention]` in `~/.config/k2so/profile.toml`).

Optional weekly timer (not enabled by default):

```ini
# ~/.config/systemd/user/k2so-prune.timer
[Unit]
Description=Weekly K-2SO workspace prune

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# ~/.config/systemd/user/k2so-prune.service
[Unit]
Description=Prune old K-2SO task workspaces

[Service]
Type=oneshot
ExecStart=%h/.local/bin/k2so prune
```

## Notifications

Task completion uses `notify-send` with the workspace path. mako action buttons (e.g. "Open report") are a possible follow-up.

## Service

```bash
systemctl --user status k2so
systemctl --user restart k2so
journalctl --user -u k2so -f
```

The unit sets `R2D2_PATH` and `PATH` so OpenCode can spawn `r2d2-mcp`.
