# Focus — 8 October 2026

## Usage

- CC: Focus click starts 50 minutes; Next click pauses, then resumes. Right click stops.
- Settings → Profiles: choose 25 or 50 minutes, explicit pause/resume and shutdown.
- Waybar: counter visible only during the session or its pause. Left click pause/resume, right click stop, wheel click opens Profiles.
- A pause freezes the remaining time and restores the initial DND state. Resume active DND; stop or finish restores the initial state.
- Notification at the end, subject to restored Mako mode: if DND was already activated before the session, it can remain silent.

## Technical and validation

State compatible with the old format: `end_epoch previous_dnd`, negative deadline for a break. Shared flock lock; workers release the lock while waiting and do not terminate a session whose deadline has changed. Restarting a session retains the initial DND. The worker survives the closure of the CC; This is not a persistent systemd service after reboot.

8 Focus tests with simulated Mako and notifications; 58 Python tests in total pass. QML and Bash syntax checked. No actual session started so as not to modify notifications from Toubi. Physical validation of clicks and rendering of the counter to be done.
