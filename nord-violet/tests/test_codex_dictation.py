import importlib.util
import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch, Mock
import wave
import struct

spec = importlib.util.spec_from_file_location('dictation', str(Path.home() / '.config/hypr/scripts/codex-dictation.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

class DictationTests(unittest.TestCase):
    def test_single_line_no_terminal_controls(self):
        self.assertEqual(m.clean_text('Bonjour\nToubi\r\t!\x00'), 'Bonjour Toubi !')
        self.assertNotIn('\x1b', m.clean_text('\x1b[200~test\x1b[201~'))

    def test_silence_and_short_noise_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 'test.wav'
            for count, sample, expected in [(16000, 0, False), (1600, 1000, False), (16000, 1000, True)]:
                with wave.open(str(p), 'wb') as w:
                    w.setparams((1, 2, 16000, 0, 'NONE', 'not compressed'))
                    w.writeframes(struct.pack('<h', sample) * count)
                self.assertEqual(m.has_speech(p), expected)

    def test_focus_changed_never_pastes(self):
        with patch.object(m, 'active', return_value=('other', 'terminal-deck', 'Other')), patch.object(m, 'shortcut') as key:
            with self.assertRaisesRegex(RuntimeError, 'changé'):
                m.deliver('Texte', True, ('target', 'terminal-deck', 'Test'), lambda: None)
            key.assert_not_called()

    def test_draft_and_send_use_exactly_one_paste(self):
        target = ('target', 'terminal-deck', 'Test')
        for send in (False, True):
            child = Mock(returncode=0)
            child.poll.return_value = 0
            with patch.object(m, 'active', return_value=target), patch.object(m, 'run'), patch.object(m, 'shortcut') as key:
                m.deliver('Texte français', send, target, lambda: None)
                self.assertEqual(key.call_args_list[0].args, ('CTRL SHIFT', 'V', target))
                self.assertEqual(key.call_count, 2 if send else 1)
                if send:
                    self.assertEqual(key.call_args_list[1].args, ('', 'Return', target))

    def test_cancel_after_paste_never_sends(self):
        target = ('target', 'terminal-deck', 'Test')
        child = Mock(returncode=0)
        child.poll.return_value = 0
        calls = 0
        def guard():
            nonlocal calls
            calls += 1
            if calls >= 2:
                raise RuntimeError('Annulé')
        with patch.object(m, 'active', return_value=target), patch.object(m, 'run'), patch.object(m, 'shortcut') as key:
            with self.assertRaisesRegex(RuntimeError, 'Annulé'):
                m.deliver('Texte', True, target, guard)
            self.assertEqual(key.call_count, 1)

if __name__ == '__main__':
    unittest.main()
