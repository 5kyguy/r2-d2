# R2-D2

R2-D2 is 5kyguy’s own config and setup on top of **Arch Linux** — a modern, opinionated desktop and tooling layer. This project uses **only the curl method** — no ISO. You install, update, and repair your laptops with the same command every time.

**Target hardware:** AMD CPU + GPU, HP/Dell laptops. English only.

## Prerequisites

Before installing, ensure your system meets these requirements:

- **Vanilla Arch Linux** (not a derivative like Manjaro, Garuda, EndeavourOS, or CachyOS)
- **x86_64** AMD CPU
- **Btrfs** root filesystem
- **Limine** bootloader installed
- **Secure Boot** disabled
- **Fresh install** — no existing GNOME or KDE desktop
- Run as a **non-root user** (the script will prompt for sudo when needed)

## Installation (and update / repair)

Install, update, or repair is always done the same way — **online only**, from a running Arch system:

```bash
curl -fsSL https://raw.githubusercontent.com/5kyguy/artoo-d2/refs/heads/dev/boot.sh | bash
```

This will:

1. **Bootstrap** — Set the stable mirror (`stable-mirror.omarchy.org`), update pacman, install git
2. **Clone** — Remove any existing `~/.local/share/omarchy/` and clone `5kyguy/artoo-d2` from the `dev` branch
3. **Run the installer** — Execute the full installation pipeline

### Installation Phases

**Phase 1 — Bootstrap (boot.sh)**

- Display ASCII logo
- Configure pacman mirror to `stable-mirror.omarchy.org`
- Install/update git
- Clone `5kyguy/artoo-d2` (dev branch) into `~/.local/share/omarchy/`
- Source `install.sh`

**Phase 2 — Guards**

- Verify Vanilla Arch, x86_64, Btrfs root, Limine, Secure Boot disabled, no GNOME/KDE

**Phase 3 — Preflight**

- Pacman setup: base-devel, **Omarchy keyring** (used for the Omarchy repo), mirror config, full system update
- Mark migrations as run (for fresh installs)
- First-run mode marker and sudoers for post-install cleanup
- Temporarily disable mkinitcpio hooks during package installation

**Phase 4 — Packaging**

- **Base packages** from `install/omarchy-base.packages` (pacman) and `install/omarchy-base.aur.packages` (AUR); includes system/base + desktop, Brave default browser, Chromium backup, Steam, etc.
- **AUR:** Helium (webapps), Cursor (editor), pear-desktop
- **Dev runtimes:** Go and Node.js via mise
- **Dictation:** Voxtype (non-interactive)
- Fonts, Neovim (LazyVim), icons, **webapps (YouTube, X — via Helium when available)**, TUIs (Disk Usage, Docker)

**Phase 5 — Config**

- Theme, branding, git, GPG, timezones, Docker, **mimetypes (Brave as default browser)**, hardware config (Vulkan, Bluetooth, printer, etc.). Chromium config is refreshed from defaults only (no Google/Chromium account setup).

**Phase 6 — Login**

- Plymouth, default keyring, SDDM, Limine + Snapper

**Phase 7 — Post-install**

- Hibernation setup, final pacman config, reboot prompt

## Themes

The default theme is a work in progress. Other [Omarchy themes](https://omarchythemes.com/) can be installed from the menu (Install → Theme). To install additional themes from other Omarchy theme repos, use `omarchy-theme-install <git-repo-url>`.

## Install / Remove / Update

- **Full install, update, or repair** — Re-run the same curl command from a running Arch system to clone the latest repo and run the installer again.
- **In-session update** — `omarchy-update` (git pull + snapshot + package updates)
- **Reinstall** — `omarchy-reinstall` (reinstall packages and reset default configs)
- **Install package** — `omarchy-pkg-add <pkg>`, or use the menu (Install → Package / AUR / etc.)
- **Remove package** — `omarchy-pkg-remove`, or menu (Remove → …)
