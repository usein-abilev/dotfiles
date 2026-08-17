#!/usr/bin/env python3
"""voice-dictation - voice dictation for the opencode TUI.

Hold Right Alt, speak, release - the transcript is pasted into the
focused window via wl-copy + Ctrl+Shift+V.

Prerequisites:
    System packages (Arch names; Debian/Fedora equivalents inline):
        ydotool            - synthetic key injection daemon + CLI
        wl-clipboard       - provides wl-copy
        libnotify          - provides notify-send (Debian/Ubuntu: libnotify-bin)
        python-evdev       - evdev Python bindings (Debian/Ubuntu/Fedora: python3-evdev)
        python-numpy       - array math (Debian/Ubuntu/Fedora: python3-numpy)
    Python venv at ~/whisper-local/venv/ with:
        faster-whisper
        nvidia-cublas-cu12             (GPU only; see CUDA setup below)
    ydotoold daemon running (start with `ydotoold &`).
    Hyprland autostart launching the script and ydotoold (see
    config/hypr/autostart.lua in this repo).

CUDA setup (GPU only):
    If faster-whisper raises `libcublas.so: cannot open shared object file`, the venv's nvidia/cublas/lib is not on the linker path. Fix:
        # Find the cuBLAS path your venv installed:
        find ~/whisper-local/venv/lib -name 'libcublas.so*' -printf '%h\n' | sort -u
        # Add it system-wide:
        echo '<path-from-above>' | sudo tee /etc/ld.so.conf.d/cuda.conf
        sudo ldconfig
        # Verify:
        ldconfig -p | grep libcublas
    Should list both libcublas.so.12 and libcublasLt.so.12.

Run via the existing ~/whisper-local/venv:
    ~/whisper-local/venv/bin/python ~/dotfiles/scripts/voice-dictation.py

Configuration via environment variables:
    HOTKEY_ALT        evdev key code, default KEY_RIGHTALT
    MODEL_GPU         default medium
    MODEL_CPU         default medium
    COMPUTE_GPU       default float16
    COMPUTE_CPU       default int8
    SAMPLE_RATE       default 16000
    LANGUAGE          default None (auto-detect per utterance)

Troubleshooting:
    Right Alt does nothing:
        ydotoold is not running. Check with `pgrep -x ydotoold`. Add it
        to Hyprland autostart: `hl.exec_cmd("ydotoold &")`.

    Permission denied on /dev/input/event*:
        The script reads evdev directly without grabbing the device.
        Add yourself to the `input` group:
            sudo usermod -aG input $USER
        Then log out and back in (or add a udev rule for the device).

    Nothing pasted after Right Alt release:
        Check ~/.local/state/voice-dictation.log for the `transcribed:`
        line. The model loads lazily on first use (~3s on medium); the
        first release shows the line 3s later. If faster-whisper errors
        with `libcublas.so: cannot open shared object file`, see CUDA
        setup above.

    wl-copy not found / ydotool not found:
        Install the system packages listed in Prerequisites.

    No notifications:
        Ensure a notification daemon is running (swaync, mako, dunst).

    Log location:
        ~/.local/state/voice-dictation.log (override with XDG_STATE_HOME)
"""

import fcntl
import os
import select
import shutil
import signal
import subprocess
import sys
import threading
import time
import traceback
from pathlib import Path
from typing import Optional

import evdev
import numpy as np


HOTKEY_ALT = os.environ.get("HOTKEY_ALT", "KEY_RIGHTALT")
MODEL_GPU = os.environ.get("MODEL_GPU", "medium")
MODEL_CPU = os.environ.get("MODEL_CPU", "medium")
COMPUTE_GPU = os.environ.get("COMPUTE_GPU", "float16")
COMPUTE_CPU = os.environ.get("COMPUTE_CPU", "int8")
SAMPLE_RATE = int(os.environ.get("SAMPLE_RATE", "16000"))
LANGUAGE = os.environ.get("LANGUAGE") or None
CHANNELS = 1

LOCK_PATH = "/tmp/voice-dictation.lock"
LOG_PATH = Path(
    os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))
) / "voice-dictation.log"


def log(msg: str) -> None:
    line = f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}"
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with LOG_PATH.open("a") as f:
            f.write(line + "\n")
    except OSError:
        pass
    if sys.stderr.isatty():
        print(line, file=sys.stderr)


def notify(title: str, body: str, urgency: str = "low") -> None:
    try:
        subprocess.Popen(
            ["notify-send", "-u", urgency, title, body],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError as e:
        log(f"notify-send failed: {e}")


def acquire_lock() -> Optional[int]:
    fd = os.open(LOCK_PATH, os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        os.close(fd)
        return None
    return fd


def find_keyboard_devices():
    """Find keyboard devices. Filters mice, touchpads, power/video bus."""
    devices = []
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        caps = dev.capabilities()
        if evdev.ecodes.EV_KEY not in caps:
            continue
        name = dev.name.lower()
        if any(skip in name for skip in [
            "mouse", "touchpad", "tpad", "trackpoint",
            "power button", "video bus",
        ]):
            continue
        key_caps = caps[evdev.ecodes.EV_KEY]
        if evdev.ecodes.KEY_A not in key_caps:
            continue
        devices.append(dev)
    return devices


class Recorder:
    def __init__(self, sample_rate: int, channels: int):
        import sounddevice as sd
        self._sd = sd
        self.sample_rate = sample_rate
        self.channels = channels
        self._stream: Optional[sd.RawInputStream] = None
        self._chunks: list = []
        self._lock = threading.Lock()

    def start(self) -> None:
        self._chunks = []
        self._stream = self._sd.RawInputStream(
            samplerate=self.sample_rate,
            channels=self.channels,
            dtype="int16",
            blocksize=int(self.sample_rate * 0.1),
            callback=self._on_audio,
        )
        self._stream.start()

    def stop(self) -> np.ndarray:
        if self._stream is not None:
            self._stream.stop()
            self._stream.close()
            self._stream = None
        with self._lock:
            if not self._chunks:
                return np.empty((0,), dtype=np.int16)
            return np.concatenate(self._chunks)

    def _on_audio(self, indata, frames, time_info, status) -> None:
        if status:
            log(f"audio status: {status}")
        with self._lock:
            self._chunks.append(np.frombuffer(indata, dtype=np.int16).copy())


class Transcriber:
    def __init__(self):
        self._model = None

    def _load(self) -> None:
        from faster_whisper import WhisperModel
        if shutil.which("nvidia-smi"):
            device = "cuda"
            compute = COMPUTE_GPU
            name = MODEL_GPU
        else:
            device = "cpu"
            compute = COMPUTE_CPU
            name = MODEL_CPU
        log(f"loading model={name} device={device} compute={compute}")
        try:
            self._model = WhisperModel(name, device=device, compute_type=compute)
        except Exception as e:
            notify(
                "Dictation failed",
                f"could not load whisper-{name}: {e}",
                urgency="critical",
            )
            raise
        log("model loaded")
        notify(
            "Dictation ready",
            f"whisper-{name} on {device} - Hold Right Alt to dictate",
            urgency="low",
        )

    def transcribe(self, audio: np.ndarray) -> str:
        if self._model is None:
            self._load()
        if audio.size == 0:
            return ""
        audio_f = audio.astype(np.float32) / 32768.0
        segments, _info = self._model.transcribe(
            audio_f,
            language=LANGUAGE,
            beam_size=5,
            vad_filter=True,
        )
        return " ".join(seg.text.strip() for seg in segments).strip()


def paste(text: str) -> None:
    if not text:
        return
    try:
        p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
        try:
            p.communicate(text.encode("utf-8"), timeout=5)
        except subprocess.TimeoutExpired:
            p.kill()
            log("wl-copy timed out")
            return
    except FileNotFoundError:
        log("wl-copy not found; cannot paste")
        return

    time.sleep(0.15)
    if shutil.which("ydotool"):
        try:
            subprocess.run(
                ["ydotool", "key", "29:1", "42:1", "47:1", "47:0", "42:0", "29:0"],
                check=True, timeout=5,
            )
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            log(f"ydotool failed: {e}")
    else:
        log("ydotool not found; text on clipboard only")


def main() -> int:
    lock_fd = acquire_lock()
    if lock_fd is None:
        log("another instance is running; exiting")
        return 0

    log("started")

    signal.signal(signal.SIGCHLD, signal.SIG_IGN)

    shutdown_r, shutdown_w = os.pipe()
    fcntl.fcntl(shutdown_r, fcntl.F_SETFL, os.O_NONBLOCK)
    fcntl.fcntl(shutdown_w, fcntl.F_SETFL, os.O_NONBLOCK)

    def request_shutdown(signum, frame):
        try:
            os.write(shutdown_w, b"x")
        except OSError:
            pass

    signal.signal(signal.SIGTERM, request_shutdown)
    signal.signal(signal.SIGINT, request_shutdown)

    alt_code = getattr(evdev.ecodes, HOTKEY_ALT, None)
    if alt_code is None:
        log(f"unknown hotkey: {HOTKEY_ALT}")
        return 1

    devices = find_keyboard_devices()
    if not devices:
        log("no keyboard devices found")
        return 1

    fds = {dev.fd: dev for dev in devices}
    log(
        f"listening on {len(devices)} keyboard(s); "
        f"hotkey = {HOTKEY_ALT}"
    )

    recorder = Recorder(SAMPLE_RATE, CHANNELS)
    transcriber = Transcriber()
    alt_held = False
    recording = False

    try:
        while True:
            readable, _, _ = select.select(
                [shutdown_r] + list(fds.keys()), [], []
            )
            shutdown_signaled = False
            for fd in readable:
                if fd == shutdown_r:
                    try:
                        os.read(shutdown_r, 1)
                    except BlockingIOError:
                        pass
                    shutdown_signaled = True
                    continue
                for event in fds[fd].read():
                    if event.type != evdev.ecodes.EV_KEY:
                        continue
                    if event.code != alt_code:
                        continue
                    alt_held = event.value > 0

                    if alt_held and not recording:
                        recording = True
                        recorder.start()
                        log("recording started")
                    elif not alt_held and recording:
                        recording = False
                        audio = recorder.stop()
                        text = transcriber.transcribe(audio)
                        if text:
                            print(text, flush=True)
                            paste(text)
                            log(f"transcribed: {text!r}")
                        else:
                            log("empty transcription; skipped")
            if shutdown_signaled:
                if recording:
                    recording = False
                    recorder.stop()
                log("shutdown requested")
                break
    except KeyboardInterrupt:
        log("interrupted")
    except Exception as e:
        log(f"UNCAUGHT in main loop: {e}\n{traceback.format_exc()}")
    finally:
        try:
            os.close(shutdown_r)
            os.close(shutdown_w)
        except OSError:
            pass
        os.close(lock_fd)
    return 0


if __name__ == "__main__":
    sys.exit(main())
