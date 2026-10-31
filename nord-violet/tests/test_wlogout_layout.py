import importlib.util
import json
from pathlib import Path
import unittest

PATH = Path(__file__).resolve().parents[1] / '.config/wlogout/launch.py'
spec = importlib.util.spec_from_file_location('wlogout_launch', PATH)
launcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launcher)


class WlogoutLayoutTests(unittest.TestCase):
    def test_layout_keeps_original_actions_and_shortcuts(self):
        entries = launcher.actions(PATH.parent)
        self.assertEqual([e['id'] for e in entries], ['lock', 'suspend', 'logout', 'reboot', 'shutdown'])
        self.assertEqual([e['key'] for e in entries], ['L', 'U', 'E', 'R', 'S'])
        self.assertEqual([e['command'] for e in entries], [['hyprlock'], ['systemctl', 'suspend'],
                         ['hyprctl', 'dispatch', 'exit'], ['systemctl', 'reboot'], ['systemctl', 'poweroff']])

    def test_preview_neutralizes_every_system_command(self):
        real, preview = launcher.actions(PATH.parent), launcher.actions(PATH.parent, True)
        self.assertTrue(all(e['command'] == ['true'] for e in preview))
        self.assertEqual([{k:v for k,v in e.items() if k != 'command'} for e in real],
                         [{k:v for k,v in e.items() if k != 'command'} for e in preview])

    def test_confirmations_match_approved_prototype(self):
        entries = launcher.actions(PATH.parent)
        self.assertEqual([e['id'] for e in entries if e['confirm']], ['logout', 'reboot'])
        self.assertFalse(next(e for e in entries if e['id'] == 'shutdown')['confirm'])

    def test_launch_selects_focused_monitor_and_marks_preview(self):
        monitors = [dict(name='HDMI-A-1', focused=False), dict(name='eDP-1', focused=True)]
        env = launcher.launch_config(PATH.parent, monitors, True)
        self.assertEqual(env['NV_SESSION_MONITOR'], 'eDP-1')
        self.assertEqual(env['NV_SESSION_PREVIEW'], '1')
        self.assertTrue(all(e['command'] == ['true'] for e in json.loads(env['NV_SESSION_ACTIONS'])))
        self.assertRegex(env['NV_SESSION_ACCENT'], r'^#[0-9a-fA-F]{6}$')


if __name__ == '__main__':
    unittest.main()
