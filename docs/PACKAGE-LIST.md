# Package list and purposes

This document lists what is installed during the R2-D2 install and what can be installed from the **Install** menu (`r2-d2-menu install`). Use it to see defaults vs optionals and the purpose of each package.

---

## 1. Install process – what gets installed

### 1.1 Profile and package lists

`boot.sh` writes the install profile to `~/.config/r2-d2/profile` (`desktop` or `server`).

| List | Desktop | Server |
| ---- | ------- | ------ |
| **`install/r2-d2-core.packages`** | yes | yes |
| **`install/r2-d2-desktop.packages`** | yes | no |
| **`install/r2-d2-desktop.aur.packages`** | yes | no |

Server is a strict subset of desktop: desktop installs **core + desktop**; server installs **core only**.

### 1.2 Preflight (`install/preflight/`)

- **pacman.sh** — Installs **base-devel**; copies pacman.conf and mirrorlist; imports Omarchy key and installs **omarchy-keyring**; full sync and upgrade (`pacman -Syyuu`).

### 1.3 Packaging (`install/packaging/base.sh`)

- **Pacman:** Profile-aware install from the lists above.
- **AUR (desktop only):** `brave-origin-nightly-bin`, `cursor-bin`, `helium-browser-bin` via yay.
- **Server extras:** `k2so.sh` runs automatically on server profile (desktop: optional via menu).
- **Voxtype:** Optional via the menu (`r2-d2-voxtype-install`).

### 1.4 Packaging – other steps

| Script | Desktop | Server |
| ------ | ------- | ------ |
| **opencode.sh** | yes | yes |
| **fonts.sh** | yes | no |
| **icons.sh** | yes | no |
| **webapps.sh** | yes | no |
| **tuis.sh** | yes | no |
| **k2so.sh** | menu only | yes |

### 1.5 Config – keyboard (keyd, desktop only)

| Script | What |
| ------ | ---- |
| **keyd.sh** | Deploy `default/keyd/default.conf` to `/etc/keyd/`; enable **keyd** service. |

### 1.6 Config – conditional packages (desktop only)

| Script | Condition | Packages |
| ------ | --------- | -------- |
| **config/hardware/vulkan.sh** | AMD GPU (lspci VGA/Display) | **vulkan-radeon** |

### 1.7 Login

| Profile | What |
| ------- | ---- |
| **desktop** | plymouth, SDDM, default keyring, limine-snapper |
| **server** | `multi-user.target`, `sshd`, limine-snapper (headless hooks) |

---

## 2. Core packages (`install/r2-d2-core.packages`)

Installed on **every** profile. **85** pacman packages.

### System and boot

base, base-devel, linux, linux-firmware, linux-headers, btrfs-progs, snapper, limine, limine-mkinitcpio-hook, limine-snapper-sync, dkms, kernel-modules-hook, amd-ucode, zram-generator, omarchy-keyring, yay, yay-debug

### Server / remote / security

openssh, polkit, logrotate, ufw, ufw-docker

### Containers (CLI)

docker, docker-buildx, docker-compose

### Shell and CLI

bash-completion, bat, eza, fd, fzf, less, ripgrep, starship, tmux, zoxide, tldr, gum, expac, man-db, wget, nano, tree, jq, just, dust, usage, btop, inxi, fastfetch

### Development (no clang/llvm)

git, github-cli, python-pip, python-poetry-core, python-gobject, python-terminaltexteffects, luarocks, pnpm, yarn, libyaml, xmlstarlet, mariadb-libs, postgresql-libs, libqalculate, plocate, impala

### Network

iwd, avahi, nss-mdns, inetutils, net-tools, wireless-regdb

### Secrets

gnome-keyring, libsecret, keychain

### Power (laptop)

power-profiles-daemon, bolt

### Fonts (CLI)

fontconfig, noto-fonts, ttf-cascadia-mono-nerd, ttf-jetbrains-mono-nerd

### Misc

whois, tzupdate, unzip, exfatprogs, fuse2

---

## 3. Desktop-only packages (`install/r2-d2-desktop.packages`)

**78** additional pacman packages on desktop profile only.

Includes: Hyprland stack, SDDM, Plymouth, Flatpak, Elephant/Walker, browsers (`chromium`), audio/pipewire UI, capture tools, file managers, media apps, printing, `keyd`, `makima-bin`, **lazygit**, **lazydocker**, and related desktop dependencies.

### Desktop AUR (`install/r2-d2-desktop.aur.packages`)

brave-origin-nightly-bin, cursor-bin, helium-browser-bin

---

## 4. Install menu – optionals

Everything below is **optional** from the menu unless noted. Server profile skips most GUI-oriented entries.

| Menu entry | What |
| ---------- | ---- |
| **Package** | `r2-d2-pkg-install` — any official repo package. |
| **AUR** | `r2-d2-pkg-aur-install` — any AUR package. |
| **Web App** | Desktop only — web app shortcuts. |
| **TUI** | Desktop only — TUI shortcuts. |
| **Development** | Docker DB, Node.js, Go, Python, Rust. |
| **Editor** | Desktop — VS Code, T3 Code. Cursor is desktop default (AUR). |
| **Dictation (Voxtype)** | Optional on either profile. |
| **K-2SO (companion)** | Auto on server install; menu on desktop. |
| **Gaming** | Desktop — Steam, Xbox controllers. |

---

## 5. Summary

- **Core pacman packages:** 85 (`install/r2-d2-core.packages`) — server + desktop.
- **Desktop-only pacman packages:** 78 (`install/r2-d2-desktop.packages`).
- **Desktop AUR:** brave-origin-nightly-bin, cursor-bin, helium-browser-bin.
- **Removed from all lists:** clang, llvm (editor build tooling no longer needed).
- **Desktop-only dev TUIs:** lazygit, lazydocker (server keeps docker CLI only).

Use the core/desktop split when moving packages between server and workstation defaults.