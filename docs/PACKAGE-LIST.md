# Package list and purposes

This document lists what is installed during the R2-D2 install and what can be installed from the **Install** menu (`r2-d2-menu install`). Use it to see defaults vs optionals and the purpose of each package.

---

## 1. Install process – what gets installed

### 1.1 Preflight (`install/preflight/`)

- **pacman.sh** — Installs **base-devel**; copies pacman.conf and mirrorlist; imports Omarchy key and installs **omarchy-keyring**; full sync and upgrade (`pacman -Syyuu`).
- All desktop and app packages are in **`install/r2-d2-base.packages`** (single pacman list).

### 1.2 Packaging – base packages (`install/packaging/base.sh`)

- **Pacman:** All packages from **`install/r2-d2-base.packages`** are installed (see categorized list below).
- **AUR:** If **`install/r2-d2-base.aur.packages`** exists, those packages are installed via yay (e.g. brave-bin, cursor-appimage). The repo does not ship this file by default; add it if you want base AUR packages.
- **Voxtype:** Optional via the menu (`r2-d2-voxtype-install`); copies `config/voxtype/config.toml` when installed.

### 1.3 Packaging – other steps

| Script | What |
| ------ | ---- |
| **dev-runtimes.sh** | **Go** (official tarball to `/usr/local`), **Node.js** (nvm, LTS). |
| **fonts.sh** | Copies **r2-d2.ttf** from `default/config/` to `~/.local/share/fonts`, runs `fc-cache`. |
| **icons.sh** | Copies bundled PNG icons to `~/.local/share/applications/icons`. |
| **webapps.sh** | Web app shortcuts via Helium when available: **WhatsApp**, **YouTube**, **X**, **Discord**. |
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

The following lists every package in **`install/r2-d2-base.packages`**, grouped by purpose. Total: **163** packages (pacman only; AUR base is optional via `r2-d2-base.aur.packages` if present).

### System and base

base, base-devel, linux, linux-firmware, linux-headers, btrfs-progs, snapper, limine, limine-mkinitcpio-hook, limine-snapper-sync, dkms, kernel-modules-hook, amd-ucode, zram-generator, keychain, omarchy-keyring

### Compositor and session

hyprland, hypridle, hyprlock, hyprpicker, hyprsunset, hyprland-guiutils, hyprland-preview-share-picker, swaybg, swayosd, waybar, uwsm, sddm, plymouth, egl-wayland, gtk4-layer-shell

### Shell and CLI

bash-completion, bat, eza, fd, fzf, less, ripgrep, starship, tmux, zoxide, tldr, gum, expac, man-db, wget, nano

### Terminal and editor

alacritty, ghostty, neovim, tree-sitter-cli. Alacritty is the default terminal (`config/terminal-default.sh` and `default/config/xdg-terminals.list`).

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

chromium (default browser when no Brave from AUR).

### Containers and Docker

docker, docker-buildx, docker-compose, lazydocker

### Development and runtimes (base list)

git, github-cli, clang, llvm, rust, jdk-openjdk, python-pip, python-poetry-core, python-gobject, python-terminaltexteffects, luarocks, pnpm, just, tree, jq, libyaml, xmlstarlet, mariadb-libs, postgresql-libs, libqalculate, lazygit

### System info and monitoring

btop, htop, inxi, fastfetch, dust, usage, brightnessctl

### Printing

cups, cups-browsed, cups-filters, cups-pdf, system-config-printer

### Power and hardware

power-profiles-daemon, bolt, wireless-regdb

### Notifications and OSD

mako, swayosd

### Apps and tools (user-facing)

gnome-calculator, gnome-disk-utility, gnome-themes-extra, kvantum-qt5, evince, eog, pinta, kdenlive, obs-studio, vlc, steam

### Firewall and security

ufw, ufw-docker

### App launcher and helpers

r2-d2-walker, flatpak

### Misc

plocate, whois, tzupdate, unzip, exfatprogs, impala, bluetui, wtype

---

## 3. Install menu – what can be installed from the menu

Everything below is **optional** from the menu (Install → …). No pacman package is added unless the user picks an option.

| Menu entry | What |
| ---------- | ---- |
| **Package** | `r2-d2-pkg-install` — pick any package from official repos. |
| **AUR** | `r2-d2-pkg-aur-install` — pick any package from AUR. |
| **Web App** | `r2-d2-webapp-install` — create a web app shortcut (any URL). Default install already adds WhatsApp, YouTube, X, Discord. |
| **TUI** | `r2-d2-tui-install` — add a TUI shortcut. Default install adds Disk Usage and Docker. |
| **Development** | Docker DB (containers), JavaScript (Node/Bun/Deno), Go, Python, Elixir, Zig, Rust. Go and Node are preinstalled by `dev-runtimes.sh`. |
| **Editor** | VSCode (`r2-d2-install-vscode`), Zed (pacman). Cursor is typically from AUR base list if used. |
| **Terminal** | Alacritty, Ghostty (set as default terminal for R2-D2). Alacritty is already in base packages. |
| **AI** | Claude Code, Codex, Gemini CLI, Copilot CLI, Cursor CLI, LM Studio, Ollama (script uses ollama-rocm), Crush. |
| **Dictation (Voxtype)** | Install Voxtype + download the model + enable its systemd service (`r2-d2-voxtype-install`). |
| **Gaming** | RetroArch [AUR], Minecraft, Xbox Controller [AUR]. Steam is in base packages. |

Background/wallpaper is set via the background selector (**Super + Ctrl + Space**), not via the Install menu.

---

## 4. Summary

- **Base pacman packages:** 163 (from `install/r2-d2-base.packages`).
- **Base AUR packages:** Optional; if `install/r2-d2-base.aur.packages` exists, those are installed (e.g. brave-bin, cursor-appimage).
- **Conditional:** vulkan-radeon (AMD GPU); limine-snapper-sync + limine-mkinitcpio-hook (if limine present).
- **Default web apps:** 4 (WhatsApp, YouTube, X, Discord).
- **Default TUI shortcuts:** 2 (Disk Usage, Docker).
- **Menu-installable:** Package (any), AUR (any), Web App, TUI, Development runtimes, Editor (VSCode, Zed), Terminal (Alacritty, Ghostty), AI tools, Gaming (RetroArch, Minecraft, Xbox).

Use this list to adjust `install/r2-d2-base.packages` and menu entries when moving items between defaults and optionals.
