#!/usr/bin/env python3
"""Explicit BlueZ agent: graphical confirmation, never automatic approval."""
import re
import subprocess
import sys
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib


def dialog(args):
    return subprocess.run(["zenity", "--title=Appairage Bluetooth", *args],
                          capture_output=True, text=True, timeout=90)


def main(address):
    if not re.fullmatch(r"(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}", address):
        raise ValueError("Adresse Bluetooth invalide")
    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    objects = bus.call_sync("org.bluez", "/", "org.freedesktop.DBus.ObjectManager",
                            "GetManagedObjects", None, None, Gio.DBusCallFlags.NONE, 5000, None).unpack()[0]
    device = next((path for path, interfaces in objects.items()
                   if interfaces.get("org.bluez.Device1", {}).get("Address", "").upper() == address.upper()), None)
    if not device:
        raise ValueError("Appareil non détecté ; relancez la recherche")
    methods = {
        "Release": "", "Cancel": "",
        "RequestPinCode": '<arg type="o" direction="in"/><arg type="s" direction="out"/>',
        "RequestPasskey": '<arg type="o" direction="in"/><arg type="u" direction="out"/>',
        "DisplayPinCode": '<arg type="o" direction="in"/><arg type="s" direction="in"/>',
        "DisplayPasskey": '<arg type="o" direction="in"/><arg type="u" direction="in"/><arg type="q" direction="in"/>',
        "RequestConfirmation": '<arg type="o" direction="in"/><arg type="u" direction="in"/>',
        "RequestAuthorization": '<arg type="o" direction="in"/>',
        "AuthorizeService": '<arg type="o" direction="in"/><arg type="s" direction="in"/>',
    }
    xml = '<node><interface name="org.bluez.Agent1">' + ''.join(
        f'<method name="{name}">{args}</method>' for name, args in methods.items()) + '</interface></node>'
    agent = "/org/nordviolet/PairAgent"

    def handle(connection, sender, path, interface, method, parameters, invocation):
        args = parameters.unpack()
        try:
            if method in ("Release", "Cancel"):
                invocation.return_value(None)
                return
            if args[0] != device:
                raise ValueError("Demande d'un autre appareil refusée")
            if method in ("RequestPinCode", "RequestPasskey"):
                response = dialog(["--entry", "--text=Saisissez le code demandé par votre appareil", "--hide-text"])
                if response.returncode:
                    raise ValueError("Appairage annulé")
                value = response.stdout.strip()
                if method == "RequestPasskey":
                    if not re.fullmatch(r"[0-9]{1,6}", value):
                        raise ValueError("Code numérique attendu, 6 chiffres maximum")
                    invocation.return_value(GLib.Variant("(u)", (int(value),)))
                else:
                    if not value or len(value) > 16:
                        raise ValueError("PIN invalide")
                    invocation.return_value(GLib.Variant("(s)", (value,)))
                return
            if method.startswith("Display"):
                code = str(args[1]) if method == "DisplayPinCode" else f"{args[1]:06d}"
                response = dialog(["--info", "--text=Saisissez ce code sur l'appareil : " + code])
            else:
                message = "Autoriser l'appairage avec cet appareil ?"
                if method == "RequestConfirmation":
                    message = f"Le code {args[1]:06d} est-il identique sur les deux appareils ?"
                elif method == "AuthorizeService":
                    message = "Autoriser le service Bluetooth demandé par cet appareil ?"
                response = dialog(["--question", "--text=" + message])
            if response.returncode:
                raise ValueError("Appairage refusé")
            invocation.return_value(None)
        except Exception as error:
            invocation.return_dbus_error("org.bluez.Error.Rejected", str(error))

    registration = bus.register_object(agent, Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0], handle, None, None)
    bus.call_sync("org.bluez", "/org/bluez", "org.bluez.AgentManager1", "RegisterAgent",
                  GLib.Variant("(os)", (agent, "KeyboardDisplay")), None, Gio.DBusCallFlags.NONE, 5000, None)
    loop = GLib.MainLoop()
    result = [1]

    def finished(connection, response, _data):
        try:
            connection.call_finish(response)
            result[0] = 0
            print("Appairage réussi ; cliquez sur Connecter pour utiliser l'appareil.")
        except Exception as error:
            print("Échec Bluetooth : " + str(error), file=sys.stderr)
        loop.quit()

    bus.call("org.bluez", device, "org.bluez.Device1", "Pair", None, None,
             Gio.DBusCallFlags.NONE, 120000, None, finished, None)
    loop.run()
    bus.unregister_object(registration)
    return result[0]


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1]))
    except Exception as error:
        print("Échec Bluetooth : " + str(error), file=sys.stderr)
        sys.exit(1)
