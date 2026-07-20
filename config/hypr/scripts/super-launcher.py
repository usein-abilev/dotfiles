#!/usr/bin/env python3

import evdev
import fcntl
import os
import signal
import subprocess
import sys
import select
import time

APP_LAUNCHER_CMD = [
    "rofi", "-show", "drun",
]


def find_input_devices():
    devices = []
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        caps = dev.capabilities()
        if evdev.ecodes.EV_KEY not in caps:
            continue
        name = dev.name.lower()
        if any(skip in name for skip in [
            "mouse", "touchpad", "power button", "video bus",
            "hotkey", "tpad", "trackpoint",
        ]):
            continue
        key_caps = caps[evdev.ecodes.EV_KEY]
        if evdev.ecodes.KEY_A not in key_caps:
            continue
        devices.append(dev)
    return devices


def find_pointer_devices():
    devices = []
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        caps = dev.capabilities()
        if evdev.ecodes.EV_KEY not in caps:
            continue
        name = dev.name.lower()
        if not any(ptr in name for ptr in ["mouse", "touchpad", "trackpoint"]):
            continue
        devices.append(dev)
    return devices


def is_pid_alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def main():
    lock_fd = os.open("/tmp/super-launcher.lock", os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)

    signal.signal(signal.SIGCHLD, signal.SIG_IGN)
    devices = find_input_devices()
    pointer_devices = find_pointer_devices()
    if not devices:
        sys.exit(1)

    fds = {device.fd: device for device in devices + pointer_devices}

    super_held = False
    other_pressed = False
    launcher_pid = None

    while True:
        readable, _, _ = select.select(fds, [], [])
        for fd in readable:
            for event in fds[fd].read():
                if event.type != evdev.ecodes.EV_KEY:
                    continue

                if event.code == evdev.ecodes.KEY_LEFTMETA:
                    if event.value == 1:
                        super_held = True
                        other_pressed = False
                    elif event.value == 0:
                        if super_held and not other_pressed:
                            if launcher_pid is not None and is_pid_alive(launcher_pid):
                                os.kill(launcher_pid, signal.SIGTERM)
                                launcher_pid = None
                            else:
                                proc = subprocess.Popen(
                                    APP_LAUNCHER_CMD,
                                    preexec_fn=lambda: signal.signal(signal.SIGCHLD, signal.SIG_DFL),
                                )
                                launcher_pid = proc.pid
                        super_held = False
                        other_pressed = False
                elif event.value == 1 and super_held:
                    other_pressed = True


if __name__ == "__main__":
    if os.fork() > 0:
        sys.exit(0)
    main()
