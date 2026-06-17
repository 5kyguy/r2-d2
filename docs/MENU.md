# Menu and keybindings

The **R2-D2 menu** is implemented by `bin/r2-d2-menu`. Open it with **Super + Alt + Space** or by clicking the R2-D2 icon in Waybar.

Jump to a submenu directly: `r2-d2-menu <submenu>`, e.g. `r2-d2-menu install`, `r2-d2-menu system`, `r2-d2-menu restart`, `r2-d2-menu share`, `r2-d2-menu screenrecord`, `r2-d2-menu power`, `r2-d2-menu toggle`, `r2-d2-menu capture`, `r2-d2-menu webcam`. The Waybar battery icon opens the Power profile submenu (`r2-d2-menu power`).

---

## Main menu

**Trigger → Setup → Restart → Install → Update → Remove → About → System**

| Entry | Action |
| ----- | ------ |
| **Trigger** | Toggle, Screenshot, Screenrecord, Share |
| **Setup** | Power profile, Audio, Wifi, Bluetooth, System sleep, DNS, Security, Dictation, Fix webcam (AMD), Reset sudo |
| **Restart** | Restart Waybar, Walker, Mako, Hypridle, Hyprsunset, SwayOSD, Pipewire, Terminal, Tmux, Wifi, Bluetooth, Hyprctl |
| **Install** | See [Install submenu](#install-submenu) |
| **Update** | R2-D2, Config, System packages, Flatpaks & AppImages, Keyring, Firmware, Webcam drivers, Password, Timezone, Time, Plocate DB, Settings, Reinstall |
| **Remove** | See [Remove submenu](#remove-submenu) |
| **About** | About / branding |
| **System** | Screensaver, Lock, Suspend, Hibernate, Logout, Restart, Shutdown |

### Trigger submenu

| Entry | Action |
| ----- | ------ |
| **Toggle** | Top bar, Display, Mirror, Notifications, Idle, Layout, Gaps, Ratio, Scaling, Screensaver |
| **Screenshot** | `r2-d2-cmd-screenshot` |
| **Screenrecord** | Screenrecord options (audio / webcam) |
| **Share** | Clipboard, file, or folder |

---

## Install submenu

| Entry | What |
| ----- | ---- |
| **Package** | Install from official repos (`r2-d2-pkg-install`) |
| **AUR** | Install from AUR (`r2-d2-pkg-aur-install`) |
| **Web App** | Create a web app shortcut (`r2-d2-webapp-install`) |
| **TUI** | Add a TUI shortcut (`r2-d2-tui-install`) |
| **AppImage** | Install an AppImage (`r2-d2-appimage-install`) |
| **Development** | Docker DB, Node.js, Go, Python, Rust |
| **Editor** | VS Code, T3 Code (`r2-d2-install-editor`) |
| **Dictation (Voxtype)** | Install Voxtype + model + systemd service |
| **Gaming** | Steam and Xbox controllers |
| **Dropbox** | Install Dropbox |
| **Tailscale** | Install Tailscale |

Change wallpaper via **Super + Ctrl + Space** (Walker background selector). Accent colors update immediately from the selected image.

---

## Remove submenu

| Entry | What |
| ----- | ---- |
| **Package** | Remove packages (`r2-d2-pkg-remove`) |
| **Web App** | Remove one web app |
| **Web Apps (all)** | Remove all web apps |
| **TUI** | Remove one TUI shortcut |
| **TUI (all)** | Remove all TUI shortcuts |
| **Development** | Remove Node.js, Go, Python, Rust |
| **Dictation** | Remove Voxtype |
| **Fingerprint** | Remove fingerprint setup |
| **Fido2** | Remove Fido2 setup |
| **Drop package (by name)** | `r2-d2-pkg-drop` |

---

## Hyprland keybindings

Bindings live under `~/.config/hypr/bindings/` (override in `bindings.conf`).

**Caps Lock ↔ Left Super:** keyd swaps these keys system-wide (`default/keyd/default.conf`). Hyprland **Super** bindings use the **Caps Lock** key; the physical **Left Win** key acts as Caps Lock.

### Menus and Walker

| Keybinding | Action |
| ---------- | ------ |
| **Super + Space** | App launcher (Walker) |
| **Super + Alt + Space** | R2-D2 menu |
| **Super + Escape** | System menu (lock, suspend, reboot, etc.) |
| **XF86PowerOff** | System menu |
| **Super + Ctrl + Space** | Background selector (wallpaper + accent theme) |
| **Super + K** | Keybindings browser |
| **Super + Ctrl + E** | Emoji picker (Walker symbols) |
| **Super + Ctrl + V** | Clipboard manager |

### Apps (Super + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Enter** | Terminal |
| **Super + B** | Browser |
| **Super + Alt + B** | Browser (private) |
| **Super + I** | Cursor |
| **Super + H** | Helium |
| **Super + Y** | YouTube |
| **Super + C / V / X** | Copy / paste / cut |

### Apps (Super + Ctrl + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Ctrl + N** | Nautilus |
| **Super + Ctrl + W** | WhatsApp |
| **Super + Ctrl + X** | X |
| **Super + Ctrl + G** | Steam |

### System settings (Super + Shift + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Shift + B** | Bluetooth controls |
| **Super + Shift + W** | Wifi controls |
| **Super + Shift + A** | Audio controls |
| **Super + Shift + I** | Activity (btop) |
| **Super + Shift + S** | Screenshot |
| **Super + Shift + T** | Toggle top bar (Waybar) |
| **Super + Shift + D** | Toggle device display |
| **Super + Shift + M** | Toggle display mirror |
| **Super + Shift + N** | Toggle notification silencing |
| **Super + Shift + P** | Power profile |
| **Super + Shift + L** | Monitor layout (external left) |

### Tiling and workspaces

| Keybinding | Action |
| ---------- | ------ |
| **Super + T** | Toggle floating/tiling |
| **Super + F** | Fullscreen |
| **Super + Ctrl + F** | Tiled fullscreen |
| **Super + Alt + F** | Full width |
| **Super + O** | Pop window (float & pin) |
| **Super + Arrow** | Move window focus |
| **Super + W** | Close window |
| **Super + S** | Toggle scratchpad |
| **Super + Alt + S** | Move window to scratchpad |
| **Super + 1..0** | Switch workspace |
| **Super + Shift + 1..0** | Move window to workspace |
| **Super + Tab / Shift+Tab** | Next / previous workspace |
| **Super + Ctrl + Tab** | Former workspace |
| **Super + mouse** | Move/resize window; scroll changes workspace |
| **Ctrl + Alt + Delete** | Close all windows |

### Captures and media

| Keybinding | Action |
| ---------- | ------ |
| **Print** | Screenshot |
| **Alt + Print** | Screenrecord menu |
| **XF86Audio\*** / **XF86MonBrightness\*** | Volume, mic, display brightness (see `media.conf`) |
| **Super + XF86AudioMute** | Switch audio output |

Layout, gaps, ratio, scaling, idle, and screensaver toggles live in **Trigger → Toggle** (no dedicated keybindings). **Share** is menu-only (**Trigger → Share**). Nightlight, dictation, zoom, per-window transparency, and Mako dismiss shortcuts were removed from the default binding set.

---

## Direct submenu shortcuts

- `r2-d2-menu trigger` — Trigger menu
- `r2-d2-menu toggle` — Toggle submenu
- `r2-d2-menu capture` — Screenshot + Screenrecord
- `r2-d2-menu install` — Install menu
- `r2-d2-menu update` — Update menu
- `r2-d2-menu remove` — Remove menu
- `r2-d2-menu system` — System (lock, suspend, reboot, etc.)
- `r2-d2-menu restart` — Restart services
- `r2-d2-menu share` — Share (clipboard/file/folder)
- `r2-d2-menu screenrecord` — Screenrecord menu
- `r2-d2-menu power` — Power profile (also Waybar battery icon)
- `r2-d2-menu setup` — Setup menu
- `r2-d2-menu webcam` — Rebuild AMD ISP4 webcam drivers
