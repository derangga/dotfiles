"""Drive a Ghostty face shader from herdr's Claude agent state.

Asks herdr what the focused pane is doing, and points Ghostty's custom-shader
at a matching pre-built variant when the answer changes.

Why swap paths instead of rewriting one shader file: Ghostty does not watch
shader contents. Upstream src/cli/edit_config.zig says outright there is "no
CLI reload command and no automatic file watching", so changing the configured
path and reloading is the only route.

Why poll instead of subscribing to events: herdr's events carry a focused pane
id that is not the user's focus. herdr probes panes by focusing them, so
layout.updated and pane.focused both flap between panes and across workspaces
several times a second -- measured against herdr 0.8.0, a stream that reported
w3K:p6 while the session's real focus sat on w3K:p1 throughout. Queried state
has no such problem: 6198 consecutive polls of pane.layout returned the same
answer while the event stream was flapping. Subscribing would not even save
wakeups, since pane.updated fires ~3.6/s whether or not anything happened.

Run with a state name to apply it once and exit -- the only practical way to
eyeball face placement without driving a real Claude session:

    ghost-watch idle
"""

import json
import os
import signal
import socket
import subprocess
import sys
import time

SOCKET = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser(
    "~/.config/herdr/herdr.sock"
)
VARIANTS = os.environ.get("GHOST_VARIANTS", "")
FRAGMENT = os.environ.get(
    "GHOST_FRAGMENT", os.path.expanduser("~/.local/state/ghost-in-the-machine/ghostty.conf")
)
PS = os.environ.get("GHOST_PS", "/bin/ps")

# herdr's agent_status vocabulary is idle/working/blocked/done/unknown. It has
# no error state, so the shader's red "worry" face goes unused. "blocked" means
# Claude is sitting on a permission prompt, which is what the yellow
# question-mark face already means, so it lands there.
STATUS_MAP = {
    "idle": "idle",
    "working": "working",
    "blocked": "thinking",
    "done": "done",
}
AGENTS = {"claude"}
OFF = "off"
STATES = set(STATUS_MAP.values()) | {"error", OFF}

# herdr reports the terminal area's left edge in columns. Anything this small
# means the sidebar is collapsed, and the face -- pinned at a fixed pixel offset
# inside the sidebar -- would otherwise sit on top of terminal text.
COLLAPSED_X = 4

POLL_SECONDS = 0.25
RETRY_SECONDS = 2


def log(message):
    print(f"{time.strftime('%H:%M:%S')} {message}", file=sys.stderr, flush=True)


def request(method, params=None):
    """One request, one response. herdr closes the connection after replying."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.settimeout(2)
        sock.connect(SOCKET)
        body = {"id": f"ghost:{method}", "method": method, "params": params or {}}
        sock.sendall((json.dumps(body) + "\n").encode())
        line = sock.makefile("r", encoding="utf-8").readline()
    if not line:
        raise ConnectionError(f"{method}: herdr closed without replying")
    message = json.loads(line)
    if "error" in message:
        raise ConnectionError(f"{method}: {message['error']}")
    return message.get("result") or {}


def current_state():
    """Ask herdr what face to show. Raises if herdr is unreachable."""
    layout = request("pane.layout").get("layout") or {}
    x = (layout.get("area") or {}).get("x")
    if isinstance(x, (int, float)) and x <= COLLAPSED_X:
        return OFF
    pane_id = layout.get("focused_pane_id")
    if not pane_id:
        return OFF
    pane = request("pane.get", {"pane_id": pane_id}).get("pane") or {}
    if pane.get("agent") not in AGENTS:
        return OFF
    return STATUS_MAP.get(pane.get("agent_status"), OFF)


def ghostty_pids():
    """Return Ghostty PIDs.

    pi used `pgrep -x ghostty`; ps is used here because pgrep failed to match
    anything at all during testing on this machine while ps worked everywhere.
    """
    result = subprocess.run([PS, "-Ao", "pid,ucomm"], capture_output=True, text=True)
    pids = []
    for line in result.stdout.splitlines()[1:]:
        parts = line.split(None, 1)
        if len(parts) == 2 and parts[1].strip() == "ghostty":
            pids.append(int(parts[0]))
    return pids


def reload_ghostty():
    pids = ghostty_pids()
    if not pids:
        # Loud on purpose. pi swallowed this with `|| true`, which makes a
        # reload that never fires look identical to a working install that
        # happens to do nothing.
        log("no ghostty process found; shader not reloaded")
        return
    for pid in pids:
        try:
            os.kill(pid, signal.SIGUSR2)
        except OSError as err:
            log(f"signalling {pid} failed: {err}")


def write_fragment(state):
    os.makedirs(os.path.dirname(FRAGMENT), exist_ok=True)
    if state == OFF:
        # Empty of shader directives, so Ghostty is left with whatever the main
        # config sets (cursor_blaze) and nothing of ours.
        text = "# ghost-in-the-machine: off\n"
    else:
        text = f"custom-shader = {os.path.join(VARIANTS, state + '.glsl')}\n"
    temporary = f"{FRAGMENT}.{os.getpid()}.tmp"
    with open(temporary, "w", encoding="utf-8") as handle:
        handle.write(text)
    os.replace(temporary, FRAGMENT)


def apply(state, applied):
    if state == applied:
        return applied
    write_fragment(state)
    reload_ghostty()
    log(f"applied {state}")
    return state


def selfcheck():
    """Exercise state resolution against canned herdr replies."""
    replies = {}

    def fake(method, params=None):
        if method == "pane.layout":
            return {"layout": replies["layout"]}
        return {"pane": replies["panes"].get(params["pane_id"], {})}

    global request
    real, request = request, fake
    try:
        replies["panes"] = {
            "p1": {"agent": "claude", "agent_status": "working"},
            "p2": {"agent": "claude", "agent_status": "blocked"},
            "p3": {"agent": "opencode", "agent_status": "working"},
            "p4": {},
        }

        def focus(pane_id, x=26):
            replies["layout"] = {"focused_pane_id": pane_id, "area": {"x": x}}

        focus("p1")
        assert current_state() == "working"
        # blocked is a permission prompt: the question-mark face.
        focus("p2")
        assert current_state() == "thinking"
        # Other agents and bare shells are off.
        focus("p3")
        assert current_state() == OFF
        focus("p4")
        assert current_state() == OFF
        # Collapsed sidebar wins over everything.
        focus("p1", x=0)
        assert current_state() == OFF
        focus("p1", x=26)
        assert current_state() == "working"
        # An unknown status is not a face.
        replies["panes"]["p1"]["agent_status"] = "unknown"
        assert current_state() == OFF
        # No focused pane at all.
        focus(None)
        assert current_state() == OFF
    finally:
        request = real
    print("selfcheck ok")


def main():
    if len(sys.argv) > 1:
        state = sys.argv[1]
        if state == "--selfcheck":
            selfcheck()
            return
        if state not in STATES:
            sys.exit(f"usage: ghost-watch [--selfcheck|{'|'.join(sorted(STATES))}]")
        write_fragment(state)
        reload_ghostty()
        return

    # Before anything else. The fragment is a file on disk, so a crash or a
    # power cut mid-"working" would otherwise resurrect that face at next login
    # and keep it across reboots.
    applied = apply(OFF, None)
    down = False
    while True:
        try:
            state = current_state()
            if down:
                log("herdr back")
                down = False
        except Exception as err:
            # No herdr, no face -- this is what makes "only while herdr is open"
            # literally true rather than usually true.
            if not down:
                log(f"herdr unreachable: {err}")
                down = True
            state = OFF
        applied = apply(state, applied)
        time.sleep(RETRY_SECONDS if down else POLL_SECONDS)


if __name__ == "__main__":
    main()
