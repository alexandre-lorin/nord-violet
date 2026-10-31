import runpy
from pathlib import Path
import unittest

placement = runpy.run_path(str(Path(__file__).resolve().parents[2] /
    "hypr/.config/hypr/scripts/float-cascade.py"))["placement"]


class CascadeTests(unittest.TestCase):
    def test_distinct_positions(self):
        monitor = dict(x=0, y=0, width=1920, height=1080, reserved=[0, 0, 0, 42])
        others = []
        for _ in range(5):
            w, h, x, y = placement(monitor, others)
            self.assertFalse(any(win["at"] == [x, y] for win in others))
            self.assertLessEqual(x + w, 1908)
            self.assertLessEqual(y + h, 1026)
            others.append({"at": [x, y]})

    def test_scaled_small_monitor(self):
        w, h, x, y = placement(dict(x=2560, y=0, width=1280, height=800,
                                    scale=2, reserved=[0, 0, 0, 42]), [])
        self.assertGreaterEqual(x, 2572)
        self.assertLessEqual(x + w, 3188)
        self.assertLessEqual(y + h, 346)


if __name__ == "__main__":
    unittest.main()
