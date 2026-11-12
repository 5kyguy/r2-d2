# Changelog

All notable changes to **R2-D2** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

GitHub Releases for each version are published from the matching section below;
see the [Releases page](https://github.com/5kyguy/r2-d2/releases).

Versioning starts at 0.1.0 under R2-D2's own identity. The `v2`/`v3` tags in
the history are Omarchy's, inherited from the fork.

## [0.1.0] - 2026-11-12

First R2-D2 version: the desktop as it works today, daily-driven.

### The system

- **Arch Linux + Hyprland (Lua config), installed by one curl script** — no
  ISO. Fresh installs, repairs, and resets run the same pipeline;
  in-session updates sync `config/` and run one-shot `migrations/`.
- **Shell and services.** quickshell draws the bar, panels, OSD, and lock
  screen; den-den-mushi renders notification cards on a layer-shell overlay.
  Both follow the live theme.
- **Robin is the file manager and media viewer** (v0.1.0): directories,
  images, video, and audio open in it. PDFs open in Zathura, archives in File Roller.
- **K-2SO**, the background agent daemon (`k2so` on npm), runs an OpenCode
  session with `r2d2-mcp` tools and its own memory MCP; R2-D2 ships the
  hotkeys, voice ingress, and the integration doc.
- **One theme, every surface.** A single `theme.json` (palette + wallpaper)
  drives Alacritty, GTK 3/4, quickshell, den-den-mushi, walker, elephant,
  btop, and the rest through templates and live sync.
- **A wrapped desktop.** 233 `r2-d2-*` helpers cover packages (pacman +
  AUR), notifications, screenshots, OCR, theme, power, and the update flow;
  Hyprland rules and binds live in 23 Lua modules.

[0.1.0]: https://github.com/5kyguy/r2-d2/releases/tag/v0.1.0
