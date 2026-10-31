#!/usr/bin/env python3
"""Readable output names shared by the flyout and Control Center.
Never rename PipeWire devices: pactl's stable name remains the command target.
"""
import json
import os
import re
import select
import subprocess
import sys
import time


def clean(value):
    value = str(value or "").strip()
    return "" if value.lower() in ("(null)", "null", "n/a") else " ".join(value.split())


def describe(sink):
    props = sink.get("properties", {})
    name = sink.get("name", "")
    port = sink.get("active_port", "")
    product = clean(props.get("device.product.name"))
    nick = clean(props.get("node.nick"))
    description = clean(sink.get("description"))
    model = product or nick or description or "Sortie audio"
    if "hdmi" in name.lower() or "displayport" in name.lower():
        screen = clean(props.get("alsa.name"))
        if screen and screen.lower() not in ("hdmi", "hdmi 0", "hdmi 1"):
            return "Écran " + screen, "HDMI / DisplayPort"
        return "Écran externe", "HDMI / DisplayPort"
    if name.startswith("bluez_") or props.get("device.api") == "bluez5":
        return model, "Bluetooth"
    if props.get("device.bus") == "usb":
        detail = "Retour casque · USB" if "wave:3" in model.lower() else "USB"
        if "hyperx" in model.lower():
            detail = "Casque · USB"
        return model, detail
    if port == "analog-output-speaker":
        return "Haut-parleurs du portable", "Audio intégré"
    if port == "analog-output-headphones":
        return "Casque filaire", "Prise jack · Audio intégré"
    return model, "Sortie audio"


def devices(sinks):
    result = []
    counts = {}
    for sink in sinks:
        label, detail = describe(sink)
        counts[label] = counts.get(label, 0) + 1
        if counts[label] > 1:
            label += " · " + str(counts[label])
        volumes = list(sink.get("volume", {}).values())
        percent = round(sum(float(v.get("value", 0)) for v in volumes)
                        / len(volumes) / 65536 * 100) if volumes else 0
        result.append({"name": sink["name"], "desc": label, "detail": detail,
                       "volume": percent, "muted": bool(sink.get("mute", False))})
    return result


def describe_source(source):
    props = source.get("properties", {})
    product = clean(props.get("device.product.name"))
    nick = clean(props.get("node.nick"))
    description = clean(source.get("description"))
    label = product or nick or description or "Microphone"
    if props.get("device.bus") == "usb":
        return label, "Microphone · USB"
    port = source.get("active_port", "")
    if "internal-mic" in port:
        return "Microphone du portable", "Audio intégré"
    if "headset-mic" in port:
        return "Microphone du casque", "Prise jack"
    return label, "Entrée audio"


def sources(source_rows):
    result = []
    counts = {}
    for source in source_rows:
        name = source.get("name", "")
        if name.endswith(".monitor") or source.get("monitor_of_sink") is not None:
            continue
        label, detail = describe_source(source)
        counts[label] = counts.get(label, 0) + 1
        if counts[label] > 1:
            label += " · " + str(counts[label])
        volumes = list(source.get("volume", {}).values())
        percent = round(sum(float(v.get("value", 0)) for v in volumes)
                        / len(volumes) / 65536 * 100) if volumes else 0
        result.append({"name": name, "desc": label, "detail": detail,
                       "volume": percent, "muted": bool(source.get("mute", False))})
    return result


def pactl(*args):
    return subprocess.check_output(["pactl", *args], text=True,
                                   env={**os.environ, "LC_ALL": "C.utf8"},
                                   stderr=subprocess.PIPE, timeout=3)


def default_sink():
    """Return the explicit PipeWire default sink used by every control."""
    sink = pactl("get-default-sink").strip()
    if not sink:
        raise ValueError("Aucune sortie audio par défaut")
    return sink


def default_source():
    source = pactl("get-default-source").strip()
    if not source:
        raise ValueError("Aucune entrée audio par défaut")
    return source


def control(action, value=""):
    """Apply one audio action to the selected/default sink.

    Selecting a sink changes only PipeWire's default. Existing streams that an
    application routed explicitly are intentionally left where they are.
    """
    if action == "select":
        if not value or any(char in value for char in "\r\n\0"):
            raise ValueError("Sortie audio invalide")
        pactl("set-default-sink", value)
        return
    if action == "select-source":
        if not value or any(char in value for char in "\r\n\0"):
            raise ValueError("Entrée audio invalide")
        pactl("set-default-source", value)
        return

    if action == "set-volume":
        if not re.fullmatch(r"(?:100|[1-9]?\d)%", value):
            raise ValueError("Volume invalide")
        sink = default_sink()
        pactl("set-sink-volume", sink, value)
    elif action == "change-volume":
        if not re.fullmatch(r"[+-](?:100|[1-9]?\d)%", value):
            raise ValueError("Variation de volume invalide")
        # WirePlumber applies the limit directly: no three-call read/write queue.
        subprocess.run(["wpctl", "set-volume", "--limit", "1.0",
                        "@DEFAULT_AUDIO_SINK@", value[1:] + value[0]],
                       check=True, stderr=subprocess.PIPE, timeout=3)
    elif action == "toggle-mute":
        sink = default_sink()
        pactl("set-sink-mute", sink, "toggle")
    elif action == "set-source-volume":
        if not re.fullmatch(r"(?:100|[1-9]?\d)%", value):
            raise ValueError("Volume micro invalide")
        source = default_source()
        pactl("set-source-volume", source, value)
    elif action == "toggle-source-mute":
        source = default_source()
        pactl("set-source-mute", source, "toggle")
    else:
        raise ValueError("Action audio inconnue")


def waybar_payload():
    outputs = devices(json.loads(pactl("-f", "json", "list", "sinks")))
    current = default_sink()
    selected = next((s for s in outputs if s["name"] == current), None)
    if selected is None:
        raise ValueError("Sortie audio introuvable")
    return {"text": "󰝟 muet" if selected["muted"] else "󰕾 " + str(selected["volume"]) + "%",
            "tooltip": selected["desc"], "class": "muted" if selected["muted"] else "active"}


def is_audio_event(event):
    return " on sink #" in event or " on server #" in event


def coalesce_audio_events(stream, emit):
    """Drain event bursts, with at most one refresh every 35 ms and a tail flush."""
    pending = False
    next_emit = 0.0
    buffer = b""
    while True:
        timeout = max(0.0, next_emit - time.monotonic()) if pending else None
        ready, _, _ = select.select([stream], [], [], timeout)
        if ready:
            chunk = os.read(stream.fileno(), 65536)
            if not chunk:
                if pending:
                    emit()
                return
            buffer += chunk
            lines = buffer.split(b"\n")
            buffer = lines.pop()
            if any(is_audio_event(line.decode("utf-8", errors="replace")) for line in lines):
                pending = True
        if pending and time.monotonic() >= next_emit:
            emit()
            next_emit = time.monotonic() + 0.035
            pending = False


def watch_waybar():
    # Start the event subscription before the initial snapshot, without polling.
    with subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE,
                          stderr=subprocess.DEVNULL, bufsize=0,
                          env={**os.environ, "LC_ALL": "C.utf8"}) as events:
        previous = None
        try:
            def emit():
                nonlocal previous
                try:
                    payload = waybar_payload()
                except (subprocess.SubprocessError, OSError, ValueError, KeyError):
                    payload = {"text": "󰝟 —", "class": "unavailable"}
                if payload != previous:
                    print(json.dumps(payload, ensure_ascii=False), flush=True)
                    previous = payload
            emit()
            coalesce_audio_events(events.stdout, emit)
        finally:
            events.terminate()


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "snapshot"
    if mode in ("select", "select-source", "set-volume", "change-volume", "toggle-mute",
                "set-source-volume", "toggle-source-mute"):
        control(mode, sys.argv[2] if len(sys.argv) > 2 else "")
        return
    if mode == "waybar-watch":
        watch_waybar()
        return
    if mode == "waybar":
        print(json.dumps(waybar_payload(), ensure_ascii=False))
        return
    outputs = devices(json.loads(pactl("-f", "json", "list", "sinks")))
    inputs = sources(json.loads(pactl("-f", "json", "list", "sources")))
    default = default_sink() if mode != "list" else ""
    if mode == "snapshot":
        print(json.dumps({"sinks": outputs, "default": default, "sources": inputs,
                          "defaultSource": default_source()}, ensure_ascii=False))
    elif mode == "list-sources":
        current = default_source()
        for source in inputs:
            if source["name"] == current:
                print("\t".join(source[k] for k in ("name", "desc", "detail")))
    else:
        for output in outputs:
            if mode == "list" or output["name"] == default:
                print("\t".join(output[k] for k in ("name", "desc", "detail")))


if __name__ == "__main__":
    try:
        main()
    except (subprocess.SubprocessError, OSError, ValueError, KeyError) as error:
        print("Audio indisponible : " + type(error).__name__, file=sys.stderr)
        sys.exit(1)
