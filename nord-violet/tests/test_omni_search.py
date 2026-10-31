import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "omni_launcher", Path("/home/toubi/08 - Outils/Omni Launcher/omni-launcher.py"))
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)


class OmniSearchTests(unittest.TestCase):
    def test_query_is_passed_as_one_argument_without_shell(self):
        query = "Zed et fichiers ; $(commande)"
        with patch.object(launcher, "entries", return_value=[("Zed", ("app", "zed"))]), patch.object(launcher.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "")) as run, patch.object(launcher, "activate") as activate:
            self.assertEqual(launcher.main(["--search", query]), 0)
            self.assertEqual(run.call_args.args[0][-2:], ["--search", query])
            self.assertNotIn("shell", run.call_args.kwargs)
            activate.assert_not_called()

    def test_empty_query_preserves_normal_launch(self):
        with patch.object(launcher, "entries", return_value=[("Zed", ("app", "zed"))]), patch.object(launcher.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "0\n")) as run, patch.object(launcher, "activate") as activate:
            self.assertEqual(launcher.main([]), 0)
            self.assertEqual(run.call_args.args[0][-2:], ["--search", ""])
            activate.assert_called_once_with(("app", "zed"))

    def test_invalid_index_cannot_activate_last_entry(self):
        for value in ["-1", "3", "invalid"]:
            with self.subTest(value=value), patch.object(launcher, "entries", return_value=[("Zed", ("app", "zed"))]), patch.object(launcher.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, value)), patch.object(launcher, "activate") as activate:
                self.assertEqual(launcher.main([]), 1)
                activate.assert_not_called()
