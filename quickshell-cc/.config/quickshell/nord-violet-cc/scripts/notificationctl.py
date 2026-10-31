#!/usr/bin/env python3
"""Centre de notifications Mako pour Nord Violet."""

import json
import subprocess
import sys


def mako(*args, capture=False):
    return subprocess.run(["makoctl", *args], check=True, text=True, capture_output=capture)


def items(command):
    try:
        return json.loads(mako(command, "-j", capture=True).stdout)
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return []


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    try:
        if command == "status":
            print(json.dumps({"current": items("list"), "history": items("history")}, ensure_ascii=False))
            return 0
        if command == "dismiss" and len(sys.argv) == 3 and sys.argv[2].isdigit():
            mako("dismiss", "-n", sys.argv[2]); return 0
        if command == "restore":
            mako("restore"); return 0
        if command == "clear-current":
            mako("dismiss", "--all", "--no-history"); return 0
        if command == "clear-history":
            for _ in items("history"):
                mako("restore"); mako("dismiss", "--no-history")
            return 0
    except (OSError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        return 1
    print("usage: notificationctl.py {status|dismiss ID|restore|clear-current|clear-history}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
