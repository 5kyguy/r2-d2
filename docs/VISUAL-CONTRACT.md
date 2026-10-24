# R2-D2 visual contract

Contract: `skyguy-visual` version **3**. Colors are a fixed palette in `config/theme/palette.toml`. The desktop is the authority: it looks up the named accent, builds the theme document, and publishes it; the portfolio site trusts the document and its revision without re-deriving the palette. Theme rendering stays inside the repo until an explicit apply or update. Do not write `~/.config/` or reload the session from theme work in progress.

## Derivation

`docs/palettes.html` shows one accent at a time. Wallpaper pixels snap to one of seven named accents in `config/theme/palette.toml`: Black, White, Cyan, Green, Red, Purple, and Gold. An explicit `#RRGGBB` that is not one of those sources snaps to the nearest named source by hue. A nearly gray color snaps to White when its luminance is at least 0.45, and to Black otherwise. Black (`#000000`) and White (`#FFFFFF`) use scheme `monochrome`. The other five use scheme `fixed`. R2-D2 stays dark, so templates render in **dark** mode only. The published document carries **both** dark and light palettes (the portfolio applies the light palette in light mode).

Black's snap source stays `#000000`. Its visible dark accent is `#FFFFFF`, with ink `#0A0A0A`. White's dark accent is also `#FFFFFF`, on a slightly different set of surfaces. Light-mode accents are the darker button colors in the same file. Danger `#FF2A4A`, on-danger `#2A0008`, warning `#FFB000`, and on-warning `#2A2100` are shared by every accent.

The portfolio does not re-derive colors. The desktop palette is the source of truth, and the worker validates the document's SHA-256 revision over the canonical body. `design/contrast.py` in the portfolio repo checks that contract.

## What the desktop takes

- Roles from the fixed palette: `accent`, `on_accent`, `deep`, `spark`, `on_spark`, `bg`, `surface`, `text`, `muted`, `line`, `danger`, `on_danger`, `warning`, and `on_warning`.
- Wallpaper source accent, validated as six-digit hex before templates render. The focused window border uses `accent`. The idle window border uses `line`.
- `danger` and `warning` are the critical and warning signals. `spark` is the second hue (none of the monochrome accents invent a second hue; their spark is the text color).
- Existing logo and icon files under `assets/`. White on dark surfaces, black on light. Silver and blue stay branding variants. They are PNG-in-SVG, so they do not inherit `currentColor`.
- JetBrainsMono Nerd Font for terminals, the shell, Walker, Alacritty, and zathura. Icon glyphs stay on that font. The variable font ships in `default/config/` because the AUR package's download returns 404. Hyprland blur and wallpaper treatment are unchanged.

R2-D2 stays dark. The light palette belongs to the document and the portfolio.

`r2-d2-theme-accent-from-bg` measures the wallpaper and prints the nearest named source. Filenames are ignored by the pixel snap. A pixel is vivid when saturation is at least 0.35 and value is at least 0.25. If vivid pixels are at least 2% of the frame, their hue picks Cyan, Green, Red, Purple, or Gold. Otherwise the image is achromatic: a 99th-percentile luminance of at least 0.45 is White, and anything darker is Black. A missing or unreadable wallpaper is White.

`backgrounds/accents.toml` pre-stores each wallpaper's accent, keyed by file name inside `backgrounds/`. `r2-d2-theme-bg-accents` backfills the store by snapping every image once; `--refresh` recomputes existing entries, and hand-curated values survive plain backfills. `r2-d2-theme-bg-set` applies the stored accent directly, so picking a listed wallpaper recolors the desktop with no pixel pass. Images without an entry, or picked from outside `backgrounds/`, fall back to the pixel snap.

## Surfaces in scope

Templates filled by `r2-d2-theme-apply` from the dark roles of the theme document (`config/theme/templates.toml`). Template paths resolve relative to the config file's directory, so the render works from any working directory:

| Template | Output |
| --- | --- |
| `hypr-looknfeel.lua` | `config/hypr/looknfeel.lua` |
| `shell-colors.toml` | `config/r2-d2/colors.toml` |
| `shell.toml` | `config/r2-d2/shell.toml` |
| `gtk.css` | `config/gtk-3.0/gtk.css` |
| `gtk4.css` | `config/gtk-4.0/gtk.css` |
| `alacritty.toml` | `config/alacritty/alacritty.toml` |
| `btop.theme` | `config/btop/themes/current.theme` |
| `starship.toml` | `config/starship.toml` |
| `walker.css` | `default/config/walker/themes/default/style.css` |
| `share-picker.css` | `default/config/hyprland-preview-share-picker/style.css` |
| `hermes-skin.yaml` | `config/theme/accent-apps/hermes-skin.yaml` |
| `opencode-theme.json` | `config/theme/accent-apps/opencode.json` |
| `zathurarc` | `config/zathura/zathurarc` |
| `sddm-palette.qml` | `default/sddm/r2-d2/Palette.qml` |

`gtk4.css` defines `accent_color`, `accent_bg_color`, and `accent_fg_color` only (mapped to `accent`/`on_accent`). Header bars, window backgrounds, and corner radius stay on the GTK theme.

`r2-d2-theme-sync-live` and `r2-d2-config-sync-live` place the other accent files after the repo render. They do not restart Hermes, OpenCode, or Qt.

- Hermes: `~/.hermes/skins/r2-d2.yaml` sets `ui_accent`, `banner_accent`, `response_border`, and `selection_bg` to the `accent` role. Every other color stays on the built-in default skin. `display.skin` becomes `r2-d2`.
- OpenCode: `~/.config/opencode/themes/opencode.json` is the built-in OpenCode palette with `darkAccent` and `lightAccent` replaced by the `accent` role. `darkStep9` stays `#fab283`. The theme name stays `opencode`, so `tui.json` and `opencode.json` are left alone.
- Kvantum: when `/usr/share/Kvantum/KvDark` is installed, a clone named `r2-d2` changes highlight and link colors to the `accent` role, and `kvantum.kvconfig` selects that clone. KvDark uses the same window color as Kvantum's builtin default.
- zathura: `~/.config/zathura/zathurarc` follows the wallpaper live (synced by `r2-d2-theme-sync-live` alongside the other config files).

A running Hermes, OpenCode, or Qt process keeps its previous accent until the next launch.

SDDM (`default/sddm/r2-d2/`) is system-managed. `Main.qml` consumes a `Palette` QtObject rendered into `default/sddm/r2-d2/Palette.qml`. A fallback `Palette.qml` is committed so the import never breaks before the first apply. SDDM is deployed by `r2-d2-refresh-sddm` at install/update only — it follows updates and migrations, **not** every wallpaper change (SDDM runs before the user session and cannot read live state). Plymouth (`default/plymouth/`) remains system-managed and is not recolored by this pass.

The rendered templates use the fixed roles. Lock-screen and prompt text use `text`. The focused border uses `accent` and the idle border uses `line`. Critical notifications and the shell error mark use `danger`. Warning notifications use `warning`. ANSI slots that follow the accent stay on `accent` or `deep`.

## Out of scope

Chromium, Brave, VS Code, Steam, Spotify, and icon themes. Cursor keeps its default color scheme. GTK 4, Kvantum, Hermes, and OpenCode take the wallpaper accent and keep their own surfaces. K-2SO is a separate project. Menu behavior stays as documented in `docs/MENU.md` and `docs/INSTALL.md`.

## State

State lives under `${XDG_STATE_HOME:-$HOME/.local/state}/r2-d2/`. When the new state directory has no compatibility file, the renderer can read the legacy `~/.local/state/r2-d2/theme-accent`. New writes use the configured directory.

| File | Meaning | Writer |
| --- | --- | --- |
| `$R2D2_PATH/.theme-state.json` | Last successful repository render, not yet necessarily selected for the desktop | `r2-d2-theme-apply` |
| `theme-accent` in the state directory | Compatibility color from the last successful render | Internal state helper after rendering |
| `theme.json` in the state directory | Versioned theme selected by the last successful explicit live-config sync | `r2-d2-theme-sync-live` or `r2-d2-config-sync-live` |

Consumers such as Brook must read **theme.json**, not the staged document or compatibility file. Repository-only renders do not advance this consumer document, publish to the website, or reload the desktop. A successful config sync may precede a user-approved desktop reload during update; the document describes selected configuration, not proof that every running process has reloaded it.

The document contains schema `version: 3`, `contract: skyguy-visual`, `contract_version: 3`, the `source` accent, the `scheme` (`fixed` or `monochrome`), a `colors` object with `dark` and `light` maps of the fixed roles (uppercase `#RRGGBB`), and a `revision`. The revision is a SHA-256 fingerprint over the canonical sorted-compact JSON body **excluding** the `revision` field; consumers can treat it as an opaque change identifier. The portfolio worker recomputes that fingerprint to validate the document **without re-deriving the colors**. No wallpaper path, username, or machine identifier is included. The document is limited to 32 KiB when validated.

The internal `bin/r2-d2-theme-state` helper supports build/render/stage/check/activate operations. `build` looks up the named accent and emits the document; `render` fills the templates from that document's dark roles; `stage`/`check`/`activate` validate the schema, the colors, and the revision-over-body, and confirm every required rendered output exists before a live sync copies anything. It is intentionally not a second public theme-selection interface: callers hold `$R2D2_PATH/.theme.lock` across render or sync. One helper centralizes schema, palette lookup, validation, and atomic writes without a new daemon or package dependency. Python 3 and flock are required on the Arch host.

Accent input must be a full `#RRGGBB` token. Case normalization follows validation; missing hashes, embedded whitespace, shortened colors, and extra characters are rejected. The renderer calls `r2-d2-theme-accent-from-bg --print-only`, so a failed render cannot write a new compatibility color early. The matcher's no-argument mode still writes the compatibility file, but never activates theme.json.

Validation (build) completes before rendering changes outputs. The previously staged document is removed only after a successful build, so a failed validation preserves it while a failed render still clears it (a partial render cannot leave an old document eligible for activation). Live state is replaced atomically only after all config copies succeed; unchanged content does not generate another write. Missing outputs, invalid schema/roles/revision, and live targets that are directories instead of files fail rather than silently report activation. A failed config copy can leave some live config files updated; it does not advance the consumer revision. This is not a transactional rollback of every desktop config file.

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
bash -n bin/r2-d2-theme-state bin/r2-d2-theme-apply
shellcheck bin/r2-d2-theme-state bin/r2-d2-theme-apply bin/r2-d2-theme-sync-live bin/r2-d2-config-sync-live bin/r2-d2-theme-accent-from-bg bin/r2-d2-theme-accent-apps bin/r2-d2-theme-bg-set bin/r2-d2-theme-bg-accents bin/r2-d2-theme-publish
```

The suite isolates HOME, XDG_STATE_HOME, and R2D2_PATH. It builds documents from `config/theme/palette.toml`, checks each named accent against that file, and fills real templates from those documents. It exercises actual wallpaper snaps (ImageMagick), rendering, file copies, schema checks, achromatic and missing-wallpaper snaps, invalid input, copy failures, idempotence, concurrent readers/writers, and the fixed roles in the rendered templates (including zathura and the SDDM palette). Wallpaper process management and desktop reload are replaced with test-only stubs. It does not change the user's running session, test an actual compositor reload, or make network requests.

## Session review and rollback

Repository templates are updated. The running session is not. `r2-d2-update` copies Manrope into the user font directory, re-renders these templates from the current wallpaper, syncs config, and then asks before reloading the desktop.

After that reload, check the bar, Walker, the on-screen display, the lock screen, a critical notification, a Nerd Font icon, the text-size control, and zathura. SDDM still needs a login or boot check; it is recolored by `r2-d2-refresh-sddm` at update, not by the wallpaper render. Plymouth was not part of this pass.

Rollback of the desktop styling is a revert of the template change, then `r2-d2-update` again, then the same reload prompt. That does not roll back the website. Website rollback is removing `theme-publish.conf` or rotating `THEME_PUBLISH_TOKEN`. With publication off, the site keeps its last valid theme or monochrome, and the desktop does not call Cloudflare.
