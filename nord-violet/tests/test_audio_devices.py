import importlib.util
from pathlib import Path
from unittest.mock import patch
import unittest
import io
import json

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location(
    "audio_devices", ROOT / "quickshell-cc/.config/quickshell/nord-violet-cc/scripts/audio-devices.py")
audio = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audio)


class AudioDeviceTests(unittest.TestCase):
    def test_waybar_uses_default_sink_and_its_mute_state(self):
        for muted in (False, True):
            with self.subTest(muted=muted), patch.object(audio.sys, "argv", ["audio-devices.py", "waybar"]), patch.object(audio, "pactl", return_value="[]"), patch.object(audio, "default_sink", return_value="chosen") as default, patch.object(audio, "devices", return_value=[{"name":"other", "volume":100, "muted":False, "desc":"Other"}, {"name":"chosen", "volume":30, "muted":muted, "desc":"Chosen"}]), patch("sys.stdout", new_callable=io.StringIO) as output:
                audio.main()
                result = json.loads(output.getvalue())
                self.assertEqual(result["text"], "󰝟 muet" if muted else "󰕾 30%")
                self.assertEqual(result["tooltip"], "Chosen")
                default.assert_called_once()

    def test_hdmi_names_the_monitor_not_the_graphics_card(self):
        self.assertEqual(audio.describe({"name": "alsa_output.gpu.hdmi-stereo",
            "description": "(null)", "properties": {"alsa.name": "MFG27F4Q"}}),
            ("Écran MFG27F4Q", "HDMI / DisplayPort"))

    def test_usb_headset_and_microphone_monitor_are_distinct(self):
        for product, detail in [("HyperX Cloud III", "Casque · USB"),
                                ("Elgato Wave:3", "Retour casque · USB")]:
            self.assertEqual(audio.describe({"properties": {"device.bus": "usb",
                "device.product.name": product}}), (product, detail))

    def test_analog_label_follows_the_active_port(self):
        for port, title in [("speaker", "Haut-parleurs du portable"),
                            ("headphones", "Casque filaire")]:
            self.assertEqual(audio.describe({"active_port": "analog-output-" + port})[0], title)

    def test_bluetooth_and_unknown_output_have_safe_fallbacks(self):
        self.assertEqual(audio.describe({"name": "bluez_output.test",
            "description": "Casque Bluetooth"}), ("Casque Bluetooth", "Bluetooth"))
        self.assertEqual(audio.describe({"description": "(null)"}), ("Sortie audio", "Sortie audio"))

    def test_duplicate_labels_keep_distinct_targets(self):
        result = audio.devices([{"name": "first"}, {"name": "second"}])
        self.assertEqual([r["name"] for r in result], ["first", "second"])
        self.assertEqual([r["desc"] for r in result], ["Sortie audio", "Sortie audio · 2"])

    def test_mute_is_independent_of_saved_volume(self):
        result = audio.devices([{"name": "test", "mute": True,
            "volume": {"left": {"value": 32768}, "right": {"value": 32768}}}])[0]
        self.assertEqual(result["volume"], 50)
        self.assertTrue(result["muted"])

    def test_scroll_uses_native_default_sink_in_one_command(self):
        with patch.object(audio.subprocess, "run") as run, patch.object(audio, "pactl") as pactl:
            audio.control("change-volume", "+5%")
        pactl.assert_not_called()
        self.assertEqual(run.call_args.args[0],
                         ["wpctl", "set-volume", "--limit", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"])

    def test_scroll_volume_is_bounded_and_keeps_one_percent_steps(self):
        for change, argument in [("+1%", "1%+"), ("-1%", "1%-"), ("+0%", "0%+")]:
            with self.subTest(change=change), patch.object(audio.subprocess, "run") as run:
                audio.control("change-volume", change)
                self.assertEqual(run.call_args.args[0],
                                 ["wpctl", "set-volume", "--limit", "1.0", "@DEFAULT_AUDIO_SINK@", argument])

    def test_invalid_relative_volume_does_not_launch_command(self):
        with patch.object(audio.subprocess, "run") as run:
            with self.assertRaises(ValueError):
                audio.control("change-volume", "+101%")
            run.assert_not_called()

    def test_stream_updates_on_sink_events_and_deduplicates(self):
        with patch.object(audio.subprocess, "Popen") as popen, patch.object(audio, "coalesce_audio_events", side_effect=lambda stream, emit: (emit(), emit())), patch.object(audio, "waybar_payload", side_effect=[{"text":"40%"}, {"text":"41%"}, {"text":"41%"}]), patch("sys.stdout", new_callable=io.StringIO) as output:
            events = popen.return_value.__enter__.return_value
            events.stdout = ["Event 'change' on sink-input #7", "Event 'change' on sink #1", "Event 'change' on server #0"]
            audio.watch_waybar()
            self.assertEqual([json.loads(line)["text"] for line in output.getvalue().splitlines()], ["40%", "41%"])
            events.terminate.assert_called_once()

    def test_only_sink_and_server_events_trigger_refresh(self):
        self.assertTrue(audio.is_audio_event("Event 'change' on sink #1"))
        self.assertTrue(audio.is_audio_event("Event 'change' on server #0"))
        self.assertFalse(audio.is_audio_event("Event 'change' on sink-input #7"))

    def test_event_burst_is_drained_in_one_refresh(self):
        import os
        read_fd, write_fd = os.pipe()
        with os.fdopen(read_fd, "rb", buffering=0) as stream:
            with os.fdopen(write_fd, "wb", buffering=0) as writer:
                writer.write(b"Event 'change' on sink #1\n" * 100)
            calls = []
            audio.coalesce_audio_events(stream, lambda: calls.append(True))
            self.assertEqual(len(calls), 1)

    def test_select_changes_default_without_moving_existing_streams(self):
        with patch.object(audio, "pactl", return_value="") as pactl:
            audio.control("select", "sink.usb")
        pactl.assert_called_once_with("set-default-sink", "sink.usb")

    def test_invalid_volume_is_rejected_before_pactl(self):
        with patch.object(audio, "pactl") as pactl:
            with self.assertRaises(ValueError):
                audio.control("set-volume", "101%")
        pactl.assert_not_called()

    def test_monitor_sources_are_not_presented_as_microphones(self):
        result = audio.sources([
            {"name": "alsa_output.test.monitor", "monitor_of_sink": 4},
            {"name": "alsa_input.usb", "properties": {"device.bus": "usb",
                "device.product.name": "Wave:3"}},
        ])
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["desc"], "Wave:3")
        self.assertEqual(result[0]["detail"], "Microphone · USB")

    def test_microphone_controls_resolve_default_source(self):
        with patch.object(audio, "pactl", side_effect=["source.main\n", ""]) as pactl:
            audio.control("set-source-volume", "75%")
        self.assertEqual(pactl.call_args_list[0].args, ("get-default-source",))
        self.assertEqual(pactl.call_args_list[1].args,
                         ("set-source-volume", "source.main", "75%"))


if __name__ == "__main__":
    unittest.main()
