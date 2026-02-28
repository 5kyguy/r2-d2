# Installed Apps & Menu-Installable Apps

This document lists everything installed during the Omarchy install process and everything that can be installed from the **Install** menu (Super+Alt+Space → Install). Use it to decide what to treat as **defaults** (installed by default) vs **optionals** (install from menu or optional step).

---

## omarchy-keyring vs default keyring

**Default keyring:** Arch Linux uses **archlinux-keyring**. It ships with the `base` (and `base-devel`) package and contains the PGP keys used by pacman to verify packages from the official Arch repositories (core, extra, community).

**Do you need omarchy-keyring?** This install uses the **Omarchy repo** for packages, so **omarchy-keyring is kept** (and the key is imported in `install/preflight/pacman.sh`). If you were to use only Arch official repositories, you could rely on `archlinux-keyring` alone.

---

## 1. Install process – what gets installed

### 1.1 Preflight (`install/preflight/`)

| Source | What |
| ------ | ---- |
| `preflight/pacman.sh` | **base-devel** (build tools), **omarchy-keyring**; then full system upgrade (`pacman -Syyuu`) |
| — | All packages (including former system/base list) are in **`install/omarchy-base.packages`** (single file). |

### 1.2 Packaging – base packages (`install/packaging/base.sh`)

All packages from **`install/omarchy-base.packages`** are installed (one per line, comments and empty lines skipped). This single file includes the former system/base set (base, base-devel, linux, pipewire, snapper, limine, etc.) and desktop/app packages. **Default browser:** Brave. **Browsers installed:** Brave, Chromium, Helium (AUR). Webapps are created using Helium when available.

#### Full pacman list (omarchy-base.packages)

| Package | Category / purpose |
| ------- | ------------------ |
| alacritty | Terminal (default) |
| alsa-utils | Audio |
| amd-ucode | CPU microcode (AMD) |
| avahi | Network discovery |
| bash-completion | Shell |
| bat | CLI pager |
| bluetui | Bluetooth TUI |
| bolt | Thunderbolt |
| brightnessctl | Display brightness |
| btop | System monitor TUI |
| brave-browser | Browser (default) |
| chromium | Browser |
| clang | Compiler |
| cups, cups-browsed, cups-filters, cups-pdf | Printing |
| docker, docker-buildx, docker-compose | Containers |
| dust | Disk usage CLI |
| evince | PDF viewer |
| exfatprogs | exFAT filesystem |
| expac | Pacman utility |
| eza | ls replacement |
| fastfetch | System info |
| fd | Find replacement |
| ffmpegthumbnailer | Video thumbnails |
| fontconfig | Fonts |
| fzf | Fuzzy finder |
| github-cli | GitHub CLI |
| gnome-calculator | Calculator |
| gnome-keyring | Secrets |
| gnome-themes-extra | GTK themes |
| grim | Screenshot (Wayland) |
| gpu-screen-recorder | Screen recording |
| gum | CLI prompts (install UI) |
| gvfs-mtp, gvfs-nfs, gvfs-smb | GVfs backends |
| hypridle, hyprland, hyprland-guiutils, hyprland-preview-share-picker | Compositor |
| hyprlock | Lock screen |
| hyprpicker | Color picker |
| hyprsunset | Night light |
| imagemagick | Image tools |
| impala | Wi‑Fi TUI |
| inetutils | Network utils |
| inxi | System info |
| iwd | Wi‑Fi daemon |
| jq | JSON processor |
| kdenlive | Video editor |
| kernel-modules-hook | DKMS hook |
| kvantum-qt5 | Qt5 theme |
| lazydocker | Docker TUI |
| lazygit | Git TUI |
| less | Pager |
| libsecret | Secrets (e.g. Chromium) |
| libyaml | YAML |
| libqalculate | Calculator lib |
| llvm | Compiler |
| localsend | File sharing |
| luarocks | Lua packages |
| mako | Notifications |
| man-db | Man pages |
| mariadb-libs | MySQL client libs |
| mise | Runtime/version manager |
| vlc | Video player |
| nautilus, nautilus-python | File manager |
| gnome-disk-utility | Disks |
| noto-fonts, noto-fonts-emoji | Fonts |
| nss-mdns | mDNS |
| nvim | Editor |
| obs-studio | Screen capture/streaming |
| omarchy-nvim | Neovim config |
| omarchy-walker | App launcher (Walker) |
| pamixer | Audio volume |
| pinta | Image editor |
| playerctl | Media control |
| plocate | Locate |
| plymouth | Boot splash |
| polkit-gnome | Polkit agent |
| postgresql-libs | PostgreSQL client libs |
| power-profiles-daemon | Power profiles |
| python-gobject | Python/GTK |
| python-poetry-core | Python packaging |
| python-terminaltexteffects | Terminal effects |
| qt5-wayland | Qt5 Wayland |
| ripgrep | Search |
| rust | Rust toolchain |
| satty | Screenshot/annotate |
| sddm | Display manager |
| slurp | Region select (Wayland) |
| starship | Shell prompt |
| sushi | File preview (Nautilus) |
| swaybg | Wallpaper |
| swayosd | OSD (volume/brightness) |
| system-config-printer | Printer config |
| tldr | CLI help |
| tree-sitter-cli | Parser generator |
| tmux | Terminal multiplexer |
| ttf-cascadia-mono-nerd | Nerd font |
| tzupdate | Timezone update |
| ufw, ufw-docker | Firewall |
| unzip | Archive |
| usage | Resource usage |
| uwsm | Session/window rules |
| steam | Gaming |
| waybar | Top bar |
| whois | WHOIS |
| wireless-regdb | Wireless regs |
| wiremix | Audio mixer TUI |
| wireplumber | Audio (Pipewire session) |
| wl-clipboard | Clipboard (Wayland) |
| woff2-font-awesome | Icons font |
| xdg-desktop-portal-gtk | Portals |
| xdg-desktop-portal-hyprland | Portals |
| xdg-terminal-exec | Terminal dispatcher |
| xmlstarlet | XML |
| yaru-icon-theme | Icons |
| yay | AUR helper |
| zoxide | cd replacement |

**Total:** One combined list in `install/omarchy-base.packages` (former base + former omarchy-other.packages); includes brave-browser, steam, and system/base packages.

### 1.3 Packaging – AUR and preinstalled optionals

| Script | What |
| ------ | ---- |
| `packaging/aur.sh` | **AUR:** helium-browser-bin (webapps), cursor-bin (editor), pear-desktop. |
| `packaging/dev-runtimes.sh` | **Go** and **Node.js** via mise (omarchy-install-dev-env go/node). |
| `packaging/voxtype.sh` | **Dictation:** Voxtype + model and systemd (non-interactive). |

### 1.4 Packaging – other steps

| Script | What |
| ------ | ---- |
| `packaging/fonts.sh` | Copies `omarchy.ttf` to `~/.local/share/fonts`, runs `fc-cache` (no pacman). |
| `packaging/nvim.sh` | Runs **omarchy-nvim-setup** (LazyVim + themes; no extra pacman). |
| `packaging/icons.sh` | Copies bundled PNG icons to `~/.local/share/applications/icons` (no pacman). |
| `packaging/webapps.sh` | **Web apps (Helium when available):** YouTube, X (twitter.com). |
| `packaging/tuis.sh` | **TUI shortcuts:** "Disk Usage" (dust), "Docker" (lazydocker). |

### 1.5 Config – conditional packages

| Script | Condition | Packages |
| ------ | --------- | -------- |
| `config/hardware/vulkan.sh` | AMD GPU detected (lspci VGA/Display) | **vulkan-radeon** |

### 1.6 Login

| Script | What |
| ------ | ---- |
| `login/limine-snapper.sh` | If `limine` is present: **limine-snapper-sync**, **limine-mkinitcpio-hook** (and mkinitcpio/snapper config). |

### 1.7 Helpers (used during install)

| Where | Package |
| ----- | ------- |
| `install/helpers/presentation.sh` | **gum** (if not already installed). |

### 1.8 boot.sh (curl install — no ISO)

| What |
| ---- |
| **git** (then clone repo and run `install.sh`). Used for install, update, and repair from a running Arch system; this project does not ship an ISO. |

---

## 2. Install menu – what can be installed from the menu

Everything below is **optional** from the menu (Install → …). No pacman package is added by the menu unless the user picks an option.

### 2.1 Install → Package

- **omarchy-pkg-install**: user picks any package from `pacman -Slq` (official repos). No fixed list.

### 2.2 Install → AUR

- **omarchy-pkg-aur-install**: user picks any package from AUR (`yay -Slqa`). No fixed list.

### 2.3 Install → Web App

- **omarchy-webapp-install**: user runs webapp installer (any URL). Default install already adds YouTube and X.

### 2.4 Install → TUI

- **omarchy-tui-install**: user defines a TUI shortcut (name, command, float/tile, icon). Default install already adds "Disk Usage" and "Docker".

### 2.5 Install → Style

| Option | What |
| ------ | ---- |
| Theme | **omarchy-theme-install** (themes from repo/config). |
| Background | **omarchy-theme-bg-install** (user picks background dir). |

### 2.7 Install → Development

| Option | How | Pacman / other |
| ------ | --- | --------------- |
| Docker DB | **omarchy-install-docker-dbs** | Docker containers only: MySQL, PostgreSQL, Redis, MongoDB, ScyllaDB. |
| JavaScript → Node.js | omarchy-install-dev-env node | **mise** (global node). |
| JavaScript → Bun | omarchy-install-dev-env bun | **mise** (bun). |
| JavaScript → Deno | omarchy-install-dev-env deno | **mise** (deno). |
| Go | omarchy-install-dev-env go | **mise** (go). |
| Python | omarchy-install-dev-env python | **mise** (python), **uv** (curl script). |
| Elixir | omarchy-install-dev-env elixir | **mise** (erlang, elixir), mix local.hex. |
| Zig | omarchy-install-dev-env zig | **mise** (zig, zls). |
| Rust | omarchy-install-dev-env rust | **rustup** (curl script). |

*Java, .NET, OCaml, Clojure, Scala, Phoenix removed from menu (not implemented in omarchy-install-dev-env).*

### 2.8 Install → Editor

| Option | Package(s) | Source |
| ------ | ---------- | ------ |
| VSCode | **visual-studio-code-bin** | omarchy-install-vscode (AUR via yay if needed). |
| Zed | **zed** | install_and_launch → omarchy-pkg-add. |

(Cursor is preinstalled via packaging/aur.sh.)

### 2.9 Install → Terminal

| Option | Package | Note |
| ------ | ------- | ---- |
| Alacritty | **alacritty** | Already in base; sets as default terminal for Omarchy. |
| Ghostty | **ghostty** | Sets as default terminal for Omarchy. |

### 2.10 Install → AI

(Dictation/Voxtype is preinstalled via packaging/voxtype.sh.)

| Option | Package (or AUR) |
| ------ | ----------------- |
| Dictation | **omarchy-voxtype-install** (no pacman list in repo). |
| Claude Code | **claude-code** (AUR). |
| Codex | **openai-codex** (AUR). |
| Gemini CLI | **gemini-cli** (AUR). |
| Copilot CLI | **github-copilot-cli** (AUR). |
| Cursor CLI | **cursor-cli** (AUR). |
| LM Studio | **lmstudio** (AUR). |
| Ollama | **ollama** or **ollama-rocm** (if ROCm). |
| Crush | **crush-bin** (AUR). |

### 2.11 Install → Gaming

| Option | What |
| ------ | ---- |
| Steam | **steam** (pacman) via omarchy-install-steam. |
| RetroArch [AUR] | **retroarch**, **retroarch-assets**, **libretro**, **libretro-fbneo** (AUR). |
| Minecraft | **minecraft-launcher** (pacman). |
| Xbox Controller [AUR] | **linux-headers**, **xpadneo-dkms** (AUR) via omarchy-install-xbox-controllers. |

---

## 3. Suggested defaults vs optionals

Below is a **suggested** split. “Default” = install during main install; “Optional” = remove from base and make installable from menu or a separate optional step.

### 3.1 Keep as defaults (core desktop and workflow)

- **Compositor / session:** hyprland, hypridle, hyprlock, hyprpicker, hyprsunset, hyprland-guiutils, hyprland-preview-share-picker, swaybg, swayosd, waybar, uwsm, sddm, plymouth  
- **Shell / CLI:** bash-completion, bat, eza, fd, fzf, less, ripgrep, starship, tmux, zoxide, tldr  
- **Secrets / session:** gnome-keyring, polkit-gnome, libsecret  
- **Audio:** wireplumber, pamixer, wiremix  
- **Network:** iwd, avahi, nss-mdns  
- **Fonts:** fontconfig, noto-fonts, noto-fonts-emoji, ttf-cascadia-mono-nerd  
- **System:** power-profiles-daemon, bolt, kernel-modules-hook  
- **Portals / XDG:** xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland, xdg-terminal-exec  
- **Install / config:** gum, yay, expac  
- **App launcher:** omarchy-walker  
- **Notifications:** mako  
- **Basics:** grim, slurp, wl-clipboard, imagemagick  
- **Terminal (one default):** alacritty  
- **Browser:** Brave (default), Chromium (backup; no Google/Chromium account setup — `omarchy-refresh-chromium` only refreshes config), Helium (webapps)  
- **File manager:** nautilus, nautilus-python, gvfs-*, sushi  
- **Editor (CLI):** nvim, omarchy-nvim  
- **Version manager:** mise  
- **Firewall:** ufw, ufw-docker (if keeping Docker default)  
- **Optional but small:** brightnessctl, inetutils, plocate, whois, tzupdate  

### 3.2 Good candidates to move to optionals

- **Media / creative:** kdenlive, obs-studio, pinta, vlc, evince, eog, gnome-calculator, gnome-disk-utility  
- **Containers / dev DBs:** docker, docker-buildx, docker-compose, lazydocker (TUI can stay as optional menu install)  
- **Sharing:** localsend  
- **Extra terminals:** (if you make one terminal default) — keep one in base, install others from menu (already possible).  
- **Heavy dev:** rust, clang, llvm (if not targeting dev-by-default users).  
- **Printing:** cups, cups-browsed, cups-filters, cups-pdf, system-config-printer (optional for many users).  
- **Misc:** bluetui (if Bluetooth is optional), impala (if Wi‑Fi TUI is optional), btop, inxi, fastfetch, python-terminaltexteffects, libqalculate  

### 3.3 Optional / conditional (already or easy to make optional)

- **vulkan-radeon** – already conditional (AMD GPU).  
- **limine-snapper-sync**, **limine-mkinitcpio-hook** – already only when limine present.  
- **Steam, Cursor, Voxtype, Go, Node, pear-desktop** – preinstalled; Steam also in base packages.  
- **RetroArch, Minecraft, Xbox** – menu-only.  
- **VSCode, Zed** – menu-only (Cursor preinstalled).  
- **Node/Bun/Deno, Go, Python, Elixir, Rust, Zig** – Go and Node preinstalled; others menu-only (mise/rustup).  
- **Web apps** – YouTube and X by default (via Helium when available); rest from menu.  
- **TUIs** – Disk Usage and Docker by default; rest from menu.  

---

## 4. Summary counts

- **Base packages (omarchy-base.packages):** 126 packages.  
- **Preflight:** base-devel, omarchy-keyring (+ full upgrade). **Single package file:** `install/omarchy-base.packages` (includes former omarchy-other.packages). **Preinstalled from menu:** Go, Node (mise), Cursor, Voxtype, Steam, pear-desktop (AUR); Brave + Helium + Chromium; webapps use Helium.  
- **Conditional:** vulkan-radeon (AMD), limine-snapper-sync + limine-mkinitcpio-hook (if limine).  
- **Default web apps:** 2 (YouTube, X).  
- **Default TUI shortcuts:** 2 (Disk Usage, Docker).  
- **Menu-installable:** Package (any), AUR (any), Web App (any), TUI (any), Style (theme/background), Development (Docker DB + Node/Bun/Deno, Go, Python, Elixir, Zig, Rust), Editor (VSCode, Zed), Terminal (Alacritty, Ghostty), AI (many), Gaming (Steam, RetroArch, Minecraft, Xbox). *Service (Chromium Account), Windows VM, Preinstalls remove, and unsupported dev runtimes (Java, .NET, OCaml, Clojure, Scala, Phoenix) removed from menu (scripts missing or not implemented).*  

Use this list to adjust `install/omarchy-base.packages` and menu entries when moving items between defaults and optionals.
