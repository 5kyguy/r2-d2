# K-2SO on R2-D2

K-2SO is the **brains** (background agent). R2-D2 is the **body** (`r2d2-mcp` tools, hotkeys, install).

## Install

```bash
r2-d2-install-k2so
```

1. Installs `k2so` from npm (or builds from `K2SO_DIR` when set for local dev)
2. Builds `mcp/r2d2`
3. Merges only the `mcp.r2d2` block into `~/.config/opencode/opencode.json` (does not replace an existing OpenCode setup)
4. Runs `k2so init` to register the markdown agent at `~/.config/opencode/agents/k2so.md` — **K-2SO never writes the full `opencode.json`**
5. Writes `~/.config/k2so/profile.toml` when absent
6. Enables `k2so.service` (daemon) and `k2so-dashboard.service` (persistent HTTP dashboard at `127.0.0.1:7780`)

## API key

```bash
$EDITOR ~/.config/r2-d2/zai-api-key
chmod 600 ~/.config/r2-d2/zai-api-key
```

Add your Z.AI API key as a single raw line (no `KEY=` prefix). OpenCode reads it via `{file:...}` so standalone `opencode` and the K-2SO daemon both work without exporting shell variables.

If you still have `~/.config/r2-d2/k2so.env` from an older install, `r2-d2-ensure-k2so-secrets` migrates `ZAI_API_KEY` into `zai-api-key` on the next install or migration.

## Usage

| Input | Action |
| ----- | ------ |
| **Super + A** | Text prompt (Walker) → `k2so ask` |
| **Super + Alt + A** | Voice via Voxtype → `k2so ask` |
| `k2so open` | Open dashboard in browser (persistent service at `127.0.0.1:7780`) |
| `k2so status` | List tasks in terminal |
| `k2so abort <id>` | Abort a queued or running task |
| `k2so open-task <id>` | Open task workspace folder |
| `k2so prune` | Remove old task workspaces |
| `k2so doctor` | Health check (agent file, profile, memory seeds) |
| `k2so init` | Re-run registration (idempotent) |

The daemon listens on a Unix socket (`~/.local/state/k2so/k2so.sock`) — only local processes running as your user can submit tasks. The dashboard companion (`k2so-dashboard.service`) is the only TCP listener, bound to loopback (`127.0.0.1:7780`) for browser access; disable it via `[dashboard].enabled = false` in `~/.config/k2so/profile.toml`.

## MCP tools

**R2-D2** tools are registered in OpenCode as `r2d2_*` via the `mcp.r2d2` block in your `opencode.json`. Enabled tools are controlled by `config/r2-d2/mcp.toml`:

- `lock_screen`, `screenshot`, `battery_remaining`
- `toggle_nightlight`, `toggle_waybar`, `toggle_notification_silencing`
- `theme_set_background`, `theme_set_accent`, `desktop_windows`
- `open_application`, `volume_set`, `volume_toggle_mute`, `media_play_pause`, `clipboard_set`
- `system_reboot`, `system_shutdown` (require `confirm: true`)

**K-2SO memory** tools (`k2so-memory_*`) are injected when `k2so serve` spawns OpenCode — not written into your config file.

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
