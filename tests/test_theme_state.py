"""Isolated integration tests: never use the real home or running desktop.

These tests exercise the v3 skyguy-visual theme contract. Colors come from the
fixed palette in config/theme/palette.toml. The desktop renders templates in
dark mode only, and the published theme document carries the dark + light role
set plus a SHA-256 revision over the canonical body.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib
import unittest

REPO = Path(__file__).resolve().parents[1]


class ThemeStateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='r2d2-theme-', dir=os.environ['TMPDIR'])
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.home = self.root / 'home'
        self.home.mkdir()
        (self.repo / 'bin').mkdir(parents=True)
        for script in REPO.joinpath('bin').glob('r2-d2-theme-*'):
            shutil.copy2(script, self.repo / 'bin' / script.name)
        shutil.copy2(REPO / 'bin/r2-d2-config-sync-live', self.repo / 'bin')
        shutil.copytree(REPO / 'config/theme', self.repo / 'config/theme')
        self.env = dict(os.environ, HOME=str(self.home), R2D2_PATH=str(self.repo),
                        XDG_STATE_HOME=str(self.root / 'state'),
                        PATH=str(self.repo / 'bin') + ':' + os.environ['PATH'])
        self.state = self.root / 'state/r2-d2'

    def run_script(self, name, *args):
        return subprocess.run(['bash', str(self.repo / 'bin' / name), *args],
                              env=self.env, text=True, capture_output=True, timeout=15)

    def apply(self, accent='#00E5FF'):
        result = self.run_script('r2-d2-theme-apply', '--accent', accent)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_render_stages_document_without_activating_or_touching_live_config(self):
        self.apply('#00e5ff')
        staged = self.repo / '.theme-state.json'
        self.assertTrue(staged.is_file(), 'Successful render must stage a versioned document')
        data = json.loads(staged.read_text())
        self.assertEqual(data['version'], 3)
        self.assertEqual(data['contract'], 'skyguy-visual')
        self.assertEqual(data['contract_version'], 3)
        self.assertEqual(data['source'], '#00E5FF')
        self.assertEqual(data['scheme'], 'fixed')
        self.assertEqual(data['colors']['dark']['accent'], '#00E5FF')
        self.assertEqual(data['colors']['dark']['bg'], '#061216')
        self.assertEqual(data['colors']['light']['accent'], '#007A96')
        self.assertRegex(data['revision'], r'^[0-9a-f]{64}$')
        self.assertEqual((self.state / 'theme-accent').read_text().strip(), '#00E5FF')
        self.assertFalse((self.state / 'theme.json').exists())
        self.assertFalse((self.home / '.config').exists())

    def test_explicit_sync_activates_staged_document_and_is_idempotent(self):
        self.apply()
        for command in ('r2-d2-theme-sync-live', 'r2-d2-config-sync-live'):
            with self.subTest(command=command):
                result = self.run_script(command)
                self.assertEqual(result.returncode, 0, result.stderr)
                active = self.state / 'theme.json'
                self.assertTrue(active.is_file(), 'Successful explicit sync must activate theme.json')
                self.assertEqual(active.read_bytes(), (self.repo / '.theme-state.json').read_bytes())
                before = active.stat().st_mtime_ns
                result = self.run_script(command)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(active.stat().st_mtime_ns, before)
                self.assertTrue((self.home / '.config/hypr/looknfeel.lua').is_file())

    def test_failed_background_render_preserves_active_and_compatibility_state(self):
        self.apply()
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        before = (self.state / 'theme.json').read_bytes()
        (self.repo / 'config/theme/templates/share-picker.css').unlink()
        result = self.run_script('r2-d2-theme-apply', '--from-background')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.state / 'theme-accent').read_text().strip(), '#00E5FF')
        self.assertFalse((self.repo / '.theme-state.json').exists(), 'Partial render must not remain activatable')
        self.assertNotEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        self.assertEqual((self.state / 'theme.json').read_bytes(), before)
        self.assertFalse((self.home / '.local/state/r2-d2/theme-accent').exists(), 'Extraction must not write legacy state early')

    def test_invalid_explicit_accent_never_changes_rendered_files(self):
        self.apply()
        before = (self.repo / '.theme-state.json').read_bytes()
        config = (self.repo / 'config/hypr/looknfeel.lua').read_bytes()
        for accent in ('', 'abc123', '#abc', '#12345678', '#GGGGGG', ' #123456'):
            with self.subTest(accent=accent):
                result = self.run_script('r2-d2-theme-apply', '--accent', accent)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual((self.repo / '.theme-state.json').read_bytes(), before)
                self.assertEqual((self.repo / 'config/hypr/looknfeel.lua').read_bytes(), config)
        result = self.run_script('r2-d2-theme-apply', '--accent', '#123456', '--from-state')
        self.assertNotEqual(result.returncode, 0, 'Conflicting selectors must not silently pick one')

    def test_invalid_persisted_accent_is_not_repaired(self):
        self.apply()
        staged = (self.repo / '.theme-state.json').read_bytes()
        for value in ('#12 3456\n', '#123456 extra\n', '#123\n456\n', ' #123456\n'):
            with self.subTest(value=value):
                (self.state / 'theme-accent').write_text(value)
                result = self.run_script('r2-d2-theme-apply', '--from-state')
                self.assertNotEqual(result.returncode, 0, 'Stored tokens must be validated, not repaired')
                self.assertEqual((self.repo / '.theme-state.json').read_bytes(), staged)

    def test_legacy_accent_is_read_when_xdg_state_is_new(self):
        legacy = self.home / '.local/state/r2-d2/theme-accent'
        legacy.parent.mkdir(parents=True)
        legacy.write_text('#00F59A\n')
        result = self.run_script('r2-d2-theme-apply', '--from-state')
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads((self.repo / '.theme-state.json').read_text())
        self.assertEqual(data['source'], '#00F59A')
        self.assertEqual((self.state / 'theme-accent').read_text(), '#00F59A\n')

    def test_sync_rejects_tampered_schema_and_missing_outputs_before_copying(self):
        self.apply()
        path = self.repo / '.theme-state.json'
        valid = path.read_text()
        data = json.loads(valid)
        data['version'] = True
        path.write_text(json.dumps(data))
        for command in ('r2-d2-theme-sync-live', 'r2-d2-config-sync-live'):
            with self.subTest(command=command, failure='schema'):
                self.assertNotEqual(self.run_script(command).returncode, 0)
                self.assertFalse((self.home / '.config').exists())
        path.write_text(valid)
        (self.repo / 'config/hypr/looknfeel.lua').unlink()
        for command in ('r2-d2-theme-sync-live', 'r2-d2-config-sync-live'):
            with self.subTest(command=command, failure='missing-output'):
                self.assertNotEqual(self.run_script(command).returncode, 0)
                self.assertFalse((self.home / '.config').exists())
        self.assertFalse((self.state / 'theme.json').exists())

    def test_every_named_accent_matches_the_palette(self):
        palette = tomllib.loads((REPO / 'config/theme/palette.toml').read_text())
        signals = {role: palette[role].upper() for role in ('danger', 'on_danger', 'warning', 'on_warning')}
        shared_light = {role: palette['light'][role].upper() for role in ('bg', 'surface', 'text', 'muted')}
        for name, item in palette['accents'].items():
            with self.subTest(accent=name):
                result = self.run_script('r2-d2-theme-state', 'build', item['source'])
                self.assertEqual(result.returncode, 0, result.stderr)
                doc = json.loads(result.stdout)
                self.assertEqual(doc['scheme'], item['scheme'])
                self.assertEqual(doc['source'], item['source'].upper())
                for role, color in item['dark'].items():
                    self.assertEqual(doc['colors']['dark'][role], color.upper())
                self.assertEqual({role: doc['colors']['dark'][role] for role in signals}, signals)
                for role, color in item['light'].items():
                    self.assertEqual(doc['colors']['light'][role], color.upper())
                self.assertEqual({role: doc['colors']['light'][role] for role in shared_light}, shared_light)
        snapped = self.run_script('r2-d2-theme-state', 'build', '#1D4ED8')
        self.assertEqual(snapped.returncode, 0, snapped.stderr)
        self.assertEqual(json.loads(snapped.stdout)['source'], '#00E5FF')

    def test_named_monochrome_accents(self):
        white = self.run_script('r2-d2-theme-state', 'build', '#FFFFFF')
        self.assertEqual(white.returncode, 0, white.stderr)
        white_doc = json.loads(white.stdout)
        self.assertEqual(white_doc['scheme'], 'monochrome')
        self.assertEqual(white_doc['colors']['dark']['accent'], '#FFFFFF')

        black = self.run_script('r2-d2-theme-state', 'build', '#000000')
        self.assertEqual(black.returncode, 0, black.stderr)
        black_doc = json.loads(black.stdout)
        dark = black_doc['colors']['dark']
        light = black_doc['colors']['light']
        self.assertEqual(black_doc['scheme'], 'monochrome')
        self.assertEqual(black_doc['source'], '#000000')
        self.assertEqual(dark['accent'], '#FFFFFF')
        self.assertEqual(dark['on_accent'], '#0A0A0A')
        self.assertEqual(dark['deep'], '#2A2A2A')
        self.assertEqual(light['accent'], '#111111')
        self.assertEqual(light['on_accent'], '#FFFFFF')
        self.assertEqual(light['line'], '#6E6E6E')

        self.apply('#000000')
        colors = (self.repo / 'config/r2-d2/colors.toml').read_text()
        self.assertIn('accent = "#ffffff"', colors)

    def test_first_install_without_xdg_or_wallpaper_uses_fallback(self):
        self.env.pop('XDG_STATE_HOME')
        result = self.run_script('r2-d2-theme-apply', '--from-state')
        self.assertEqual(result.returncode, 0, result.stderr)
        legacy = self.home / '.local/state/r2-d2'
        self.assertEqual((legacy / 'theme-accent').read_text(), '#FFFFFF\n')
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        document = json.loads((legacy / 'theme.json').read_text())
        self.assertEqual(document['source'], '#FFFFFF')
        self.assertEqual(document['scheme'], 'monochrome')

    def test_failed_copy_does_not_advance_active_revision(self):
        self.apply()
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        active = self.state / 'theme.json'
        before = active.read_bytes()
        self.apply('#F5E642')
        self.assertEqual(active.read_bytes(), before, 'Rendering must not activate')
        target = self.home / '.config/starship.toml'
        target.unlink()
        target.mkdir()
        (target / 'starship.toml').mkdir()
        result = self.run_script('r2-d2-theme-sync-live')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(active.read_bytes(), before)

    def test_sync_rejects_directory_where_a_live_file_should_be(self):
        for command in ('r2-d2-theme-sync-live', 'r2-d2-config-sync-live'):
            for relative in ('starship.toml', 'walker/themes/default/style.css',
                             'hyprland-preview-share-picker/style.css'):
                with self.subTest(command=command, target=relative):
                    self.apply()
                    self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
                    active = self.state / 'theme.json'
                    before = active.read_bytes()
                    self.apply('#F5E642')
                    target = self.home / '.config' / relative
                    target.unlink()
                    target.mkdir()
                    try:
                        result = self.run_script(command)
                        self.assertNotEqual(result.returncode, 0, 'cp must not silently nest a file inside a directory')
                        self.assertEqual(active.read_bytes(), before)
                        self.assertFalse((target / target.name).exists())
                    finally:
                        shutil.rmtree(target)

    def test_wallpaper_flow_extracts_and_activates_before_reload(self):
        wallpaper = self.root / 'sample.ppm'
        wallpaper.write_text('P3\n1 1\n255\n29 78 216\n')
        # Only desktop side effects are replaced; extraction/render/copy/state are real.
        for name in ('pkill', 'setsid'):
            stub = self.repo / 'bin' / name
            stub.write_text('#!/bin/bash\nexit 0\n')
            stub.chmod(0o755)
        reload = self.repo / 'bin/r2-d2-theme-reload'
        reload.write_text(
            '#!/bin/bash\nset -euo pipefail\n'
            'test -f "$XDG_STATE_HOME/r2-d2/theme.json"\n'
            'printf "%s" "$1" > "$HOME/reload-accent"\n')
        result = self.run_script('r2-d2-theme-bg-set', str(wallpaper))
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads((self.state / 'theme.json').read_text())
        self.assertEqual(data['source'], '#00E5FF')
        self.assertEqual(data['scheme'], 'fixed')
        self.assertEqual((self.home / 'reload-accent').read_text(), '#00E5FF')
        self.assertEqual((self.repo / 'backgrounds/@background').resolve(), wallpaper)
        self.assertTrue((self.home / '.config/hypr/looknfeel.lua').is_file())

    def test_achromatic_snaps_do_not_write_state(self):
        backgrounds = self.repo / 'backgrounds'
        backgrounds.mkdir()
        wallpaper = self.root / 'gray.ppm'
        link = backgrounds / '@background'
        cases = (
            ('200 200 200', '#FFFFFF'),
            ('20 20 20', '#000000'),
        )
        for pixel, expected in cases:
            with self.subTest(pixel=pixel):
                wallpaper.write_text(f'P3\n1 1\n255\n{pixel}\n')
                link.unlink(missing_ok=True)
                link.symlink_to(wallpaper)
                result = self.run_script('r2-d2-theme-accent-from-bg', '--print-only')
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), expected)
                self.assertFalse(self.state.exists())
                self.assertFalse((self.repo / '.theme-state.json').exists())

    def test_red_on_black_snaps_to_red(self):
        rows = []
        for y in range(8):
            for x in range(8):
                rows.append('198 40 40' if x < 2 and y < 2 else '0 0 0')
        wallpaper = self.root / 'red.ppm'
        wallpaper.write_text('P3\n8 8\n255\n' + '\n'.join(rows) + '\n')
        backgrounds = self.repo / 'backgrounds'
        backgrounds.mkdir()
        (backgrounds / '@background').symlink_to(wallpaper)
        result = self.run_script('r2-d2-theme-accent-from-bg', '--print-only')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), '#FF2A4A')

    def test_concurrent_renders_and_readers_observe_complete_documents(self):
        import threading
        self.apply()
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        failures = []
        observations = []
        stop = threading.Event()
        def observe():
            while not stop.is_set():
                try:
                    data = json.loads((self.state / 'theme.json').read_text())
                    observations.append(data['source'])
                    self.assertEqual(data['colors']['dark']['accent'], data['source'])
                except Exception as error:
                    failures.append(str(error))
        reader = threading.Thread(target=observe)
        reader.start()
        try:
            processes = [subprocess.Popen(
                ['bash', str(self.repo / 'bin/r2-d2-theme-apply'), '--accent', accent],
                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                for accent in ('#FFD000', '#00F59A', '#00E5FF')]
            for process in processes:
                _, error = process.communicate(timeout=15)
                self.assertEqual(process.returncode, 0, error)
                self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        finally:
            stop.set()
            reader.join(timeout=5)
        self.assertTrue(observations)
        self.assertEqual(failures, [])
        self.assertEqual((self.state / 'theme.json').read_bytes(), (self.repo / '.theme-state.json').read_bytes())


    def test_rendered_templates_use_derived_roles(self):
        self.apply('#00E5FF')
        document = json.loads((self.repo / '.theme-state.json').read_text())
        dark = document['colors']['dark']
        primary = dark['accent'].lower().lstrip('#')
        outline = dark['line'].lower().lstrip('#')
        on_primary = dark['on_accent'].lower().lstrip('#')
        background = dark['bg'].lower().lstrip('#')

        # Quickshell surfaces consume colors.toml; the desktop stays dark.
        colors = (self.repo / 'config/r2-d2/colors.toml').read_text()
        self.assertIn(f'accent = "#{primary}"', colors)
        self.assertIn(f'background = "#{background}"', colors)

        look = (self.repo / 'config/hypr/looknfeel.lua').read_text()
        self.assertIn(f'rgb({outline})', look)
        self.assertNotIn('{{', look)

        walker = (self.repo / 'default/config/walker/themes/default/style.css').read_text()
        for leftover in ('#EAEAEA', '#5e5e5e', '#fffffaaa'):
            self.assertNotIn(leftover, walker)
        self.assertIn('JetBrainsMono Nerd Font', walker)
        self.assertNotIn('{{', walker)

        zathura = (self.repo / 'config/zathura/zathurarc').read_text()
        self.assertIn('JetBrainsMono Nerd Font', zathura)
        self.assertNotIn('{{', zathura)

        palette = (self.repo / 'default/sddm/r2-d2/Palette.qml').read_text()
        self.assertIn(f'property color primary: "#{primary}"', palette)
        self.assertIn(f'property color background: "#{background}"', palette)
        self.assertIn(f'property color outline: "#{outline}"', palette)
        self.assertNotIn('{{', palette)

        starship = (self.repo / 'config/starship.toml').read_text()
        self.assertIn('bold #ff2a4a', starship)
        self.assertIn(f'bold #{on_primary}', starship)
        self.assertNotIn('{{', starship)

        alacritty = (self.repo / 'config/alacritty/alacritty.toml').read_text()
        self.assertNotIn('#bebebe', alacritty)
        self.assertNotIn('#333333', alacritty)
        self.assertNotIn('{{', alacritty)

        for rendered in (
            self.repo / 'config/hypr/looknfeel.lua',
            self.repo / 'config/r2-d2/colors.toml',
            self.repo / 'default/config/walker/themes/default/style.css',
            self.repo / 'config/zathura/zathurarc',
            self.repo / 'default/sddm/r2-d2/Palette.qml',
        ):
            self.assertNotIn('{{', rendered.read_text())

        gtk4 = (self.repo / 'config/gtk-4.0/gtk.css').read_text()
        self.assertIn(f'@define-color accent_bg_color #{primary};', gtk4)
        self.assertNotIn('window_bg_color', gtk4)
        self.assertNotIn('{{', gtk4)
        hermes = (self.repo / 'config/theme/accent-apps/hermes-skin.yaml').read_text()
        self.assertIn(f'ui_accent: "#{primary}"', hermes)
        self.assertNotIn('status_bar_bg', hermes)
        self.assertNotIn('{{', hermes)
        opencode = json.loads((self.repo / 'config/theme/accent-apps/opencode.json').read_text())
        self.assertEqual(opencode['defs']['darkAccent'], f'#{primary}')
        self.assertEqual(opencode['defs']['lightAccent'], f'#{primary}')
        self.assertEqual(opencode['defs']['darkStep9'], '#fab283')
        self.assertNotIn('#9d7cd8', json.dumps(opencode))

    def test_sync_merges_accent_without_replacing_app_themes(self):
        kvantum = self.root / 'kvantum'
        kvantum.mkdir()
        (kvantum / 'theme.kvconfig').write_text(
            "[GeneralColors]\n"
            "window.color=#353535\n"
            "highlight.color=#15539e\n"
            "inactive.highlight.color=#15539e\n"
            "link.color=#2EB8E6\n"
            "highlight.text.color=white\n"
        )
        (kvantum / 'theme.svg').write_text("<svg/>\n")
        self.env['R2D2_KVANTUM_SRC'] = str(kvantum)
        hermes = self.home / '.hermes'
        hermes.mkdir()
        (hermes / 'config.yaml').write_text("display:\n  compact: false\n  skin: default\n\nother: 1\n")
        cursor = self.home / '.config/Cursor/User/settings.json'
        cursor.parent.mkdir(parents=True)
        cursor.write_text(json.dumps({
            "editor.fontSize": 14,
            "workbench.colorTheme": "Default Dark+",
            "workbench.colorCustomizations": {"editor.background": "#111111"},
        }, indent=2) + "\n")
        opencode = self.home / '.config/opencode/opencode.json'
        opencode.parent.mkdir(parents=True)
        original = '{"mcp":{"r2d2":{"enabled":true}}}\n'
        opencode.write_text(original)
        active = self.home / '.config/Kvantum/kvantum.kvconfig'
        active.parent.mkdir(parents=True)
        active.write_text("[General]\ntheme=KvGnomeDark\n\n[Applications]\nfoo=1\n")

        self.apply('#00E5FF')
        self.assertFalse((self.home / '.hermes/skins/r2-d2.yaml').exists())
        original_cursor = cursor.read_text()
        for command in ('r2-d2-theme-sync-live', 'r2-d2-config-sync-live'):
            with self.subTest(command=command):
                result = self.run_script(command)
                self.assertEqual(result.returncode, 0, result.stderr)

        primary = '#00e5ff'
        self.assertEqual((self.home / '.config/gtk-4.0/gtk.css').read_text(),
                         (self.repo / 'config/gtk-4.0/gtk.css').read_text())
        self.assertEqual((hermes / 'skins/r2-d2.yaml').read_text(),
                         (self.repo / 'config/theme/accent-apps/hermes-skin.yaml').read_text())
        hermes_config = (hermes / 'config.yaml').read_text()
        self.assertIn('skin: r2-d2\n', hermes_config)
        self.assertIn('compact: false\n', hermes_config)
        self.assertIn('other: 1\n', hermes_config)
        theme = json.loads((self.home / '.config/opencode/themes/opencode.json').read_text())
        self.assertEqual(theme['defs']['darkAccent'], primary)
        self.assertEqual(theme['defs']['darkStep9'], '#fab283')
        self.assertFalse((self.home / '.config/opencode/tui.json').exists())
        self.assertEqual(opencode.read_text(), original)
        self.assertEqual(cursor.read_text(), original_cursor,
                         'Cursor settings must stay untouched; Cursor is off the accent schema')
        cloned = (self.home / '.config/Kvantum/r2-d2/r2-d2.kvconfig').read_text()
        self.assertIn(f'highlight.color={primary}\n', cloned)
        self.assertIn(f'link.color={primary}\n', cloned)
        self.assertIn('window.color=#353535\n', cloned)
        self.assertEqual((self.home / '.config/Kvantum/r2-d2/r2-d2.svg').read_text(), '<svg/>\n')
        selected = active.read_text()
        self.assertIn('theme=r2-d2\n', selected)
        self.assertIn('foo=1\n', selected)

        before = (
            (hermes / 'config.yaml').stat().st_mtime_ns,
            cursor.stat().st_mtime_ns,
            active.stat().st_mtime_ns,
        )
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        after = (
            (hermes / 'config.yaml').stat().st_mtime_ns,
            cursor.stat().st_mtime_ns,
            active.stat().st_mtime_ns,
        )
        self.assertEqual(after, before)

    def test_invalid_cursor_settings_do_not_block_sync(self):
        cursor = self.home / '.config/Cursor/User/settings.json'
        cursor.parent.mkdir(parents=True)
        cursor.write_text('{')
        self.apply()
        result = self.run_script('r2-d2-theme-sync-live')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(cursor.read_text(), '{')
        self.assertTrue((self.state / 'theme.json').is_file())

    def test_bg_set_applies_the_stored_accent_without_measuring_pixels(self):
        backgrounds = self.repo / 'backgrounds'
        backgrounds.mkdir()
        # Black pixels would snap to #000000 if the image were measured.
        wallpaper = backgrounds / 'preset.png'
        wallpaper.write_text('P3\n1 1\n255\n0 0 0\n')
        (backgrounds / 'accents.toml').write_text('"preset.png" = "#00E5FF"\n')
        for name in ('pkill', 'setsid'):
            stub = self.repo / 'bin' / name
            stub.write_text('#!/bin/bash\nexit 0\n')
            stub.chmod(0o755)
        reload = self.repo / 'bin/r2-d2-theme-reload'
        reload.write_text(
            '#!/bin/bash\nset -euo pipefail\n'
            'printf "%s" "$1" > "$HOME/reload-accent"\n')
        result = self.run_script('r2-d2-theme-bg-set', str(wallpaper))
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads((self.state / 'theme.json').read_text())
        self.assertEqual(data['source'], '#00E5FF')
        self.assertEqual((self.home / 'reload-accent').read_text(), '#00E5FF')
        self.assertTrue((self.home / '.config/hypr/looknfeel.lua').is_file())

    def test_bg_accents_backfills_preserves_and_refreshes(self):
        backgrounds = self.repo / 'backgrounds'
        backgrounds.mkdir()
        rows = []
        for y in range(8):
            for x in range(8):
                rows.append('198 40 40' if x < 2 and y < 2 else '0 0 0')
        (backgrounds / 'red.ppm').write_text('P3\n8 8\n255\n' + '\n'.join(rows) + '\n')
        (backgrounds / 'gray.ppm').write_text('P3\n1 1\n255\n200 200 200\n')

        result = self.run_script('r2-d2-theme-bg-accents')
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = (backgrounds / 'accents.toml').read_text()
        self.assertIn('"red.ppm" = "#FF2A4A"', manifest)
        self.assertIn('"gray.ppm" = "#FFFFFF"', manifest)

        (backgrounds / 'accents.toml').write_text(
            manifest.replace('"red.ppm" = "#FF2A4A"', '"red.ppm" = "#00F59A"'))
        result = self.run_script('r2-d2-theme-bg-accents')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"red.ppm" = "#00F59A"',
                      (backgrounds / 'accents.toml').read_text(),
                      'Hand-curated entries must survive a backfill')

        result = self.run_script('r2-d2-theme-bg-accents', '--refresh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('"red.ppm" = "#FF2A4A"',
                      (backgrounds / 'accents.toml').read_text(),
                      '--refresh must recompute every entry')


if __name__ == '__main__':
    unittest.main()
