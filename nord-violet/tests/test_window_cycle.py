import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("window_cycle", Path(__file__).resolve().parents[2] / "hypr/.config/hypr/scripts/window-cycle.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class WindowCycleTests(unittest.TestCase):
    def window(self, address, workspace=1, **extra):
        return {"address": address, "workspace": {"id": workspace}, **extra}

    def test_other_workspace_and_reverse(self):
        clients = [self.window("a"), self.window("b", 15), self.window("c", 11)]
        self.assertEqual(module.next_window(clients, "a"), "b")
        self.assertEqual(module.next_window(clients, "a", True), "c")

    def test_exclude_shell_and_hidden(self):
        clients = [self.window("a"), self.window("special", -1),
                   self.window("hidden", hidden=True), self.window("closed", mapped=False),
                   self.window("osd", title="Nord Violet OSD"), self.window("b", 15)]
        self.assertEqual(module.next_window(clients, "a"), "b")

    def test_empty_or_single(self):
        self.assertIsNone(module.next_window([], "a"))
        self.assertEqual(module.next_window([self.window("a")], "a"), "a")
