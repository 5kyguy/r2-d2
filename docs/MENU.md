# Menu and keybindings

The **R2-D2 menu** is implemented by `bin/r2-d2-menu`. It is launched with **Super + Alt + Space** or by clicking the R2-D2 icon in Waybar. You can open a specific submenu and exit after one action: `r2-d2-menu <submenu>`, e.g. `r2-d2-menu install`, `r2-d2-menu system`, `r2-d2-menu restart`, `r2-d2-menu share`, `r2-d2-menu screenrecord`, `r2-d2-menu power`. The Waybar battery icon opens the Power profile submenu (`r2-d2-menu power`).

---

## Main menu

The main menu offers: **Trigger**, **Setup**, **Restart**, **Install**, **Remove**, **Update**, **About**, **System**.

| Entry | Action |
| ----- | ------ |
| **Trigger** | Screenshot, Screenrecord, Share (clipboard/file/folder), Toggle (screensaver, nightlight, idle lock, top bar, device display, notification silencing) |
| **Setup** | Audio, Wifi, Bluetooth, Power profile, System sleep (enable/disable suspend/hibernate), DNS, Security (Fingerprint, Fido2), Dictation (Voxtype: config/model/status), Reset sudo (lockout) |
| **Restart** | Restart Waybar, Walker, Mako, Hypridle, Hyprsunset, SwayOSD, Pipewire, Terminal, Tmux, Wifi, Bluetooth, Hyprctl |
| **Install** | See [Install submenu](#install-submenu) |
| **Remove** | See [Remove submenu](#remove-submenu) |
| **Update** | R2-D2, System packages, Keyring, Firmware, Password (drive/user), Timezone, Time, Plocate DB, Reinstall (full / packages / configs / git) |
| **About** | About / branding |
| **System** | Screensaver, Lock, Suspend, Hibernate, Logout, Restart, Shutdown |

---

## Install submenu

| Entry | What |
| ----- | ---- |
| **Package** | Install from official repos (`r2-d2-pkg-install` — fzf picker). |
| **AUR** | Install from AUR (`r2-d2-pkg-aur-install`). |
| **Web App** | Create a web app shortcut (`r2-d2-webapp-install`). Default install adds WhatsApp, YouTube, X, Discord (via Helium when available). |
| **TUI** | Add a TUI shortcut (`r2-d2-tui-install`). Default install adds Disk Usage and Docker. |
| **AppImage** | Install an AppImage and create a launcher (`r2-d2-appimage-install`). Stores AppImages under `~/Applications`. |
| **Development** | Docker DB (containers), JavaScript (Node/Bun/Deno), Go, Python, Elixir, Zig, Rust. Go and Node are preinstalled. |
| **AI** | Claude Code, Codex, Gemini CLI, Copilot CLI, Cursor CLI, LM Studio, Ollama, Crush. |
| **Dictation (Voxtype)** | Install Voxtype + download the model + enable its systemd service (`r2-d2-voxtype-install`). |
| **Gaming** | Install Steam and Xbox controllers (runs both `r2-d2-install-steam` and `r2-d2-install-xbox-controllers`). |
| **Dropbox** | Install Dropbox (`r2-d2-install-dropbox`). |
| **Tailscale** | Install Tailscale (`r2-d2-install-tailscale`). |

Alacritty and Ghostty are installed by default; Alacritty is the default terminal (Super + Enter). To change the wallpaper, use the background selector: **Super + Ctrl + Space** (Walker menu).

---

## Remove submenu

| Entry | What |
| ----- | ---- |
| **Package** | Remove packages (`r2-d2-pkg-remove` — fzf picker). |
| **Web App** | Remove one web app (`r2-d2-webapp-remove`). |
| **Web Apps (all)** | Remove all web apps (`r2-d2-webapp-remove-all`). |
| **TUI** | Remove one TUI shortcut (`r2-d2-tui-remove`). |
| **TUI (all)** | Remove all TUI shortcuts (`r2-d2-tui-remove-all`). |
| **Development** | Remove runtimes: JavaScript (Node/Bun/Deno), Go, Python, Elixir, Zig, Rust. |
| **Dictation** | Remove Voxtype (`r2-d2-voxtype-remove`). |
| **Fingerprint** | Remove fingerprint setup. |
| **Fido2** | Remove Fido2 setup. |
| **Drop package (by name)** | Drop a package by name (`r2-d2-pkg-drop`). |

---

## Hyprland keybindings

Bindings are defined under `~/.config/hypr/bindings/` (and optional overrides in `bindings.conf`). Summary of the main ones:

### Launchers and menu

| Keybinding | Action |
| ---------- | ------ |
| **Super + Space** | App launcher (Walker) |
| **Super + Alt + Space** | R2-D2 menu |
| **Super + Escape** | System menu (lock, suspend, reboot, etc.) |
| **Super + Ctrl + Space** | Background selector |
| **Super + K** | Show keybindings (r2-d2-menu-keybindings) |
| **Super + Ctrl + E** | Emoji picker (Walker symbols) |
| **Super + Ctrl + C** | Capture menu (screenshot / screenrecord) |
| **Super + Ctrl + S** | Share menu |
| **Print** | Screenshot |
| **Alt + Print** | Screenrecord menu |

### Apps

| Keybinding | Action |
| ---------- | ------ |
| **Super + Enter** | Terminal |
| **Super + Shift + Enter** | Browser |
| **Super + Shift + B** | Browser (private: Super + Shift + Alt + B) |
| **Super + Shift + F** | File manager (cwd: Super + Alt + Shift + F) |
| **Super + Shift + N** | Editor |

### Clipboard and copy/paste

| Keybinding | Action |
| ---------- | ------ |
| **Super + C** | Copy (sends Ctrl+Insert) |
| **Super + V** | Paste (sends Shift+Insert) |
| **Super + X** | Cut |
| **Super + Ctrl + V** | Clipboard manager (Walker) |

### Toggles and controls

| Keybinding | Action |
| ---------- | ------ |
| **Super + Shift + Space** | Toggle top bar (Waybar) |
| **Super + Ctrl + I** | Toggle idle lock |
| **Super + Ctrl + N** | Toggle nightlight |
| **Super + Ctrl + L** | Lock system |
| **Super + Ctrl + X** | Toggle dictation (Voxtype) |
| **Super + Ctrl + A** | Audio controls |
| **Super + Ctrl + B** | Bluetooth controls |
| **Super + Ctrl + W** | Wifi controls |
| **Super + Ctrl + T** | Activity (btop) |
| **Super + Ctrl + Z** | Zoom in (Super + Ctrl + Alt + Z = reset zoom) |
| **Super + Backspace** | Toggle window transparency |
| **Super + Shift + Backspace** | Toggle workspace gaps |
| **Super + Ctrl + Backspace** | Toggle monitor scaling |
| **Super + Ctrl + Alt + Backspace** | Toggle single-window square aspect |

### Notifications (Mako)

| Keybinding | Action |
| ---------- | ------ |
| **Super + ,** | Dismiss last notification |
| **Super + Shift + ,** | Dismiss all |
| **Super + Ctrl + ,** | Toggle silencing |
| **Super + Alt + ,** | Invoke last / **Super + Shift + Alt + ,** Restore last |

### Media and brightness

| Keybinding | Action |
| ---------- | ------ |
| **XF86AudioRaiseVolume / LowerVolume / Mute** | Volume (Alt for 1% steps) |
| **XF86AudioMicMute** | Mute microphone |
| **XF86MonBrightnessUp / Down** | Display brightness (Alt for 1%) |
| **XF86KbdBrightnessUp / Down** | Keyboard backlight |
| **Super + XF86AudioMute** | Switch audio output |
| **XF86AudioNext / Prev / Play / Pause** | Media (playerctl) |

### Windows and workspaces (tiling)

- **Super + 1..0** — Switch to workspace 1–10
- **Super + Shift + 1..0** — Move window to workspace
- **Super + Alt + Shift + 1..0** — Move window silently to workspace
- **Super + Tab / Shift+Tab** — Next / previous workspace; **Super + Ctrl + Tab** — former workspace
- **Super + W** — Close window; **Ctrl + Alt + Delete** — Close all windows
- **Super + T** — Toggle floating/tiling; **Super + F** — Fullscreen; **Super + Ctrl + F** — Tiled fullscreen; **Super + Alt + F** — Full width
- **Super + Arrow** — Move focus; **Super + Shift + Arrow** — Swap window; **Super + Alt + Arrow** — Move into group
- **Super + S** — Toggle scratchpad; **Super + Alt + S** — Move window to scratchpad
- **Super + G** — Toggle group; **Super + O** — Pop window out (float & pin)
- **Super + J** — Toggle split; **Super + P** — Pseudo window
- **Super + -/=** — Resize window
- **Super + mouse** — Move/resize window; **Super + scroll** — Change workspace

---

## Direct submenu shortcuts

- `r2-d2-menu install` — Install menu
- `r2-d2-menu system` — System (lock, suspend, reboot, etc.)
- `r2-d2-menu restart` — Restart (Waybar, Walker, Mako, etc.)
- `r2-d2-menu share` — Share (clipboard/file/folder)
- `r2-d2-menu screenrecord` — Screenrecord menu
- `r2-d2-menu power` — Power profile (also via Waybar battery icon)
