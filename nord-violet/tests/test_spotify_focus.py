import importlib.util
from pathlib import Path
from unittest.mock import patch
import unittest

spec = importlib.util.spec_from_file_location("spotify_focus", Path(__file__).resolve().parents[2] / "hypr/.config/hypr/scripts/spotify-focus.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SpotifyFocusTests(unittest.TestCase):
    def test_select_real_window(self):
        clients = [{"class": "spotify", "mapped": False, "address": "closed"},
                   {"class": "Spotify", "address": "ready"}, {"class": "Alacritty", "address": "other"}]
        self.assertEqual(module.spotify_address(clients), "ready")

    def test_existing_instance_not_launched_again(self):
        with patch.object(module, "find", return_value="ready"), \
             patch.object(module.subprocess, "Popen") as launch, \
             patch.object(module.subprocess, "run") as focus:
            self.assertEqual(module.main(), 0)
            launch.assert_not_called()
            self.assertIn("address:ready", focus.call_args.args[0])

    def test_launch_then_focus(self):
        with patch.object(module, "find", side_effect=[None, "ready"]), \
             patch.object(module.time, "sleep"), \
             patch.object(module.subprocess, "Popen") as launch, \
             patch.object(module.subprocess, "run") as focus:
            self.assertEqual(module.main(), 0)
            launch.assert_called_once()
            focus.assert_called_once()
