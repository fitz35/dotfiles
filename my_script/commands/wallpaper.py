"""One random wallpaper per workspace, from the dotfiles assets, renewed every INTERVAL seconds.

Started by i3 / sway (exec_always : a sway reload clears the background, the restart sets one at once) and runs
until the session ends. Neither sway nor i3 has a per-workspace background : this listens to the workspace
events and swaps the image of a screen when the workspace shown on it changes. Idle cost : none (it blocks on
the IPC events, no polling) ; per switch : one IPC request to awww-daemon, which keeps the decoded images
(`swaymsg output bg` would reconfigure the output and respawn swaybg, decoding the PNG again : a visible lag).
X (i3) : feh, Wayland (sway) : awww, or the sway background when awww is not installed.
"""

import json
import os
import random
import select
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path
from types import FrameType
from typing import TypedDict, cast

INTERVAL = 240  # seconds
# the files of the subfolders too (private/ : the git-ignored images, kept out of the public repo) ; the
# assets folder is a link into the dotfiles (rglob follows it : it is the starting point)
IMAGES_DIR = Path.home() / ".config/assets/background_image"
# the running loop, so a restarted one (exec_always after a reload) can stop it
PID_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "my_script_wallpaper.pid"

WAYLAND = bool(os.environ.get("WAYLAND_DISPLAY"))
# i3-msg in i3, swaymsg in sway (same IPC)
WM_MSG = "swaymsg" if WAYLAND else "i3-msg"


class Workspace(TypedDict):
    name: str
    visible: bool
    output: str


def stop_previous() -> None:
    """Stop the loop started before the reload (one loop only), checking the pid is still that loop."""
    try:
        pid = int(PID_FILE.read_text())
        cmdline = Path(f"/proc/{pid}/cmdline").read_bytes()
    except (OSError, ValueError):
        pid, cmdline = 0, b""
    if pid != os.getpid() and b"commands/wallpaper.py" in cmdline:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    _ = PID_FILE.write_text(str(os.getpid()))


def list_images() -> list[str]:
    # read again at each rotation : a new image is used without a restart
    return sorted(str(p) for p in IMAGES_DIR.rglob("*") if p.is_file())


def visible_workspaces() -> dict[str, str]:
    """output -> name of the workspace shown on it."""
    result = subprocess.run([WM_MSG, "-t", "get_workspaces"], capture_output=True, text=True, check=True)
    workspaces = cast(list[Workspace], json.loads(result.stdout))
    return {w["output"]: w["name"] for w in workspaces if w["visible"]}


def x_screen_order() -> list[str]:
    """Output names in the order feh gives the images to the screens (the xrandr monitor index)."""
    result = subprocess.run(["xrandr", "--listactivemonitors"], capture_output=True, text=True, check=True)
    # first line : "Monitors: 2", then " 0: +*eDP-1 1920/344x1080/193+0+0  eDP-1"
    return [line.split()[-1] for line in result.stdout.splitlines()[1:] if line.strip()]


def start_awww() -> bool:
    """Make sure awww-daemon runs ; False when awww is missing or does not answer (use the sway background)."""
    if shutil.which("awww") is None or shutil.which("awww-daemon") is None:
        return False
    if subprocess.run(["pgrep", "-f", "awww-daemon"], capture_output=True, check=False).returncode != 0:
        _ = subprocess.Popen(
            ["awww-daemon"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,  # outlives this loop : its cache is the point
        )
    for _attempt in range(20):
        if subprocess.run(["awww", "query"], capture_output=True, check=False).returncode == 0:
            return True
        time.sleep(0.05)
    return False


class Wallpapers:
    def __init__(self) -> None:
        self.images: list[str] = list_images()
        self.ws_image: dict[str, str] = {}  # workspace -> its image, kept for the session
        self.shown: dict[str, str] = {}  # output -> image drawn on it now (no redraw when unchanged)
        self.awww: bool = WAYLAND and start_awww()

    def pick(self, taken: set[str]) -> str:
        # not an image already on another screen, when there are enough of them
        free = [i for i in self.images if i not in taken] or self.images
        return random.choice(free)

    def redraw(self) -> None:
        if not self.images:
            return
        visible = visible_workspaces()
        wanted: dict[str, str] = {}
        for output, ws in visible.items():
            if self.ws_image.get(ws) not in self.images:  # first visit, or the image was removed
                self.ws_image[ws] = self.pick({self.ws_image.get(w, "") for w in visible.values()})
            wanted[output] = self.ws_image[ws]
        if WAYLAND:
            for output, image in wanted.items():
                if self.shown.get(output) != image:
                    if self.awww:
                        # crop = sway's fill
                        cmd = ["awww", "img", "-o", output, "--resize", "crop", "--transition-type", "none", image]
                    else:
                        cmd = [WM_MSG, "output", output, "bg", image, "fill"]
                    _ = subprocess.run(cmd, capture_output=True, check=False)
        elif wanted != self.shown:
            # feh sets every screen at once, the n-th image on the n-th screen
            order = x_screen_order()
            fallback = next(iter(wanted.values()))
            images = [wanted.get(output, fallback) for output in order]
            _ = subprocess.run(["feh", "--bg-fill", *images], check=False)
        self.shown = wanted

    def rotate(self) -> None:
        """New images for the visible workspaces (the others keep theirs until they are shown again)."""
        self.images = list_images()
        visible = visible_workspaces().values()
        for ws in visible:
            _ = self.ws_image.pop(ws, None)
        self.redraw()


def main() -> None:
    stop_previous()
    events = subprocess.Popen(
        [WM_MSG, "-t", "subscribe", "-m", '["workspace", "output"]'], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL
    )

    def stop(_signum: int, _frame: FrameType | None) -> None:
        # the event listener would otherwise stay alive, alone
        events.terminate()
        sys.exit(0)

    _ = signal.signal(signal.SIGTERM, stop)
    _ = signal.signal(signal.SIGINT, stop)

    stdout = events.stdout
    if stdout is None:
        sys.exit(1)
    fd = stdout.fileno()
    wallpapers = Wallpapers()
    wallpapers.redraw()
    # a deadline, not a timeout per wait : the workspace events must not delay the rotation
    next_rotation = time.monotonic() + INTERVAL
    while True:
        ready, _, _ = select.select([fd], [], [], max(0.0, next_rotation - time.monotonic()))
        if not ready:
            wallpapers.rotate()
            next_rotation = time.monotonic() + INTERVAL
            continue
        # the content doesn't matter : any event (focus, new output...) means "check what is shown" ; read
        # everything waiting, so a burst of events gives one redraw
        if not os.read(fd, 65536):
            sys.exit(0)  # the window manager is gone : end of the session
        wallpapers.redraw()


if __name__ == "__main__":
    main()
