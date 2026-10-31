"""Pure launcher tests: no desktop processes and no personal data."""
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[2] / 'hypr/.config/hypr/scripts/falcon-popup.py'
spec = importlib.util.spec_from_file_location('falcon_popup', SCRIPT)
popup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(popup)


class PopupTests(unittest.TestCase):
    def test_geometry_respects_scaling_rotation_and_reservations(self):
        for scale, transform in [(1, 0), (1.5, 0), (2, 1), (1.25, 3)]:
            m = dict(width=2560, height=1440, x=-1280, y=100, scale=scale,
                     transform=transform, reserved=[10, 20, 30, 42])
            w, h, x, y = popup.geometry(m)
            aw, ah = ((1440, 2560) if transform % 2 else (2560, 1440))
            self.assertGreaterEqual(x, m['x'] + 10)
            self.assertGreaterEqual(y, m['y'] + 20)
            self.assertLessEqual(x + w, m['x'] + round(aw / scale) - 30)
            self.assertLessEqual(y + h, m['y'] + round(ah / scale) - 42)
            self.assertLessEqual(w, 1400)
            self.assertLessEqual(h, 850)

    def test_hide_on_other_monitor_restores_focus(self):
        shown = dict(name='A', specialWorkspace=dict(name='special:nvfalcon'))
        target = dict(name='B')
        with patch.object(popup, 'hypr') as dispatch:
            popup.hide([shown, target], target)
        self.assertEqual([c.args for c in dispatch.call_args_list], [
            ('dispatch', 'focusmonitor', 'A'),
            ('dispatch', 'togglespecialworkspace', 'nvfalcon'),
            ('dispatch', 'focusmonitor', 'B')])

    def exercise_toggle(self, acknowledge):
        monitor = dict(name='A', focused=True, width=1920, height=1080, x=0, y=0,
                       specialWorkspace={}, scale=1, reserved=[0, 0, 0, 40])
        client = dict(address='0x123', pid=1, **{'class': 'falcon-popup'},
                      workspace=dict(name='special:nvfalcon'), size=[900, 600], at=[0, 0])
        calls = []
        def query(name):
            return [monitor] if name == 'monitors' else [client]
        def dispatch(*args):
            calls.append(args)
            if acknowledge and args[1] == 'movewindowpixel':
                w, h, x, y = popup.geometry(monitor)
                client.update(size=[w, h], at=[x, y])
        with patch.object(popup, 'query', side_effect=query), patch.object(popup, 'hypr', side_effect=dispatch), patch.object(popup.time, 'sleep'):
            if acknowledge:
                popup.toggle()
            else:
                with self.assertRaisesRegex(RuntimeError, 'Position'):
                    popup.toggle()
        return calls

    def test_existing_instance_is_placed_before_reveal(self):
        calls = self.exercise_toggle(True)
        dispatchers = [c[1] for c in calls]
        self.assertNotIn('exec', dispatchers)
        self.assertLess(dispatchers.index('movewindowpixel'), dispatchers.index('togglespecialworkspace'))
        self.assertEqual(dispatchers[-1], 'focuswindow')

    def test_failed_position_never_reveals_window(self):
        self.assertNotIn('togglespecialworkspace', [c[1] for c in self.exercise_toggle(False)])


if __name__ == '__main__':
    unittest.main()
