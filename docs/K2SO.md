# K-2SO on R2-D2

K-2SO is the **brains** (background agent). R2-D2 is the **body** (`r2d2-mcp` tools, hotkeys, install).

## Install

```bash
r2-d2-install-k2so
```

Requires the [k-2so](https://github.com/5kyguy/k-2so) repo at `$R2D2_PATH/k-2so` (nested clone or set `K2SO_DIR`).

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
|-------|--------|
| **Super + A** | Text prompt → `k2so ask` |
| **Super + Shift + A** | Voice via Voxtype → `k2so ask` |
| `k2so open` | Local dashboard at http://127.0.0.1:4178 |
| `k2so status` | List tasks in terminal |

## MCP tools

Registered in OpenCode as `r2d2_*`:

- `lock_screen`, `screenshot`, `battery_remaining`
- `toggle_nightlight`, `toggle_waybar`, `toggle_notification_silencing`
- `theme_set_background`, `desktop_windows`
- `system_reboot`, `system_shutdown` (require `confirm: true`)

## Bench presets

Example tasks in `config/k2so/bench-presets.json` for manual benchmarking:

```bash
k2so ask "$(jq -r '.[0].instruction' ~/.config/k2so/bench-presets.json)"
k2so bench
```

## Service

```bash
systemctl --user status k2so
systemctl --user restart k2so
journalctl --user -u k2so -f
```
