#!/usr/bin/env python3
"""Dictée locale F9 pour les terminaux Wayland de Toubi. Aucun service au repos."""
import array
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import tempfile
import time
import wave

SUBMAP = "codex-dictation"
MODEL = Path.home() / ".local/share/falcon/models/ggml-base.bin"
TERMINALS = {"terminal-deck", "local.toubi.terminal-deck", "alacritty", "scratchterm"}


def run(args, **kwargs):
    return subprocess.run(args, check=True, timeout=3, **kwargs)


def hypr(*args):
    return run(["hyprctl", *args], capture_output=True, text=True).stdout.strip()


def notify(message, ongoing=False):
    subprocess.Popen(["notify-send", "-a", "Dictée", "-r", "9049", "-t", "0" if ongoing else "4000", "Dictée", message],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def active():
    w = json.loads(hypr("-j", "activewindow"))
    return (w.get("address"), w.get("class", "").lower(), w.get("title", ""))


def clean_text(text):
    # Une seule ligne de texte, sans séquence terminal ni touche implicite.
    return " ".join(re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", text).split())[:16000]


def has_speech(path):
    with wave.open(str(path), "rb") as audio:
        if audio.getsampwidth() != 2 or audio.getnchannels() != 1:
            raise RuntimeError("Format du microphone inattendu.")
        samples = array.array("h", audio.readframes(audio.getnframes()))
        if sys.byteorder != "little":
            samples.byteswap()
        # Ne pas transcrire un microphone muet : Whisper peut inventer du texte.
        block = max(1, audio.getframerate() // 50)
        loud = sum(math.sqrt(sum(v*v for v in samples[i:i+block]) / len(samples[i:i+block])) > 100
                   for i in range(0, len(samples), block))
        return loud >= 8


def stop(child):
    if child and child.poll() is None:
        child.send_signal(signal.SIGINT)
        try:
            child.wait(timeout=2)
        except subprocess.TimeoutExpired:
            child.kill()
            child.wait(timeout=2)


def endpoint():
    instance = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    if not instance:
        raise RuntimeError("Cette dictée nécessite une session Hyprland.")
    root = Path(os.environ["XDG_RUNTIME_DIR"]) / ("codex-dictation-" + hashlib.sha256(instance.encode()).hexdigest()[:10])
    root.mkdir(mode=0o700, exist_ok=True)
    if root.stat().st_uid != os.getuid() or root.is_symlink():
        raise RuntimeError("Dossier de dictée non sûr.")
    return root


def request(root, action):
    try:
        with socket.socket(socket.AF_UNIX) as client:
            client.settimeout(.5)
            client.connect(str(root / "control.sock"))
            client.sendall(action.encode())
        return True
    except (FileNotFoundError, ConnectionRefusedError, socket.timeout):
        return False


def shortcut(modifiers, key, target):
    result = hypr("dispatch", "sendshortcut", f"{modifiers}, {key}, address:{target[0]}")
    if result != "ok":
        raise RuntimeError("Le terminal n’a pas reçu le raccourci.")


def deliver(text, send, target, guard):
    if active() != target:
        raise RuntimeError("Dictée annulée : le terminal actif a changé.")
    # wl-copy revient seulement quand il possède le presse-papiers. Ne pas
    # utiliser --paste-once : le gestionnaire d’historique peut lire en premier.
    run(["wl-copy", "--type", "text/plain;charset=utf-8"], input=text, text=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    guard()
    shortcut("CTRL SHIFT", "V", target)
    # L’IPC de collage d’Electron est asynchrone. Garder les touches physiques
    # interceptées jusqu’à son traitement, puis envoyer une seule Entrée.
    deadline = time.monotonic() + .6
    while time.monotonic() < deadline:
        guard()
        time.sleep(.025)
    if send:
        shortcut("", "Return", target)


def serve(root):
    lock = open(root / "lock", "a")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return
    target = active()
    if target[1] not in TERMINALS:
        notify("Placez le curseur dans votre terminal avant F9.")
        return
    if not MODEL.is_file():
        notify("Modèle Whisper local introuvable.")
        return
    control = root / "control.sock"
    control.unlink(missing_ok=True)
    recorder = decoder = None
    entered = False
    with socket.socket(socket.AF_UNIX) as server, tempfile.TemporaryDirectory(prefix="audio-", dir=root) as tmp:
        server.bind(str(control))
        server.listen(4)
        server.settimeout(.08)
        def command():
            try:
                client, _ = server.accept()
                with client:
                    client.settimeout(.2)
                    return client.recv(32).decode()
            except socket.timeout:
                return None
        def guard():
            if active() != target:
                raise RuntimeError("Dictée annulée : vous avez changé de fenêtre ou de panneau.")
            if command() == "cancel":
                raise RuntimeError("Dictée annulée.")
        try:
            # Un autre sous-mode (redimensionnement, etc.) reste prioritaire.
            if hypr("submap") != "default":
                raise RuntimeError("Terminez le raccourci en cours avant de dicter.")
            audio = Path(tmp) / "capture.wav"
            recorder = subprocess.Popen(["pw-record", "--rate", "16000", "--channels", "1", "--format", "s16", str(audio)],
                                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(.15)
            if recorder.poll() is not None:
                raise RuntimeError("Impossible d’ouvrir le microphone.")
            hypr("dispatch", "submap", SUBMAP)
            entered = True
            notify("Micro ouvert · F9 : relire · Entrée : envoyer · Échap : annuler", ongoing=True)
            deadline = time.monotonic() + 180
            while True:
                if active() != target:
                    raise RuntimeError("Dictée annulée : vous avez changé de fenêtre ou de panneau.")
                action = command()
                if action == "cancel":
                    raise RuntimeError("Dictée annulée.")
                if action in ("toggle", "send"):
                    break
                if recorder.poll() is not None:
                    raise RuntimeError("Le microphone s’est arrêté.")
                if time.monotonic() > deadline:
                    raise RuntimeError("Dictée annulée après trois minutes.")
            stop(recorder)
            if not has_speech(audio):
                raise RuntimeError("Aucune parole détectée. Vérifiez votre microphone.")
            notify("Transcription locale… · Échap : annuler", ongoing=True)
            output = Path(tmp) / "transcript"
            decoder = subprocess.Popen(["whisper-cli", "-m", str(MODEL), "-l", "fr", "-f", str(audio),
                                        "-otxt", "-of", str(output), "-np", "-nt", "-ng", "-t", "6"],
                                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            deadline = time.monotonic() + 90
            while decoder.poll() is None:
                guard()
                if time.monotonic() > deadline:
                    raise RuntimeError("Transcription trop longue : dictée annulée.")
                time.sleep(.03)
            if decoder.returncode:
                raise RuntimeError("Whisper n’a pas pu transcrire cet enregistrement.")
            transcript = clean_text(output.with_suffix(".txt").read_text())
            if not transcript:
                raise RuntimeError("Aucune parole reconnue.")
            guard()
            deliver(transcript, action == "send", target, guard)
            notify("Message envoyé." if action == "send" else "Texte inséré · relisez puis Entrée pour envoyer.")
        except (RuntimeError, OSError, subprocess.SubprocessError, ValueError, wave.Error) as error:
            notify(str(error))
        finally:
            stop(recorder)
            stop(decoder)
            if entered and hypr("submap") == SUBMAP:
                hypr("dispatch", "submap", "reset")
            control.unlink(missing_ok=True)


def main():
    os.umask(0o077)
    # Un arrêt de session libère le micro et le sous-mode via le finally.
    def interrupted(_sig, _frame):
        raise RuntimeError("Dictée interrompue.")
    signal.signal(signal.SIGTERM, interrupted)
    action = sys.argv[1] if len(sys.argv) == 2 else ""
    if action not in ("toggle", "send", "cancel", "serve"):
        raise SystemExit("Usage : codex-dictation.py toggle|send|cancel|serve")
    root = endpoint()
    if action == "serve":
        serve(root)
    else:
        delivered = request(root, action)
        if not delivered and action == "toggle":
            subprocess.Popen([sys.executable, str(Path(__file__).resolve()), "serve"], start_new_session=True,
                             stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        elif not delivered and action == "cancel":
            # Secours si le processus a été interrompu brutalement.
            if hypr("submap") == SUBMAP:
                hypr("dispatch", "submap", "reset")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        notify(str(error))
        raise SystemExit(1)
