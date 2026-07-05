# AGENTS.md

Guidance for AI agents (K-2SO, OpenCode, Claude Code, Codex, etc.) operating
on this R2-D2 installation. Read this before making changes.

## Runtime environment

- All R2-D2 binaries live under `$R2D2_PATH/bin/` (default
  `~/.local/share/r2-d2/bin`) and are prefixed `r2-d2-`. They are on `$PATH`.
- `$R2D2_PATH` points at the live repo (default `~/.local/share/r2-d2`).
- `$R2D2_INSTALL` points at `$R2D2_PATH/install` during the install pipeline.
- The Hyprland compositor auto-reloads on config save, but you MUST validate
  after editing (see below).
- The MCP server (`r2d2-mcp`) exposes `r2d2_*` tools to compatible harnesses;
  K-2SO injects its own `k2so-memory_*` tools at serve time.

## Hyprland config edits — ALWAYS validate

After ANY Hyprland config change:

1. Run `hyprctl reload`.
2. Run `hyprctl configerrors`.
3. If `hyprctl configerrors` reports errors, address them and rerun validation
   until clean, or until a real blocker is identified.

Do not leave the compositor in a broken state. The user may be working in
another session and will not see warnings you ignore.

## Use the wrappers, not raw commands

R2-D2 ships wrappers that handle pacman + AUR, the notification daemon, and
common hardware/system operations. Prefer these over raw equivalents:

| Want to... | Use | Not |
| --- | --- | --- |
| Install a package | `r2-d2-pkg-add <pkg>` | `pacman -S` |
| Install an AUR package | `r2-d2-pkg-aur-add <pkg>` | `yay -S` |
| Remove a package | `r2-d2-pkg-remove <pkg>` / `r2-d2-pkg-drop <pkg>` | `pacman -R*` |
| Send a notification | `r2-d2-notification-send` | `notify-send` |
| Take a screenshot | `r2-d2-cmd-screenshot` | `grim` |
| Run OCR on screen text | `r2-d2-capture-text-extraction` | `tesseract` |
| Toggle passwordless sudo | `r2-d2-sudo-passwordless-toggle` | editing sudoers directly |
| Reload Hyprland | `r2-d2-hyprland-reload` | `hyprctl reload` |
| Restart waybar | `r2-d2-restart-waybar` | `killall waybar` |

`r2-d2-notification-send` in particular routes through the right urgency and
adds click-action / image / glyph hints the bare `notify-send` does not. The
K-2SO task-completion notifications should always use it.

## Packages

- Add packages to `install/r2-d2-base.packages` (pacman) or
  `install/r2-d2-base.aur.packages` (AUR) for fresh installs.
- For existing installs, ship a `migrations/<unix-ts>.sh` that calls
  `r2-d2-pkg-add`. Never assume the base list re-syncs on update.
- To remove a package on existing installs, ship a migration that calls
  `r2-d2-pkg-remove` (handles dependent-package cleanup safely).

## Config structure

- Repo `config/` is synced to `~/.config/` on update via `r2-d2-update-sync-files`.
- Repo `default/` holds system-path assets (`/etc`, `/usr/share`, system-sleep
  hooks) applied via migrations or install scripts — NOT overwritten on every update.
- Repo `default/config/` holds `~/.config` support assets applied at install
  and via migrations only.
- Hyprland bindings live under `config/hypr/bindings/*.conf` (R2-D2 uses
  `.conf`, not `.lua`).

## Migrations

- One-shot scripts under `migrations/<unix-ts>.sh`, sourced by `r2-d2-migrate`.
- State tracked at `~/.local/state/r2-d2/migrations/<filename>`.
- Use `r2-d2-dev-add-migration` to mint a new timestamped migration.
- Migrations must be idempotent (guard with `[[ -f ... ]]` / `grep -q` checks)
  and use `sudo` for system paths with graceful `|| true` fallbacks where
  failure is non-fatal.

## K-2SO integration

- K-2SO is the background agent daemon (Unix socket at
  `~/.local/state/k2so/k2so.sock`). See `docs/K2SO.md`.
- It spawns OpenCode with the `k2so` agent profile (`config/k2so/profile.toml`).
- The R2-D2 MCP server is registered in OpenCode via the `mcp.r2d2` block;
  K-2SO's own memory tools are injected at serve time and are NOT written into
  `~/.config/opencode/opencode.json`.
