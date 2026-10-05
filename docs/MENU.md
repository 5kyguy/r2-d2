# Menu and keybindings

The **R2-D2 menu** is the command bar opened on the menu tree (`bin/r2-d2-menu` runs the actions). **Super + Alt + Space**, the bar logo, and `r2-d2-menu` show the top level. Type to search every entry. Enter opens a category or runs its action. Backspace on an empty query goes up one level, and closes once it is back at the level you opened. **Super + Space** stays the app and answer bar: a matching app is selected, and a menu action that matches sits below that, above Google and, when K-2SO is installed, Ask K-2SO.

`r2-d2-menu <submenu>` opens that level (`install`, `system`, `screenrecord`, `setup`, and the rest). `r2-d2-menu doctor` and `r2-d2-menu webcam` still run those actions directly. Audio, Wi-Fi, Bluetooth, and power open from the top bar. Picking a webcam or a default app still uses Walker, because those lists are built when you choose them.

---

## Main menu

**Apps → Trigger → Setup → Restart → Install → Update → Remove → About → System**

| Entry | Action |
| ----- | ------ |
| **Apps** | App search in the command bar |
| **Trigger** | Toggle, Screenshot, Screenrecord, Share |
| **Setup** | Text size, Default apps, Monitors, System sleep, DNS, Security, Dictation, Fix webcam (AMD), Dependencies, Reset sudo |
| **Restart** | Restart Shell, Walker, Pipewire, Terminal, Wifi, Bluetooth, Hyprctl |
| **Install** | See [Install submenu](#install-submenu) |
| **Update** | R2-D2 (full), Config, Packages (pacman, AUR, Flatpaks, AppImages, firmware), Webcam, Password, Timezone & Time, Reinstall |
| **Remove** | See [Remove submenu](#remove-submenu) |
| **About** | About / branding |
| **System** | Lock, Screensaver, Suspend, Hibernate, Logout, Restart, Shutdown |

### Setup submenu

| Entry | Action |
| ----- | ------ |
| **Text size** | 10, 12, 14, 16, or a custom size |
| **Default apps** | Choose the installed handler for text, PDF, images, or video |
| **Monitors** | Save or apply a docked layout and a laptop layout |
| **System sleep** | Suspend, hibernate, and on a laptop the lid-close policy |
| **DNS** | DNS presets |
| **Security** | Fingerprint, Fido2, Sudoless Docker |
| **Dictation** | Config, model, status |
| **Fix webcam (AMD)** | Rebuild AMD ISP4 webcam drivers |
| **Dependencies** | Report missing base and AUR packages (`r2-d2-cmd-doctor`). Does not install them |
| **Reset sudo** | Recover from a sudo lockout |

Lid close is **Suspend**, **Lock**, or **Keep running**. Keep running leaves the machine on with the lid shut. An external screen still uses clamshell and does not suspend. Until a policy is chosen, closing the lid locks when no external screen is connected.

Monitor layouts are manual. **Apply** is what login and a desktop reload restore, when every saved output is still connected. With no saved layout, login still places the external screen on the left.

### Trigger submenu

| Entry | Action |
| ----- | ------ |
| **Toggle** | Top bar, Display, Mirror, Notifications, Idle, Layout, Scaling, Screensaver, Crash capture |
| **Screenshot** | `r2-d2-cmd-screenshot` |
| **Screenrecord** | Stop, or record with no audio, desktop audio, a microphone, or a webcam |
| **Share** | Clipboard, file, or folder |

---

## Install submenu

| Entry | What |
| ----- | ---- |
| **Package** | Install from official repos (`r2-d2-pkg-install`) |
| **AUR** | Install from AUR (`r2-d2-pkg-aur-install`) |
| **Web App** | Create a web app shortcut (`r2-d2-webapp-install`) |
| **AppImage** | Install an AppImage (`r2-d2-appimage-install`) |
| **Development** | Node.js, Go, Python, Rust |
| **Editor** | Cursor, VS Code, T3 Code, OpenCode, Hermes (`r2-d2-install-editor`). Cursor is installed by default. |
| **K-2SO (companion)** | Install K-2SO background agent + `r2d2-mcp` (`r2-d2-install-k2so`) |
| **Gaming** | Steam and Xbox controllers |
| **Dropbox** | Install Dropbox |
| **Tailscale** | Install Tailscale |

Change wallpaper via **Super + Ctrl + Space** (Walker background selector). Accent colors update immediately from the selected image.

---

## Remove submenu

Package and Drop package are always listed. Every other entry appears only when that thing is installed. Development and Editor open a second list of only the installed runtimes or editors.

| Entry | What |
| ----- | ---- |
| **Package** | Remove packages (`r2-d2-pkg-remove`) |
| **Drop package (by name)** | `r2-d2-pkg-drop` |
| **Web App** | Remove one web app |
| **Web Apps (all)** | Remove all web apps |
| **Development** | Remove installed Node.js, Go, Python, or Rust |
| **Editor** | Remove installed Cursor, VS Code, T3 Code, OpenCode, or Hermes (`r2-d2-remove-editor`) |
| **Dictation** | Remove Voxtype |
| **Fingerprint** | Remove fingerprint setup |
| **Fido2** | Remove Fido2 setup |
| **Sudoless Docker** | Turn off sudoless Docker, when it is enabled |

---

## Hyprland keybindings

Bindings live under `~/.config/hypr/bindings/` (override in `bindings.lua`).

**Caps Lock → Super:** keyd maps Caps Lock to Super system-wide (`default/keyd/default.conf`). Hyprland **Super** bindings use the **Caps Lock** key (Left Win is also Super). Caps Lock lock state is disabled — use Shift for capitals.

### Menus and Walker

| Keybinding | Action |
| ---------- | ------ |
| **Super + Space** | Command bar |
| **Super + Alt + Space** | R2-D2 menu (command bar) |
| **Super + Escape** | System menu (lock, suspend, reboot, etc.) |
| **XF86PowerOff** | System menu |
| **Super + Ctrl + Space** | Background selector (wallpaper + accent theme) |
| **Super + K** | Keybindings browser |
| **Super + Ctrl + E** | Emoji picker (Walker symbols) |
| **Super + \\** | Clipboard history |
| **Super + A** | Ask K-2SO (text prompt) |
| **Super + Alt + A** | K-2SO voice (Voxtype) |

### Apps (Super + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Enter** | Terminal |
| **Super + B** | Browser |
| **Super + Alt + B** | Browser (private) |
| **Super + I** | Cursor |
| **Super + N** | Thunar |
| **Super + C / V / X** | Copy / paste / cut |

### Apps (Super + Ctrl + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Ctrl + Y** | YouTube |
| **Super + Ctrl + W** | WhatsApp |
| **Super + Ctrl + X** | X |
| **Super + Ctrl + G** | Steam |

### System settings (Super + Shift + letter)

| Keybinding | Action |
| ---------- | ------ |
| **Super + Shift + B** | Bluetooth panel |
| **Super + Shift + W** | Wifi panel |
| **Super + Shift + A** | Audio panel |
| **Super + Shift + I** | Activity (btop) |
| **Super + Shift + S** | Screenshot |
| **Super + Shift + T** | Toggle top bar |
| **Super + Shift + D** | Toggle device display |
| **Super + Shift + M** | Toggle display mirror |
| **Super + Shift + N** | Toggle notification silencing |
| **Super + Shift + P** | Power panel |
| **Super + Shift + L** | Monitor layout (external left) |

### Tiling and workspaces

| Keybinding | Action |
| ---------- | ------ |
| **Super + T** | Toggle floating/tiling |
| **Super + F** | Fullscreen |
| **Super + Ctrl + F** | Tiled fullscreen |
| **Super + Alt + F** | Full width |
| **Super + O** | Pop window (float & pin) |
| **Super + J** | Toggle split orientation |
| **Super + Arrow** | Move window focus |
| **Super + Minus / Equal** | Decrease / increase window width |
| **Super + Shift + Minus / Equal** | Decrease / increase window height |
| **Super + W** | Close window |
| **Super + S** | Toggle scratchpad |
| **Super + Alt + S** | Move window to scratchpad |
| **Super + 1..0** | Switch workspace |
| **Super + Shift + 1..0** | Move window to workspace |
| **Super + Shift + comma** | Move window to the previous monitor |
| **Super + Shift + period** | Move window to the next monitor |
| **Super + Page Down / Page Up** | Next / previous workspace |
| **Super + mouse** | Move/resize window; scroll changes workspace |
| **Ctrl + Alt + Delete** | Close all windows |

### Captures and media

| Keybinding | Action |
| ---------- | ------ |
| **Print** | Screenshot |
| **Alt + Print** | Screenrecord menu |
| **Super + Print** | Extract text (OCR) from the screen |
| **Super + D** | Dictate into the focused text field (hold, then release) |
| **XF86Audio\*** / **XF86MonBrightness\*** | Volume, mic, display brightness (see `bindings/media.lua`) |
| **Super + XF86AudioMute** | Switch audio output |

Layout, scaling, idle, and screensaver toggles live in **Trigger → Toggle** (no dedicated keybindings). **Share** is menu-only (**Trigger → Share**). Dictation models live in **Setup → Dictation → Model**. Nightlight, zoom, and per-window transparency shortcuts were removed from the default binding set.

---

## Direct submenu shortcuts

- `r2-d2-menu trigger` — Trigger menu
- `r2-d2-menu toggle` — Toggle submenu
- `r2-d2-menu capture` — Screenshot, Screenrecord, QR code
- `r2-d2-menu install` — Install menu
- `r2-d2-menu update` — Update menu
- `r2-d2-menu remove` — Remove menu
- `r2-d2-menu system` — System (lock, suspend, reboot, etc.)
- `r2-d2-menu restart` — Restart services
- `r2-d2-menu share` — Share (clipboard/file/folder)
- `r2-d2-menu screenrecord` — Screenrecord menu
- `r2-d2-menu setup` — Setup menu
- `r2-d2-menu lid` — Lid-close policy
- `r2-d2-menu defaults` — Default apps
- `r2-d2-menu monitors` — Saved monitor layouts
- `r2-d2-menu doctor` — Dependency check
- `r2-d2-menu webcam` — Rebuild AMD ISP4 webcam drivers
