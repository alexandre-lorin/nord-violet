import importlib.util
from pathlib import Path
import tempfile
from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch
import time
import unittest

spec = importlib.util.spec_from_file_location("active_brightness", Path(__file__).resolve().parents[2] / "hypr/.config/hypr/scripts/active-brightness.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ActiveBrightnessTests(unittest.TestCase):
    def test_select_focused_not_first_monitor(self):
        monitors = [{"name": "eDP-1", "focused": False}, {"name": "HDMI-A-1", "focused": True}]
        self.assertEqual(module.focused_connector(monitors), "HDMI-A-1")

    def test_no_fallback_when_no_focus(self):
        with self.assertRaises(ValueError):
            module.focused_connector([{"name": "eDP-1"}])

    def test_bounds(self):
        self.assertEqual(module.target_percent(98, 5), 100)
        self.assertEqual(module.target_percent(2, -5), 0)
        self.assertEqual(module.target_percent(2, -5, True), 1)

    def test_pending_drained_once(self):
        with tempfile.TemporaryFile(mode="w+") as stream:
            stream.write("15")
            stream.flush()
            self.assertEqual(module.drain(stream), 15)
            self.assertEqual(module.drain(stream), 0)

    def test_concurrent_cranks_not_lost(self):
        batches = []

        class FakeBrightness:
            def __init__(self, connector):
                time.sleep(0.02)

            def change(self, delta):
                batches.append(delta)
                time.sleep(0.02)

        with tempfile.TemporaryDirectory() as runtime, \
             patch.dict(module.os.environ, {"XDG_RUNTIME_DIR": runtime}), \
             patch.object(module, "command", return_value='[{"name":"HDMI-A-1","focused":true}]'), \
             patch.object(module, "Brightness", FakeBrightness):
            with ThreadPoolExecutor(max_workers=10) as pool:
                list(pool.map(module.change_focused, [5] * 10))
            self.assertEqual(sum(batches), 50)
            self.assertLess(len(batches), 10)
