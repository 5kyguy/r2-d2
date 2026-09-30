# R2-D2 visual contract

Contract: `skyguy-visual` version **1**. Canonical rules and the derivation algorithm live in the portfolio's `DESIGN.md`. This note is how the desktop applies that version. Theme rendering stays inside the repo until an explicit apply or update. Do not write `~/.config/` or reload the session from theme work in progress.

The matching fixture is `docs/fixtures/contrast-v1.json`. Template colors for text, borders, and controls match those samples.

## Derivation

Use WCAG relative luminance in IEEE-754 doubles. Contrast is `(lighter + 0.05) / (darker + 0.05)`. Compare with `>= 4.5` for text and `>= 3.0` for borders before rounding. Blend toward `#FFFFFF` in steps of `0.01` until the color clears `#0A0A0A`, `#121212`, and `#1A1A1A`. Round each channel with half-away-from-zero, then clamp to `0..255`. Keep the smallest step that passes. A source that already passes is unchanged.

Control ink is `#0A0A0A` or `#FAFAFA`, whichever contrasts more, if that ratio is at least 4.5. If neither passes, darken the fill toward black until `#FAFAFA` passes, or lighten it toward white until `#0A0A0A` passes, and keep the shorter blend. The RGB role is the source channels. `design/contrast.py` in the portfolio repo is the reference checker; this desktop does not run it during theme apply.

## What the desktop takes

- The dark base already in `config/theme/palette.toml`: background `#121212`, foreground `#D4D4D4`, inactive `#606060`, dim `#8A8A8D`, plus the shared page `#0A0A0A` and raised `#1A1A1A` where a surface needs them.
- Wallpaper source accent, validated as six-digit hex before templates render.
- Derived text, border, control, and on-control roles from the shared algorithm. The brighter/dimmer mixes in `r2-d2-theme-apply` are not those roles.
- Critical `#C73838`, critical dark `#862020`, warning `#E07924`, magenta `#932A37`. Small critical text uses `#D25E5E`. Warning on this dark base can stay `#E07924`.
- Existing logo and icon files under `assets/`. White on dark surfaces, black on light. Silver and blue stay branding variants. They are PNG-in-SVG, so they do not inherit `currentColor`.
- JetBrainsMono Nerd Font for terminals, Waybar, Walker, Hyprlock, and Alacritty. Icon glyphs stay on that font. Mako uses Manrope for notification text. The variable font ships in `default/config/` because the AUR package's download returns 404. Hyprland blur and wallpaper treatment are unchanged.

R2-D2 stays dark. The light palette belongs to the portfolio.

Grayscale wallpapers still resolve to `fallback_accent` `#EAEAEA`. That is a successful accent. Monochrome `#FFFFFF` is only for a missing or invalid accent during first install or a failed read, and it still runs through derivation.

## Surfaces in scope

Templates rendered by `r2-d2-theme-apply`:

| Template | Output |
| --- | --- |
| `hypr-looknfeel.lua.in` | `config/hypr/looknfeel.lua` |
| `hypr-hyprlock.conf.in` | `config/hypr/hyprlock.conf` |
| `waybar.css.in` | `config/waybar/waybar.css` |
| `waybar-style.css.in` | `config/waybar/style.css` |
| `gtk.css.in` | `config/gtk-3.0/gtk.css` |
| `gtk4.css.in` | `config/gtk-4.0/gtk.css` |
| `alacritty.toml.in` | `config/alacritty/alacritty.toml` |
| `mako.ini.in` | `config/mako/config` |
| `swayosd.css.in` | `config/swayosd/style.css` |
| `btop.theme.in` | `config/btop/themes/current.theme` |
| `starship.toml.in` | `config/starship.toml` |
| `walker.css.in` | `default/config/walker/themes/default/style.css` |
| `share-picker.css.in` | `default/config/hyprland-preview-share-picker/style.css` |
| `hermes-skin.yaml.in` | `config/theme/accent-apps/hermes-skin.yaml` |
| `opencode-theme.json.in` | `config/theme/accent-apps/opencode.json` |
| `cursor-accent.json.in` | `config/theme/accent-apps/cursor.json` |

`gtk4.css.in` defines `accent_color`, `accent_bg_color`, and `accent_fg_color` only. Header bars, window backgrounds, and corner radius stay on the GTK theme.

`r2-d2-theme-sync-live` and `r2-d2-config-sync-live` place the other accent files after the repo render. They do not restart Hermes, OpenCode, Cursor, or Qt.

- Hermes: `~/.hermes/skins/r2-d2.yaml` sets `ui_accent`, `banner_accent`, `response_border`, and `selection_bg`. Every other color stays on the built-in default skin. `display.skin` becomes `r2-d2`.
- OpenCode: `~/.config/opencode/themes/opencode.json` is the built-in OpenCode palette with `darkAccent` and `lightAccent` replaced. The theme name stays `opencode`, so `tui.json` and `opencode.json` are left alone.
- Cursor: accent keys are merged into `workbench.colorCustomizations` in the existing user settings. `workbench.colorTheme` stays as it is.
- Kvantum: when `/usr/share/Kvantum/KvDark` is installed, a clone named `r2-d2` changes highlight and link colors, and `kvantum.kvconfig` selects that clone. KvDark uses the same window color as Kvantum's builtin default.

A running Hermes, OpenCode, Cursor, or Qt process keeps its previous accent until the next launch.

SDDM (`default/sddm/r2-d2/`) and Plymouth (`default/plymouth/`) are system-managed. They follow install, update, and migration, not the wallpaper render path. This pass does not recolor them.

The rendered templates use palette roles and the derived dark accent roles (`text`, `border`, `control`, `on_control`). Lock-screen and prompt text use the text role. Borders use the border role. Critical notifications and the shell error mark stay on `#C73838` / `#D25E5E`. ANSI slots that were already accent-mapped stay that way. The old fixed grays in Walker, Waybar, btop, Alacritty, GTK, and the share picker are palette roles.

## Out of scope

Chromium, Brave, VS Code, Steam, Spotify, and icon themes. GTK 4, Cursor, Kvantum, Hermes, and OpenCode take the wallpaper accent and keep their own surfaces. K-2SO is a separate project. Menu behavior stays as documented in `docs/MENU.md` and `docs/INSTALL.md`.

## State

State lives under `${XDG_STATE_HOME:-$HOME/.local/state}/r2-d2/`. When the new state directory has no compatibility file, the renderer can read the legacy `~/.local/state/r2-d2/theme-accent`. New writes use the configured directory.

| File | Meaning | Writer |
| --- | --- | --- |
| `$R2D2_PATH/.theme-state.json` | Last successful repository render, not yet necessarily selected for the desktop | `r2-d2-theme-apply` |
| `theme-accent` in the state directory | Compatibility color from the last successful render | Internal state helper after rendering |
| `theme.json` in the state directory | Versioned theme selected by the last successful explicit live-config sync | `r2-d2-theme-sync-live` or `r2-d2-config-sync-live` |

Consumers such as Brook must read **theme.json**, not the staged document or compatibility file. Repository-only renders do not advance this consumer document, publish to the website, or reload the desktop. A successful config sync may precede a user-approved desktop reload during update; the document describes selected configuration, not proof that every running process has reloaded it.

The document contains schema `version: 1`, `contract: skyguy-visual`, `contract_version: 1`, a fixed-key palette, an accent source plus dark/light derived roles, and a revision. The revision is a SHA-256 content fingerprint generated from sorted compact JSON before adding the revision field; consumers can treat it as an opaque change identifier. No wallpaper path, username, or machine identifier is included. The document is limited to 32 KiB when validated.

The internal `bin/r2-d2-theme-state` helper supports build/stage/check/activate operations. It is intentionally not a second public theme-selection interface: callers hold `$R2D2_PATH/.theme.lock` across render or sync. One helper centralizes schema, contrast derivation, validation, and atomic writes without a new daemon or package dependency. Python 3 with tomllib and flock are required on the Arch host.

Accent input must be a full `#RRGGBB` token. Case normalization follows validation; missing hashes, embedded whitespace, shortened colors, and extra characters are rejected. The renderer calls wallpaper extraction with `--print-only`, so failed rendering cannot write a new compatibility color early. The extractor's legacy no-argument mode still writes the compatibility file, but never activates theme.json.

Validation completes before rendering changes outputs. Before rendering starts, an older staged document is removed so a partial failure cannot leave an old document eligible for activation. Live state is replaced atomically only after all config copies succeed; unchanged content does not generate another write. Missing outputs, invalid schema/roles/revision, and live targets that are directories instead of files fail rather than silently report activation. A failed config copy can leave some live config files updated; it does not advance the consumer revision. This is not a transactional rollback of every desktop config file.

Text size still reapplies from the display state file after a render, as `r2-d2-theme-apply` does today.

## Publication

Cloud publication is opt-in and separate from rendering. `r2-d2-theme-sync-live` and `r2-d2-config-sync-live` call `r2-d2-theme-publish` only after `theme.json` is activated. The publisher returns immediately, and a failed publication does not roll back the wallpaper change or Brook's local read.

Without `${XDG_CONFIG_HOME:-$HOME/.config}/r2-d2/theme-publish.conf`, nothing is sent. Other R2-D2 installs do not publish to skyguy.dev. The file is mode `600` and stays out of Git:

```bash
enabled=true
endpoint=https://skyguy.dev/api/theme
token=
```

The token is the Cloudflare secret `THEME_PUBLISH_TOKEN` on the `portfolio-theme` worker. Create or rotate it with `wrangler secret put THEME_PUBLISH_TOKEN` from `portfolio/`, then replace the local `token=` value. Revoke access by putting a new secret or deleting it; the previous token stops working on the next request. Do not print the token, commit it, or put it in a browser bundle.

The publisher writes the newest desired document, holds one lock, and retries only that latest body. After a successful write it reads the public endpoint and records the revision in `theme-publish.confirmed`. An older retry cannot replace a newer revision. Network and authentication failures are logged in the state directory without the token. The initial worker route and the first live token still need SkyGuy's approval before this desktop starts publishing.

## Verification

Run from the repository root with TMPDIR pointing to a writable scratch directory:

```bash
python3 -m unittest discover -s tests -v
bash -n bin/r2-d2-theme-state
shellcheck bin/r2-d2-theme-state bin/r2-d2-theme-sync-live bin/r2-d2-config-sync-live bin/r2-d2-theme-accent-from-bg bin/r2-d2-theme-accent-apps bin/r2-d2-theme-publish
```

The suite isolates HOME, XDG_STATE_HOME, and R2D2_PATH. It exercises actual extraction (ImageMagick), rendering, file copies, schema/fixture checks, grayscale and missing-wallpaper fallback, invalid input, copy failures, idempotence, concurrent readers/writers, and derived accent roles in the rendered templates. Wallpaper process management and desktop reload are replaced with test-only stubs. It does not change the user's running session, test an actual compositor reload, or make network requests.

## Session review and rollback

Repository templates are updated. The running session is not. `r2-d2-update` copies Manrope into the user font directory, re-renders these templates from the current wallpaper, syncs config, and then asks before reloading the desktop.

After that reload, check the bar, Walker, Mako, SwayOSD, Hyprlock, a critical notification, a Nerd Font icon, and the text-size control. SDDM and Plymouth still need a login or boot check; they were not part of this render.

Rollback of the desktop styling is a revert of the template change, then `r2-d2-update` again, then the same reload prompt. That does not roll back the website. Website rollback is removing `theme-publish.conf` or rotating `THEME_PUBLISH_TOKEN`. With publication off, the site keeps its last valid theme or monochrome, and the desktop does not call Cloudflare.
