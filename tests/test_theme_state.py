"""Isolated integration tests: never use the real home or running desktop."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
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

    def apply(self, accent='#1D4ED8'):
        result = self.run_script('r2-d2-theme-apply', '--accent', accent)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_render_stages_document_without_activating_or_touching_live_config(self):
        self.apply('#1d4ed8')
        staged = self.repo / '.theme-state.json'
        self.assertTrue(staged.is_file(), 'Successful render must stage a versioned document')
        data = json.loads(staged.read_text())
        self.assertEqual(data['version'], 1)
        self.assertEqual(data['accent']['source'], '#1D4ED8')
        self.assertEqual(data['accent']['dark']['text'], '#5A7EE3')
        self.assertEqual(data['palette']['background'], '#121212')
        self.assertRegex(data['revision'], r'^[0-9a-f]{64}$')
        self.assertEqual((self.state / 'theme-accent').read_text().strip(), '#1D4ED8')
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
        (self.repo / 'config/theme/templates/share-picker.css.in').unlink()
        result = self.run_script('r2-d2-theme-apply', '--from-background')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.state / 'theme-accent').read_text().strip(), '#1D4ED8')
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
        legacy.write_text('#0B3D2E\n')
        result = self.run_script('r2-d2-theme-apply', '--from-state')
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads((self.repo / '.theme-state.json').read_text())
        self.assertEqual(data['accent']['source'], '#0B3D2E')
        self.assertEqual((self.state / 'theme-accent').read_text(), '#0B3D2E\n')

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

    def test_fixture_parity_for_every_supported_sample(self):
        fixture = json.loads((REPO / 'docs/fixtures/contrast-v1.json').read_text())
        for name, modes in fixture['samples'].items():
            with self.subTest(sample=name):
                result = self.run_script('r2-d2-theme-state', 'build', modes['dark']['source'])
                self.assertEqual(result.returncode, 0, result.stderr)
                accent = json.loads(result.stdout)['accent']
                for mode in ('dark', 'light'):
                    self.assertEqual(accent[mode], modes[mode])

    def test_first_install_without_xdg_or_wallpaper_uses_fallback(self):
        self.env.pop('XDG_STATE_HOME')
        result = self.run_script('r2-d2-theme-apply', '--from-state')
        self.assertEqual(result.returncode, 0, result.stderr)
        legacy = self.home / '.local/state/r2-d2'
        self.assertEqual((legacy / 'theme-accent').read_text(), '#EAEAEA\n')
        self.assertEqual(self.run_script('r2-d2-theme-sync-live').returncode, 0)
        self.assertEqual(json.loads((legacy / 'theme.json').read_text())['accent']['source'], '#EAEAEA')

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
        self.assertEqual(data['accent']['source'], '#1D4ED8')
        self.assertEqual((self.home / 'reload-accent').read_text(), '#1D4ED8')
        self.assertEqual((self.repo / 'backgrounds/@background').resolve(), wallpaper)
        self.assertTrue((self.home / '.config/hypr/looknfeel.lua').is_file())

    def test_grayscale_extraction_print_only_does_not_write_state(self):
        wallpaper = self.root / 'gray.ppm'
        wallpaper.write_text('P3\n1 1\n255\n128 128 128\n')
        backgrounds = self.repo / 'backgrounds'
        backgrounds.mkdir()
        (backgrounds / '@background').symlink_to(wallpaper)
        result = self.run_script('r2-d2-theme-accent-from-bg', '--print-only')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), '#EAEAEA')
        self.assertFalse(self.state.exists())
        self.assertFalse((self.repo / '.theme-state.json').exists())

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
                    observations.append(data['accent']['source'])
                    self.assertEqual(data['accent']['dark']['source'], data['accent']['source'])
                except Exception as error:
                    failures.append(str(error))
        reader = threading.Thread(target=observe)
        reader.start()
        try:
            processes = [subprocess.Popen(
                ['bash', str(self.repo / 'bin/r2-d2-theme-apply'), '--accent', accent],
                env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                for accent in ('#F5E642', '#0B3D2E', '#1D4ED8')]
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
        self.apply('#1D4ED8')
        document = json.loads((self.repo / '.theme-state.json').read_text())
        dark = document['accent']['dark']
        text = dark['text'].lstrip('#')
        red, green, blue = int(text[0:2], 16), int(text[2:4], 16), int(text[4:6], 16)
        hyprlock = (self.repo / 'config/hypr/hyprlock.conf').read_text()
        self.assertIn(f'$font_color    = rgba({red}, {green}, {blue}, 1.0)', hyprlock)
        look = (self.repo / 'config/hypr/looknfeel.lua').read_text()
        self.assertIn(f'rgb({dark["border"].lstrip("#")})', look)
        walker = (self.repo / 'default/config/walker/themes/default/style.css').read_text()
        for leftover in ('#EAEAEA', '#5e5e5e', '#fffffaaa'):
            self.assertNotIn(leftover, walker)
        self.assertIn('JetBrainsMono Nerd Font', walker)
        waybar = (self.repo / 'config/waybar/waybar.css').read_text()
        self.assertNotIn('#636e72', waybar)
        self.assertIn(dark['border'], waybar)
        mako = (self.repo / 'config/mako/config').read_text()
        self.assertIn('font=Manrope 12', mako)
        self.assertIn(f'border-color={dark["border"]}', mako)
        self.assertIn('text-color=#D25E5E', mako)
        starship = (self.repo / 'config/starship.toml').read_text()
        self.assertIn('bold #D25E5E', starship)
        alacritty = (self.repo / 'config/alacritty/alacritty.toml').read_text()
        self.assertNotIn('#bebebe', alacritty)
        self.assertNotIn('#333333', alacritty)
        for rendered in (
            self.repo / 'config/hypr/hyprlock.conf',
            self.repo / 'config/waybar/waybar.css',
            self.repo / 'config/mako/config',
            walker,
        ):
            text_out = rendered if isinstance(rendered, str) else rendered.read_text()
            self.assertNotIn('{{', text_out)


if __name__ == '__main__':
    unittest.main()
