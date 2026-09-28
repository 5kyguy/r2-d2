"""Opt-in publisher tests. They never contact SkyGuy's website."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

REPO = Path(__file__).resolve().parents[1]


class ThemePublishTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='r2d2-publish-', dir=os.environ['TMPDIR'])
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
        self.state = self.root / 'state/r2-d2'
        self.state.mkdir(parents=True)
        self.config_dir = self.root / 'config/r2-d2'
        self.config_dir.mkdir(parents=True)
        self.env = dict(
            os.environ,
            HOME=str(self.home),
            R2D2_PATH=str(self.repo),
            XDG_STATE_HOME=str(self.root / 'state'),
            XDG_CONFIG_HOME=str(self.root / 'config'),
            R2D2_THEME_PUBLISH_FOREGROUND='1',
            R2D2_THEME_PUBLISH_RETRIES='3',
            R2D2_THEME_PUBLISH_RETRY_SECONDS='0',
            PATH=str(self.repo / 'bin') + ':' + os.environ['PATH'],
        )
        self.server = None

    def tearDown(self):
        if self.server is not None:
            self.server.shutdown()
            self.server.server_close()

    def build(self, accent):
        result = subprocess.run(
            ['bash', str(self.repo / 'bin/r2-d2-theme-state'), 'build', accent],
            env=self.env, text=True, capture_output=True, timeout=15, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def write_theme(self, accent):
        document = self.build(accent)
        (self.state / 'theme.json').write_text(document)
        return json.loads(document)

    def enable(self, endpoint, token='test-token'):
        (self.config_dir / 'theme-publish.conf').write_text(
            f'enabled=true\nendpoint={endpoint}\ntoken={token}\n'
        )

    def publish(self):
        return subprocess.run(
            ['bash', str(self.repo / 'bin/r2-d2-theme-publish')],
            env=self.env, text=True, capture_output=True, timeout=15, check=False,
        )

    def serve(self, hold_first=False, status=200):
        received = []
        started = threading.Event()
        release = threading.Event()
        current = {'body': b''}

        class Handler(BaseHTTPRequestHandler):
            def do_PUT(self):
                length = int(self.headers.get('Content-Length', '0'))
                body = self.rfile.read(length)
                received.append(body)
                if self.headers.get('Authorization') != 'Bearer test-token':
                    self.send_response(401)
                    self.end_headers()
                    return
                if hold_first and len(received) == 1:
                    started.set()
                    release.wait(5)
                if status != 200:
                    self.send_response(status)
                    self.end_headers()
                    return
                current['body'] = body
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(body)

            def do_GET(self):
                if not current['body']:
                    self.send_response(404)
                    self.end_headers()
                    return
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(current['body'])

            def log_message(self, _format, *_args):
                return

        self.server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        thread.start()
        port = self.server.server_address[1]
        return f'http://127.0.0.1:{port}', received, started, release

    def test_missing_config_does_not_publish(self):
        endpoint, received, _started, _release = self.serve()
        self.write_theme('#1D4ED8')
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(received, [])
        self.assertNotIn('test-token', result.stdout + result.stderr)
        self.assertTrue(endpoint.startswith('http://127.0.0.1:'))

    def test_readback_confirms_the_published_revision(self):
        endpoint, _received, _started, _release = self.serve()
        document = self.write_theme('#1D4ED8')
        before = (self.state / 'theme.json').read_bytes()
        self.enable(endpoint)
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.state / 'theme.json').read_bytes(), before)
        self.assertEqual((self.state / 'theme-publish.confirmed').read_text().strip(), document['revision'])
        log = (self.state / 'theme-publish.log').read_text()
        self.assertNotIn('test-token', log)
        self.assertIn(document['revision'], log)

    def test_authentication_failure_does_not_retry_or_change_the_theme(self):
        endpoint, received, _started, _release = self.serve()
        document = self.write_theme('#EAEAEA')
        before = (self.state / 'theme.json').read_bytes()
        self.enable(endpoint, token='wrong-token')
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(received), 1)
        self.assertEqual((self.state / 'theme.json').read_bytes(), before)
        self.assertFalse((self.state / 'theme-publish.confirmed').exists())
        self.assertNotEqual(document['revision'], '')

    def test_rejected_theme_is_not_retried(self):
        endpoint, received, _started, _release = self.serve(status=400)
        self.write_theme('#1D4ED8')
        self.enable(endpoint)
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(received), 1)

    def test_offline_endpoint_exits_cleanly(self):
        self.write_theme('#1D4ED8')
        before = (self.state / 'theme.json').read_bytes()
        self.enable('http://127.0.0.1:9')
        self.env['R2D2_THEME_PUBLISH_RETRIES'] = '2'
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.state / 'theme.json').read_bytes(), before)

    def test_rapid_updates_let_the_newest_revision_win(self):
        endpoint, received, started, release = self.serve(hold_first=True)
        first = self.write_theme('#1D4ED8')
        second = json.loads(self.build('#EAEAEA'))
        self.enable(endpoint)
        publisher = threading.Thread(target=self.publish)
        publisher.start()
        self.assertTrue(started.wait(5), 'first publication did not reach the server')
        (self.state / 'theme.json').write_text(json.dumps(second))
        follower = subprocess.Popen(
            ['bash', str(self.repo / 'bin/r2-d2-theme-publish')],
            env=self.env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        threading.Event().wait(0.2)
        release.set()
        publisher.join(5)
        stdout, stderr = follower.communicate(timeout=5)
        self.assertEqual(follower.returncode, 0, stderr)
        revisions = [json.loads(body)['revision'] for body in received]
        self.assertIn(first['revision'], revisions)
        self.assertLess(revisions.index(first['revision']), revisions.index(second['revision']))
        self.assertNotIn(first['revision'], revisions[revisions.index(second['revision']) + 1:])
        self.assertEqual((self.state / 'theme-publish.confirmed').read_text().strip(), second['revision'])

    def test_explicit_sync_publishes_the_activated_document(self):
        endpoint, received, _started, _release = self.serve()
        self.enable(endpoint)
        result = subprocess.run(
            ['bash', str(self.repo / 'bin/r2-d2-theme-apply'), '--accent', '#1D4ED8'],
            env=self.env, text=True, capture_output=True, timeout=15, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        result = subprocess.run(
            ['bash', str(self.repo / 'bin/r2-d2-theme-sync-live')],
            env=self.env, text=True, capture_output=True, timeout=15, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        activated = json.loads((self.state / 'theme.json').read_text())
        self.assertEqual(json.loads(received[-1])['revision'], activated['revision'])
        self.assertEqual((self.state / 'theme-publish.confirmed').read_text().strip(), activated['revision'])


if __name__ == '__main__':
    unittest.main()
