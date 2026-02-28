# Menu (Omarchy Menu)

The **Omarchy menu** is launched with **Super + Alt + Space** (or via the Waybar launcher icon). It can also be opened to a specific submenu: `omarchy-menu <submenu>`, e.g. `omarchy-menu power`, `omarchy-menu install`, `omarchy-menu theme`.

---

## Main menu

| Entry | Action |
| ----- | ------ |
| **Apps** | App launcher (Walker) — same as Super + Space |
| **Learn** | Keybindings, Omarchy manual, Hyprland, Arch, Neovim, Bash (links) |
| **Trigger** | Capture (screenshot, screenrecord, color), Share (clipboard/file/folder), Toggle (screensaver, nightlight, idle lock, top bar) |
| **Style** | Theme, Background, Hyprland look, Screensaver, About (config links) |
| **Setup** | Audio, Wifi, Bluetooth, Power profile, System sleep, Monitors, Keybindings, Input, DNS, Security (Fingerprint, Fido2), Config (defaults, Hyprland, Hypridle, Hyprlock, etc.) |
| **Install** | See [Install submenu](#install-submenu) below |
| **Remove** | See [Remove submenu](#remove-submenu) below |
| **Update** | Omarchy, Config, Extra themes, Restart (Hypridle, Hyprsunset, Swayosd, Walker, Waybar), Hardware (Audio, Wi‑Fi, Bluetooth), Firmware, Password (drive/user), Timezone, Time |
| **About** | About / branding |
| **System** | Screensaver, Lock, Suspend, Hibernate, Logout, Restart, Shutdown |

---

## Install submenu

| Entry | What |
| ----- | ---- |
| **Package** | Install from official repos (`omarchy-pkg-install` — fzf picker). |
| **AUR** | Install from AUR (`omarchy-pkg-aur-install`). |
| **Web App** | Create a web app shortcut (`omarchy-webapp-install`). Default install adds YouTube and X (via Helium when available). |
| **TUI** | Add a TUI shortcut (`omarchy-tui-install`). Default install adds Disk Usage and Docker. |
| **Style** | Theme install, Background install. |
| **Development** | Docker DB (containers), JavaScript (Node/Bun/Deno), Go, Python, Elixir, Zig, Rust. *Go and Node are preinstalled.* |
| **Editor** | VSCode, Zed. *Cursor is preinstalled.* |
| **Terminal** | Alacritty, Ghostty (set as default for Omarchy). |
| **AI** | Dictation (Voxtype; *preinstalled*), Claude Code, Codex, Gemini CLI, Copilot CLI, Cursor CLI, LM Studio, Ollama, Crush. |
| **Gaming** | Steam (*also in base packages*), RetroArch [AUR], Minecraft, Xbox Controller [AUR]. |

*Removed from menu (scripts missing or not implemented):* Service (Chromium Account), Windows VM; Java, .NET, OCaml, Clojure, Scala, Phoenix under Development; Preinstalls and Windows under Remove.

---

## Remove submenu

| Entry | What |
| ----- | ---- |
| **Package** | Remove packages (`omarchy-pkg-remove` — fzf picker). |
| **Web App** | Remove web apps (`omarchy-webapp-remove`). |
| **TUI** | Remove TUI shortcuts (`omarchy-tui-remove`). |
| **Development** | Remove runtimes: JavaScript (Node/Bun/Deno), Go, Python, Elixir, Zig, Rust. |
| **Dictation** | Remove Voxtype (`omarchy-voxtype-remove`). |
| **Theme** | Remove themes (`omarchy-theme-remove`). |
| **Fingerprint** | Remove fingerprint setup. |
| **Fido2** | Remove Fido2 setup. |

---

## Direct submenu shortcuts

You can jump straight to a submenu (and exit after one action if desired):

- `omarchy-menu power` — Power profile / System menu
- `omarchy-menu install` — Install menu
- `omarchy-menu theme` — Theme picker
- `omarchy-menu background` — Background picker
- `omarchy-menu share` — Share (clipboard/file/folder)
- `omarchy-menu capture` — Capture menu
- `omarchy-menu system` — System (lock, suspend, reboot, etc.)

User overrides and extra menu entries can be added in `~/.config/omarchy/extensions/menu.sh` (sourced at the end of `bin/omarchy-menu`).
