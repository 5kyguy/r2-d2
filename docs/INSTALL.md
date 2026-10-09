# R2-D2

R2-D2 is 5kyguy’s own config and setup on top of **Arch Linux** — a modern, opinionated desktop and tooling layer. This project uses **only the curl method** — no ISO. Use the curl bootstrap for fresh installs, repairs, and full resets; use `r2-d2-update` for normal in-session updates.

**Target hardware:** AMD CPU + GPU, HP/Dell laptops. English only.

## Prerequisites

Install Arch Linux using archinstall, with the following options:

| Section | Option |
| ------- | ------ |
| Disk > File system | btrfs (default structure: yes + use compression) |
| Disk > Disk encryption | Encryption type: LUKS + Encryption password + Partitions (select the one) |
| Bootloader | Limine |
| Applications | Audio: pipewire |

## Installation (full install / repair)

Use this path for a fresh install, a repair, or when you want to reset the machine to the repo defaults — **online only**, from a running Arch system:

```bash
curl -fsSL https://raw.githubusercontent.com/5kyguy/r2-d2/refs/heads/master/boot.sh | bash
```

This will:

1. **Bootstrap (boot.sh)** — Set a working mirror (`geo.mirror.pkgbuild.com`, Arch's official geoIP mirror), update pacman, install git, remove any existing `~/.local/share/r2-d2/`, clone `5kyguy/r2-d2` from the `master` branch, then source `install.sh`
2. **Run the installer** — Execute the full pipeline (preflight → packaging → config → login → post-install)

`install/preflight/guard.sh` checks vanilla Arch, not root, x86_64, Secure Boot off, no GNOME or KDE, Limine, and a Btrfs root, and asks before continuing if one fails.

## In-session update

If R2-D2 is already installed and you just want the latest repo changes, use:

```bash
r2-d2-update
```

This is the normal day-to-day update path. It:

1. Creates a snapshot when available
2. Runs `git pull --autostash` in `~/.local/share/r2-d2`
3. Overwrites repo-managed user config from `config/` and refreshes `applications/`
4. Updates system packages and installs any missing packages from the repo base package lists
5. Runs migrations for `default/` and other special-command changes, then AUR updates, orphan cleanup, and post-update hooks

Use the full `boot.sh` flow when you want a full reinstall/repair.

### Which path should I use?

| Path | When to use | What it does |
| ------- | ------- | ------- |
| **Full install / repair (`boot.sh`)** | Fresh install, repair, or reset to repo defaults | Re-clones `~/.local/share/r2-d2` and runs the full install pipeline, including packaging, config copy, login, and post-install steps |
| **In-session update (`r2-d2-update`)** | Normal updates on an already-installed system | Pulls the latest repo into `~/.local/share/r2-d2`, overwrites repo-managed user config from `config/`, refreshes `applications/`, syncs base packages, and runs pending migrations |

### What migrations do during updates

Migrations are the mechanism for applying `default/`, `default/config/`, and other special-command changes on an existing install.

- Migration scripts live in `migrations/*.sh`
- Their state lives in `~/.local/state/r2-d2/migrations/`
- `r2-d2-migrate` only runs migrations that do not already have a matching state file
- On a fresh install, existing migrations are marked as completed during preflight, so the install steps create the desired state directly

This means `r2-d2-update` applies only newly added migrations after a pull, not the whole migration history every time.

Use migrations for:

- `default/`-backed system files that land in `/etc`, `/boot`, `/usr/share`, and similar system paths
- `default/config/` support assets that live under `~/.config` but should not be overwritten by normal update sync
- special commands or one-time actions that are not simple repo file overwrites

### What `r2-d2-update` does not refresh automatically

- It does **not** re-run the full install pipeline
- It does **not** blindly overwrite `default/` into system paths; that remains migration/refresh-script territory
- It does **not** overwrite `default/config/` support assets during normal update sync; those are handled by install/reinstall and migrations
- It does **not** need to copy `bin/` or `backgrounds/` anywhere else; they are already live from `~/.local/share/r2-d2`

If you want a repo config file refreshed without doing a full reinstall, use:

```bash
r2-d2-refresh-config hypr/hypridle.conf
```

If you want all default configs reset, use `r2-d2-reinstall-configs`. If you want all default packages reinstalled from the repo package list, use `r2-d2-reinstall-pkgs`.

### Installation Phases (install.sh)

**Phase 1 — Preflight** (`install/preflight/all.sh`)

- **guard.sh** — Check vanilla Arch, not root, x86_64, Secure Boot off, no GNOME or KDE, Limine, and a Btrfs root
- **begin.sh** — Clear screen, show “Installing…”, start install log
- **pacman.sh** — Install base-devel; copy pacman.conf and mirrorlist; full sync and upgrade (`pacman -Syyuu`)
- **migrations.sh** — Prepare migration state directory; migrations run at end of install (r2-d2-migrate)
- **first-run-mode.sh** — Create first-run marker and sudoers entries for post-login cleanup
- **disable-mkinitcpio.sh** — Temporarily disable mkinitcpio hooks during package install

**Phase 2 — Packaging** (`install/packaging/all.sh`)

- **base.sh** — Install all packages from `install/r2-d2-base.packages` (pacman) and `install/r2-d2-base.aur.packages` (AUR via yay). See `docs/PACKAGE-LIST.md` for what is installed.
- **omaroll.sh** — Install Omaroll from GitHub releases and point images and videos at it (`r2-d2-install-omaroll`)
- **fonts.sh** — Copy `r2-d2.ttf` and `manrope-variable.ttf` to `~/.local/share/fonts`, run fc-cache
- **icons.sh** — Copy bundled icons to `~/.local/share/applications/icons`
- **webapps.sh** — Create web app shortcuts (WhatsApp, YouTube, X, Telegram) in the default browser (Brave Origin)
- **tuis.sh** — Installs no TUI shortcuts

**Phase 3 — Config** (`install/config/all.sh`)

- **config.sh** — Copy repo `config/*` user config to `~/.config/`, default bashrc to `~/.bashrc`
- **voxtype.sh** — Download the `small.en` model and enable the user service
- **default-config.sh** — Copy repo `default/config/*` support assets into their live `~/.config` locations
- **theme.sh** — Wallpaper symlink, accent theme apply (`r2-d2-theme-apply`), sync themed config to `~/.config/` (`r2-d2-theme-sync-live`), Chromium policy dirs
- **keyd.sh** — Deploy Caps Lock → Left Super via keyd (`default/keyd/default.conf` → `/etc/keyd/`); Caps Lock disabled
- **branding.sh** — Copy the icon for fastfetch and the screensaver
- **git, gpg, timezones** — User/config defaults
- **sudoers-helpers.sh** — Passwordless sudoers for DNS presets and timezone changes
- **increase-file-watchers** — Dev tooling (inotify limits)
- **detect-keyboard-layout, xcompose** — Input
- **docker.sh, flatpak.sh** — Container/flatpak config
- **mimetypes.sh** — Refresh applications (copies repo `applications/*.desktop`), default apps (Brave Origin, Zathura, Omaroll, Nano); terminal order from `default/config/xdg-terminals.list`. Change text, PDF, image, and video handlers later from Setup → Default apps
- **walker-elephant.sh, fast-shutdown.sh, input-group.sh** (plocate DB: run `r2-d2-update-locate` when needed)
- **oomd.sh** — Enable systemd-oomd for `app.slice` only
- **zram.sh** — zram drop-in, and disable zswap in front of zram
- **makima.sh** — Remap the Copilot key with makima
- **kernel-modules-hook.sh, wifi-powersave-rules.sh**
- **plocate-ac-only.sh** — Run the plocate database update only on AC power
- **hardware/** — network, wireless regdom, Bluetooth, printer, USB autosuspend, power button, Vulkan (AMD), Synaptics touchpad, AMD ISP4 webcam
- **unmount-fuse.sh** — Unmount gvfs FUSE before suspend or hibernate

**Phase 4 — Login** (`install/login/all.sh`)

- **plymouth.sh** — Boot splash
- **default-keyring.sh** — Default keyring setup
- **sddm.sh** — SDDM display manager
- **limine-snapper.sh** — Limine + Snapper (when limine present)

**Phase 5 — Post-install** (`install/post-install/all.sh`)

- **hibernation.sh** — Enable hibernation
- **pacman.sh** — Final pacman.conf and mirrorlist
- **r2-d2-migrate** — Run pending migrations (idempotent; safe on first install and re-run)
- **allow-reboot.sh** — Sudoers for reboot
- **finished.sh** — Stop log, show logo and install time, remove reboot sudoers, prompt to reboot now

## Themes

R2-D2 uses a dark companion palette with a **named wallpaper accent**. The base colors (background, text, inactive borders) stay fixed. Each wallpaper is measured and snapped to the nearest accent in `config/theme/palette.toml`: Black, White, Cyan, Green, Red, Purple, or Gold. That accent is applied across Hyprland, the shell, GTK, the terminal, notifications, and other UI.

- Change the wallpaper with the background carousel (**Super + Ctrl + Space**). Left and right move through the images, typing filters by name, and Enter applies the selection. `r2-d2-theme-bg-set` updates the desktop image, snaps the nearest named accent, syncs themed config to `~/.config/` via `r2-d2-theme-sync-live`, and reloads desktop components immediately.
- Achromatic images resolve to Black or White. A missing wallpaper is White (`#FFFFFF`). No free color is taken from the image.
- The shell, Walker, and the terminal stay on JetBrainsMono Nerd Font. Manrope still ships in `default/config/` and is copied into `~/.local/share/fonts` on install and update.
- Run **Update** (`r2-d2-update`) to refresh all repo-managed config and optionally reload desktop components when prompted.
- Theme templates live in `config/theme/templates/`; `r2-d2-theme-apply` renders them into the repo only.
- Successful renders stage `.theme-state.json`; explicit theme/full-config syncs then atomically select `${XDG_STATE_HOME:-$HOME/.local/state}/r2-d2/theme.json` for local consumers. Rendering alone does not activate that document or reload the desktop. See [the visual contract](VISUAL-CONTRACT.md#state) for compatibility, validation, and failure behavior.
- Website publication is off unless `${XDG_CONFIG_HOME:-$HOME/.config}/r2-d2/theme-publish.conf` opts in. A failed publish does not affect the desktop or Brook. Provisioning and rotation are in [the visual contract](VISUAL-CONTRACT.md#publication).

## Keyboard (Caps Lock → Super)

R2-D2 maps **Caps Lock** to **Left Super** system-wide via **keyd** (`default/keyd/default.conf`). Caps Lock lock state is disabled (games/Proton often toggles it and leaves typing stuck in uppercase). After install or update:

- Press **Caps Lock** for Hyprland **Super** bindings (launcher, tiling, workspaces, etc.)
- Press **Left Win** for Super as well (both keys are Super)
- Use **Shift** for capitals — there is no Caps Lock key

Hyprland `input.lua` sets `kb_options = "caps:none"` so injected Caps Lock events cannot re-enable the lock.

## Install / Remove / Update

- **Full install / repair / reset-to-defaults** — Re-run the same curl command from a running Arch system to clone the latest repo and run the installer again.
- **In-session update** — `r2-d2-update` (snapshot + git pull + config/app refresh + base package sync + pending migrations)
- **Reinstall** — `r2-d2-reinstall` (reinstall packages and reset default configs)
- **Reinstall packages only** — `r2-d2-reinstall-pkgs`
- **Reinstall configs only** — `r2-d2-reinstall-configs`
- **Refresh one config file** — `r2-d2-refresh-config <path>`
- **Install package** — `r2-d2-pkg-add <pkg>`, or use the menu (Install → Package / AUR / etc.)
- **Remove package** — `r2-d2-pkg-remove`, or menu (Remove → …)
