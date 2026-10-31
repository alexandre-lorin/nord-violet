import runpy
from pathlib import Path
from unittest import TestCase, mock
import json

SCRIPT = Path(__file__).resolve().parents[2] / "hypr/.config/hypr/scripts/terminal-here.py"


class TerminalHereTests(TestCase):
    def test_empty_unfocused_monitor_is_focused_before_launch(self):
        module = runpy.run_path(str(SCRIPT))
        monitors = [dict(id=0, x=0, y=0, width=2560, height=1440,
                         focused=True, activeWorkspace={"id": 1}),
                    dict(id=1, x=2560, y=0, width=1920, height=1080,
                         focused=False, activeWorkspace={"id": 11})]
        with mock.patch("subprocess.check_output", side_effect=[json.dumps({"x":3000,"y":400}), json.dumps(monitors)]), mock.patch("subprocess.run") as run:
            module["main"]()
        self.assertEqual(run.call_args_list, [
            mock.call(["hyprctl", "dispatch", "focusmonitor", "1"], check=True),
            mock.call(["hyprctl", "dispatch", "exec", "[workspace 11] alacritty --class nvterminal"], check=True)])

    def test_scaled_monitor_and_fallback(self):
        choose = runpy.run_path(str(SCRIPT))["target_workspace"]
        monitors = [dict(x=0, y=0, width=1920, height=1080, scale=2,
                         focused=True, activeWorkspace={"id": 6})]
        self.assertEqual(choose(monitors, {"x":900,"y":500}), 6)
        self.assertEqual(choose(monitors, {"x":3000,"y":500}), 6)
