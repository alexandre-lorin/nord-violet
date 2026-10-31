import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[2] / 'quickshell-cc/.config/quickshell/nord-violet-cc/scripts/flyout-workspace.py'
spec = importlib.util.spec_from_file_location('flyout_workspace', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class FlyoutWorkspaceTests(unittest.TestCase):
    def setUp(self):
        self.monitors = [
            dict(name='HDMI-A-1', focused=True, specialWorkspace=dict(name=''), x=0, y=0, width=2560, height=1440, scale=1, reserved=[0, 0, 0, 42]),
            dict(name='eDP-1', focused=False, specialWorkspace=dict(name=''), x=2048, y=0, width=1920, height=1080, scale=1.25, reserved=[0, 0, 0, 42]),
        ]
        self.client = dict(title='Nord Violet Audio Flyout', address='0x123', at=[0, 0], size=[300, 251])

    def output(self, args, **kwargs):
        return json.dumps(self.monitors if args[1] == 'monitors' else [self.client])

    def invoke(self, *args):
        with patch.object(module.sys, 'argv', ['flyout-workspace.py', *args]), patch.object(module.subprocess, 'check_output', side_effect=self.output):
            module.main()

    def test_hide_already_hidden_does_not_reopen(self):
        with patch.object(module, 'dispatch') as dispatch:
            self.invoke('hide', 'nvaudio')
            dispatch.assert_not_called()

    def test_show_already_shown_only_restores_focus(self):
        self.monitors[0]['specialWorkspace']['name'] = 'special:nvaudio'
        with patch.object(module, 'dispatch') as dispatch:
            self.invoke('show', 'nvaudio')
            dispatch.assert_called_once_with('focuswindow', 'address:0x123')

    def test_hide_on_other_monitor_restores_original_focus(self):
        self.monitors[1]['specialWorkspace']['name'] = 'special:nvaudio'
        with patch.object(module, 'dispatch') as dispatch:
            self.invoke('hide', 'nvaudio')
            self.assertEqual([c.args for c in dispatch.call_args_list], [
                ('focusmonitor', 'eDP-1'), ('togglespecialworkspace', 'nvaudio'), ('focusmonitor', 'HDMI-A-1')])

    def test_show_hidden_opens_then_focuses(self):
        with patch.object(module, 'dispatch') as dispatch:
            self.invoke('show', 'nvaudio')
            self.assertEqual([c.args for c in dispatch.call_args_list], [
                ('togglespecialworkspace', 'nvaudio'), ('focuswindow', 'address:0x123')])

    def test_position_respects_scaled_monitor_and_reserved_bar(self):
        self.client.update(at=[3272, 374], size=[300, 436])
        with patch.object(module.subprocess, 'run', return_value=SimpleNamespace(stdout='ok\n\nok\n')) as run:
            self.invoke('position', 'nvaudio', '300', '436', 'eDP-1')
            self.assertEqual(run.call_args.args[0], ['hyprctl', '--batch',
                'dispatch resizewindowpixel exact 300 436,address:0x123;dispatch movewindowpixel exact 3272 374,address:0x123'])

    def test_position_respects_rotated_monitor(self):
        self.monitors[1].update(scale=1, transform=1)
        self.client.update(at=[2816, 1430], size=[300, 436])
        with patch.object(module.subprocess, 'run', return_value=SimpleNamespace(stdout='ok\nok\n')) as run:
            self.invoke('position', 'nvaudio', '300', '436', 'eDP-1')
            self.assertIn('exact 2816 1430,address:0x123', run.call_args.args[0][2])

    def test_unconfirmed_geometry_fails_instead_of_revealing(self):
        with patch.object(module.subprocess, 'run', return_value=SimpleNamespace(stdout='ok\nok\n')), patch.object(module.time, 'sleep'):
            with self.assertRaisesRegex(RuntimeError, 'confirmée'):
                self.invoke('position', 'nvaudio', '300', '436', 'eDP-1')

    def test_invalid_target_rejected_without_compositor_call(self):
        with patch.object(module.subprocess, 'check_output') as output, patch.object(module.sys, 'argv', ['helper', 'show', 'other']):
            with self.assertRaises(SystemExit):
                module.main()
            output.assert_not_called()


if __name__ == '__main__':
    unittest.main()
