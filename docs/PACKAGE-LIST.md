# Package list and purposes

This document lists what is installed during the R2-D2 install and what can be installed from the **Install** menu (`r2-d2-menu install`). Use it to see defaults vs optionals and the purpose of each package.

---

## 1. Install process – what gets installed

### 1.1 Preflight (`install/preflight/`)

- **pacman.sh** — Installs **base-devel**; copies pacman.conf and mirrorlist; full sync and upgrade (`pacman -Syyuu`).
- All desktop and app packages are in **`install/r2-d2-base.packages`** (pacman) and **`install/r2-d2-base.aur.packages`** (AUR).

### 1.2 Packaging – base packages (`install/packaging/base.sh`)

- **Pacman:** All packages from **`install/r2-d2-base.packages`** are installed (see categorized list below).
- **AUR:** Packages from **`install/r2-d2-base.aur.packages`** are installed via yay (browsers, walker/elephant, limine helpers, localsend, xdg-terminal-exec, and other AUR-only deps).
- **SSH:** `openssh` is installed so the SSH server is available, but `sshd` is **not** enabled by default. Enable it manually when needed (`sudo systemctl enable --now sshd`).
- **Voxtype:** Installed by default (`voxtype-bin` plus `wtype`). Setup downloads the `small.en` model and enables the user service. Change the model from **Setup → Dictation → Model**.

### 1.3 Packaging – other steps

| Script | What |
| ------ | ---- |
| **fonts.sh** | Copies **r2-d2.ttf** and **manrope-variable.ttf** from `default/config/` to `~/.local/share/fonts`, runs `fc-cache`. |
| **icons.sh** | Copies bundled PNG icons to `~/.local/share/applications/icons`. |
| **webapps.sh** | Web app shortcuts in the default browser (Brave Origin): **WhatsApp**, **YouTube**, **X**. |
| **tuis.sh** | Installs no TUI shortcuts. |

### 1.4 Config – keyboard (keyd)

| Script | What |
| ------ | ---- |
| **keyd.sh** | Deploy `default/keyd/default.conf` to `/etc/keyd/`; enable **keyd** service. Maps Caps Lock → Super (Caps Lock disabled) so Hyprland Super bindings use the Caps key. |

### 1.5 Config – conditional packages

| Script | Condition | Packages |
| ------ | --------- | -------- |
| **config/hardware/vulkan.sh** | AMD GPU (lspci VGA/Display) | **vulkan-radeon** |

### 1.6 Login

| Script | What |
| ------ | ---- |
| **login/limine-snapper.sh** | If **limine** is present: **limine-snapper-sync**, **limine-mkinitcpio-hook** (and mkinitcpio/snapper config). |

### 1.7 boot.sh (curl install)

- Installs **git**, then clones the repo and runs `install.sh`. Used for install, update, and repair from a running Arch system (no ISO).

---

## 2. Base packages by purpose (`install/r2-d2-base.packages`)

The following lists every package in **`install/r2-d2-base.packages`**, grouped by purpose. Total: **150** packages (pacman only; AUR base via `install/r2-d2-base.aur.packages`).

### System and base

base, base-devel, linux, linux-firmware, linux-headers, btrfs-progs, snapper, limine, dkms, kernel-modules-hook, amd-ucode, zram-generator, keychain, keyd

### Compositor and session

hyprland, hypridle, hyprpicker, hyprsunset, hyprland-guiutils, swaybg, quickshell, uwsm, sddm, plymouth, egl-wayland, gtk4-layer-shell, qt5-wayland

### Shell and CLI

bash-completion, bat, eza, fd, fzf, less, ripgrep, starship, tmux, zoxide, tldr, gum, expac, man-db, wget, nano

### Terminal

alacritty. Alacritty is the default terminal (`default/config/xdg-terminals.list`; terminal `.desktop` files come from `applications/` via `r2-d2-refresh-applications` in `mimetypes.sh`).

### Audio

pipewire, pipewire-alsa, pipewire-jack, pipewire-pulse, wireplumber, pamixer, wiremix, libpulse, gst-plugin-pipewire, alsa-utils, playerctl

### Network and discovery

networkmanager, avahi, nss-mdns, inetutils, net-tools, qrencode

### Fonts and icons

fontconfig, noto-fonts, noto-fonts-cjk, noto-fonts-emoji, ttf-cascadia-mono-nerd, ttf-jetbrains-mono-nerd, woff2-font-awesome

### Secrets and session

gnome-keyring, polkit-gnome, libsecret

### Portals and XDG

xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland

### Screenshot, capture, sharing

grim, slurp, imagemagick, gpu-screen-recorder, satty, wl-clipboard, ffmpegthumbnailer, zbar, tesseract, tesseract-data-eng

### File manager and GVfs

thunar, tumbler, gvfs-mtp, gvfs-nfs, gvfs-smb, webp-pixbuf-loader, udiskie

### Browsers and default apps

**Brave Origin** (AUR package `brave-origin-nightly-bin`) is the default browser, including web apps. `chromium` stays installed as a spare and is not used by the desktop.

### Containers and Docker

docker, docker-buildx, docker-compose

### Development and runtimes (base list)

git, github-cli, clang, llvm, python-pip, python-poetry-core, python-gobject, luarocks, pnpm, yarn, just, tree, jq, libyaml, xmlstarlet, mariadb-libs, postgresql-libs, libqalculate

### System info and monitoring

btop, inxi, fastfetch, usage, brightnessctl, ddcutil

### Printing

cups, cups-browsed, cups-filters, cups-pdf, system-config-printer

### Power and hardware

power-profiles-daemon, bolt, wireless-regdb, socat

### Package tools

pacman-contrib

### Shell

quickshell draws the bar, panels, on-screen display, notifications, and lock screen.

### Apps and tools (user-facing)

qalculate-gtk, gnome-themes-extra, kvantum-qt5, evince, eog, pinta, totem, kdenlive, obs-studio, steam

### Firewall and security

ufw, openssh (sshd is installed but **not** enabled by default)

### Bluetooth

bluez, bluez-utils, bluez-tools

### App launcher and helpers

flatpak

### Misc

plocate, whois, unzip, exfatprogs, fuse2, wtype

### AUR base (`install/r2-d2-base.aur.packages`)

brave-origin-nightly-bin, cursor-bin, walker, elephant, hyprland-preview-share-picker-git, limine-mkinitcpio-hook, limine-snapper-sync, localsend, makima-bin, python-terminaltexteffects, tzupdate, ufw-docker, voxtype-bin, xdg-terminal-exec, yaru-icon-theme, yay

elephant-desktopapplications, elephant-websearch, elephant-menus, elephant-symbols, elephant-clipboard, elephant-calc, elephant-providerlist, elephant-files, elephant-runner, elephant-bluetooth, elephant-todo, elephant-unicode

---

## 3. Install menu – what can be installed from the menu

Everything below is **optional** from the menu (Install → …). No pacman package is added unless the user picks an option.

| Menu entry | What |
| ---------- | ---- |
| **Package** | `r2-d2-pkg-install` — pick any package from official repos. |
| **AUR** | `r2-d2-pkg-aur-install` — pick any package from AUR. |
| **Web App** | `r2-d2-webapp-install` — create a web app shortcut (any URL). Default install already adds WhatsApp, YouTube, X. |
| **AppImage** | `r2-d2-appimage-install` |
| **Development** | Node.js, Go, Python, Rust. |
| **Editor** | Cursor, VS Code, T3 Code, OpenCode, Hermes. Cursor is installed by default. Remove lists only editors that are installed. Removing Cursor or Voxtype stays off on later updates until you install that one again. Installing K-2SO still installs OpenCode when it is missing. |
| **K-2SO (companion)** | Install K-2SO background agent, clone/build from GitHub, enable `k2so.service` (`r2-d2-install-k2so`). |
| **Brook** | `r2-d2-install-brook` — offline music player from GitHub releases. **Super + M** starts it with no window. |
| **Dropbox** | `r2-d2-install-dropbox` |
| **Tailscale** | `r2-d2-install-tailscale` |

Background/wallpaper and accent theme are set via the background selector (**Super + Ctrl + Space**), not via the Install menu.

---

## 4. Summary

- **Base pacman packages:** 150 (from `install/r2-d2-base.packages`).
- **Base AUR packages:** 28 (from `install/r2-d2-base.aur.packages`) — browsers, walker/elephant stack, limine helpers, localsend, voxtype, xdg-terminal-exec, yay, and related AUR-only deps.
- **SSH:** `openssh` installed; `sshd` not enabled by default.
- **Conditional:** vulkan-radeon (AMD GPU); limine-snapper-sync + limine-mkinitcpio-hook also applied from login when limine is present.
- **Default web apps:** 3 (WhatsApp, YouTube, X).
- **Default editors:** Cursor (AUR).
- **Menu-installable:** Package (any), AUR (any), Web App, AppImage, Development runtimes, Editor (Cursor, VS Code, T3 Code, OpenCode, Hermes), K-2SO, Brook, Dropbox, Tailscale.

Use this list to adjust `install/r2-d2-base.packages` and menu entries when moving items between defaults and optionals.
