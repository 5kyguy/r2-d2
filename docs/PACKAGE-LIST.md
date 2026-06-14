# Package list and purposes

This document lists what is installed during the R2-D2 install and what can be installed from the **Install** menu (`r2-d2-menu install`). Use it to see defaults vs optionals and the purpose of each package.

---

## 1. Install process – what gets installed

### 1.1 Preflight (`install/preflight/`)

- **pacman.sh** — Installs **base-devel**; copies pacman.conf and mirrorlist; imports Omarchy key and installs **omarchy-keyring**; full sync and upgrade (`pacman -Syyuu`).
- All desktop and app packages are in **`install/r2-d2-base.packages`** (single pacman list).

### 1.2 Packaging – base packages (`install/packaging/base.sh`)

- **Pacman:** All packages from **`install/r2-d2-base.packages`** are installed (see categorized list below).
- **AUR:** Packages from **`install/r2-d2-base.aur.packages`** are installed via yay (brave-origin-nightly-bin, cursor-bin, helium-browser-bin).
- **Voxtype:** Optional via the menu (`r2-d2-voxtype-install`); copies `config/voxtype/config.toml` when installed.

### 1.3 Packaging – other steps

| Script | What |
| ------ | ---- |
| **opencode.sh** | **Opencode** via the official curl installer (`~/.opencode/bin`). |
| **fonts.sh** | Copies **r2-d2.ttf** from `default/config/` to `~/.local/share/fonts`, runs `fc-cache`. |
| **icons.sh** | Copies bundled PNG icons to `~/.local/share/applications/icons`. |
| **webapps.sh** | Web app shortcuts via Helium when available: **WhatsApp**, **YouTube**, **X**. |
| **tuis.sh** | TUI shortcuts: **Disk Usage** (dust), **Docker** (lazydocker). |

### 1.4 Config – conditional packages

| Script | Condition | Packages |
| ------ | --------- | -------- |
| **config/hardware/vulkan.sh** | AMD GPU (lspci VGA/Display) | **vulkan-radeon** |

### 1.5 Login

| Script | What |
| ------ | ---- |
| **login/limine-snapper.sh** | If **limine** is present: **limine-snapper-sync**, **limine-mkinitcpio-hook** (and mkinitcpio/snapper config). |

### 1.6 boot.sh (curl install)

- Installs **git**, then clones the repo and runs `install.sh`. Used for install, update, and repair from a running Arch system (no ISO).

---

## 2. Base packages by purpose (`install/r2-d2-base.packages`)

The following lists every package in **`install/r2-d2-base.packages`**, grouped by purpose. Total: **161** packages (pacman only; AUR base via `install/r2-d2-base.aur.packages`).

### System and base

base, base-devel, linux, linux-firmware, linux-headers, btrfs-progs, snapper, limine, limine-mkinitcpio-hook, limine-snapper-sync, dkms, kernel-modules-hook, amd-ucode, zram-generator, keychain, omarchy-keyring

### Compositor and session

hyprland, hypridle, hyprlock, hyprpicker, hyprsunset, hyprland-guiutils, hyprland-preview-share-picker, swaybg, swayosd, waybar, uwsm, sddm, plymouth, egl-wayland, gtk4-layer-shell

### Shell and CLI

bash-completion, bat, eza, fd, fzf, less, ripgrep, starship, tmux, zoxide, tldr, gum, expac, man-db, wget, nano

### Terminal

alacritty. Alacritty is the default terminal (`default/config/xdg-terminals.list`; terminal `.desktop` files come from `applications/` via `r2-d2-refresh-applications` in `mimetypes.sh`).

### Audio

pipewire, pipewire-alsa, pipewire-jack, pipewire-pulse, wireplumber, pamixer, wiremix, libpulse, gst-plugin-pipewire, alsa-utils, playerctl

### Network and discovery

iwd, avahi, nss-mdns, inetutils, net-tools

### Fonts and icons

fontconfig, noto-fonts, noto-fonts-emoji, ttf-cascadia-mono-nerd, woff2-font-awesome, yaru-icon-theme

### Secrets and session

gnome-keyring, polkit-gnome, libsecret

### Portals and XDG

xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland, xdg-terminal-exec

### Screenshot, capture, sharing

grim, slurp, imagemagick, gpu-screen-recorder, satty, wl-clipboard, localsend, ffmpegthumbnailer

### File manager and GVfs

nautilus, nautilus-python, sushi, gvfs-mtp, gvfs-nfs, gvfs-smb, webp-pixbuf-loader

### Browsers and default apps

chromium (fallback). Default browser is **Brave Origin Nightly** (AUR); **Helium** is used for web apps when available.

### Containers and Docker

docker, docker-buildx, docker-compose, lazydocker

### Development and runtimes (base list)

git, github-cli, clang, llvm, python-pip, python-poetry-core, python-gobject, python-terminaltexteffects, luarocks, pnpm, just, tree, jq, libyaml, xmlstarlet, mariadb-libs, postgresql-libs, libqalculate, lazygit

### System info and monitoring

btop, inxi, fastfetch, dust, usage, brightnessctl

### Printing

cups, cups-browsed, cups-filters, cups-pdf, system-config-printer

### Power and hardware

power-profiles-daemon, bolt, wireless-regdb

### Notifications and OSD

mako, swayosd

### Apps and tools (user-facing)

gnome-calculator, gnome-themes-extra, kvantum-qt5, evince, eog, pinta, totem, kdenlive, obs-studio, steam

### Firewall and security

ufw, ufw-docker

### App launcher and helpers

omarchy-walker, flatpak

### Misc

plocate, whois, tzupdate, unzip, exfatprogs, impala, bluetui, wtype

---

## 3. Install menu – what can be installed from the menu

Everything below is **optional** from the menu (Install → …). No pacman package is added unless the user picks an option.

| Menu entry | What |
| ---------- | ---- |
| **Package** | `r2-d2-pkg-install` — pick any package from official repos. |
| **AUR** | `r2-d2-pkg-aur-install` — pick any package from AUR. |
| **Web App** | `r2-d2-webapp-install` — create a web app shortcut (any URL). Default install already adds WhatsApp, YouTube, X. |
| **TUI** | `r2-d2-tui-install` — add a TUI shortcut. Default install adds Disk Usage and Docker. |
| **Development** | Docker DB (containers), Node.js, Go, Python, Rust. |
| **Editor** | VS Code, T3 Code (`r2-d2-install-editor`). Cursor and Opencode are installed by default. |
| **Dictation (Voxtype)** | Install Voxtype + download the model + enable its systemd service (`r2-d2-voxtype-install`). |
| **Gaming** | Install Steam and Xbox controllers (`r2-d2-install-steam`, `r2-d2-install-xbox-controllers`). Steam is in base packages. |

Background/wallpaper is set via the background selector (**Super + Ctrl + Space**), not via the Install menu.

---

## 4. Summary

- **Base pacman packages:** 161 (from `install/r2-d2-base.packages`).
- **Base AUR packages:** brave-origin-nightly-bin, cursor-bin, helium-browser-bin.
- **Conditional:** vulkan-radeon (AMD GPU); limine-snapper-sync + limine-mkinitcpio-hook (if limine present).
- **Default web apps:** 3 (WhatsApp, YouTube, X).
- **Default TUI shortcuts:** 2 (Disk Usage, Docker).
- **Default editors:** Cursor (AUR), Opencode (curl installer).
- **Menu-installable:** Package (any), AUR (any), Web App, TUI, Development runtimes, Editor (VS Code, T3 Code), Gaming (Steam, Xbox controllers).

Use this list to adjust `install/r2-d2-base.packages` and menu entries when moving items between defaults and optionals.
