import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("monitor_brightness", Path(__file__).resolve().parents[2] / "quickshell-cc/.config/quickshell/nord-violet-cc/scripts/monitor-brightness.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class MonitorBrightnessTests(unittest.TestCase):
    def test_connector_not_fixed_bus(self):
        text = "Display 1\n I2C bus: /dev/i2c-9\n DRM connector: card1-HDMI-A-1\nInvalid display\n I2C bus: /dev/i2c-5\n DRM connector: card1-eDP-1\n"
        self.assertEqual(module.bus_for_connector(text, "HDMI-A-1"), 9)
        with self.assertRaises(ValueError):
            module.bus_for_connector(text, "eDP-1")

    def test_vcp_brightness(self):
        self.assertEqual(module.parse_brightness("VCP 10 C 30 100"), (30, 100))

    def test_unsupported_brightness(self):
        for text in ("VCP 10 ERR", "VCP 10 C 5 0"):
            with self.assertRaises(ValueError):
                module.parse_brightness(text)
