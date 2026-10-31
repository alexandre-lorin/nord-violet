import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[2] / "quickshell-cc/.config/quickshell/nord-violet-cc/scripts"
spec = importlib.util.spec_from_file_location("focus_waybar", SCRIPTS / "focus-waybar.py")
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


class FocusTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.env = dict(os.environ, XDG_STATE_HOME=str(self.base),
                        MOCK_DND=str(self.base / "dnd"), PATH=f"{self.base}:{os.environ['PATH']}")
        mocks = {
            "makoctl": '#!/bin/sh\nif [ "$1" = mode ] && [ "$#" = 1 ]; then [ ! -e "$MOCK_DND" ] || echo dnd; exit 0; fi\nif [ "$2" = -a ]; then touch "$MOCK_DND"; else rm -f "$MOCK_DND"; fi\n',
            "notify-send": '#!/bin/sh\nexit 0\n',
            "nohup": '#!/bin/sh\nexit 0\n',
        }
        for name, code in mocks.items():
            path = self.base / name
            path.write_text(code)
            path.chmod(0o700)

    def run_focus(self, *args):
        return subprocess.run([str(SCRIPTS / "focusctl.sh"), *args], env=self.env,
                              capture_output=True, text=True, check=True, timeout=3).stdout.strip()

    def test_inactive(self):
        self.assertEqual(self.run_focus("status"), "inactive|0")

    def test_pause_resume_cancel(self):
        self.assertEqual(self.run_focus("start", "25"), "active|1500")
        self.assertTrue((self.base / "dnd").exists())
        self.assertTrue(self.run_focus("pause").startswith("paused|"))
        self.assertFalse((self.base / "dnd").exists())
        paused = self.run_focus("status")
        self.assertEqual(self.run_focus("status"), paused)
        self.assertTrue(self.run_focus("resume").startswith("active|"))
        self.assertTrue((self.base / "dnd").exists())
        self.assertEqual(self.run_focus("cancel"), "inactive|0")
        self.assertFalse((self.base / "dnd").exists())

    def test_initial_dnd_preserved(self):
        (self.base / "dnd").touch()
        self.run_focus("start", "50")
        self.run_focus("pause-toggle")
        self.assertTrue((self.base / "dnd").exists())
        self.run_focus("cancel")
        self.assertTrue((self.base / "dnd").exists())

    def test_restart_preserves_original_state(self):
        self.run_focus("start", "25")
        self.run_focus("start", "50")
        self.run_focus("cancel")
        self.assertFalse((self.base / "dnd").exists())

    def test_expired_session_restores_dnd(self):
        self.run_focus("start", "25")
        (self.base / "nord-violet/focus").write_text("1 0\n")
        self.assertEqual(self.run_focus("status"), "inactive|0")
        self.assertFalse((self.base / "dnd").exists())

    def test_stale_worker_does_not_end_new_session(self):
        self.run_focus("start", "25")
        self.run_focus("worker", "1")
        self.assertTrue(self.run_focus("status").startswith("active|"))

    def test_waybar_states(self):
        self.assertEqual(adapter.render("inactive|0")["text"], "")
        self.assertEqual(adapter.render("active|65")["text"], "◷ 01:05")
        self.assertEqual(adapter.render("paused|1500")["class"], "paused")

    def test_invalid_duration(self):
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_focus("start", "0")


if __name__ == "__main__":
    unittest.main()
