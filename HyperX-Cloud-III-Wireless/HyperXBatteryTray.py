"""HyperX Cloud III Wireless battery indicator for the Windows notification area."""

# Copyright (c) 2026 Red-Rood (GitHub: CrimsonRood). All rights reserved.

from __future__ import annotations

import argparse
import ctypes
import json
import os
import sys
import threading
import time
import winreg
from pathlib import Path

try:
    import hid
    import pystray
    from PIL import Image, ImageDraw, ImageFont
except ImportError as exc:
    print(
        "Faltan dependencias. Ejecuta Instalar-HyperXBatteryTray.cmd "
        f"(detalle: {exc})",
        file=sys.stderr,
    )
    raise SystemExit(2)


VENDOR_ID = 0x03F0
# Product IDs used by the HP HyperX Cloud III Wireless receiver/headset.
PRODUCT_IDS = (0x0C9D, 0x05B7)
PRODUCT_NAMES = ("Cloud III Wireless", "Cloud III")
DEVICE_NAME = "HyperX Cloud III Wireless"
REFRESH_SECONDS = 60


class BatteryReader:
    """Queries the Cloud III Wireless through its HID interface."""

    def __init__(self) -> None:
        self._lock = threading.Lock()

    def _find_device_info(self):
        matches = []
        for product_id in PRODUCT_IDS:
            try:
                matches.extend(hid.enumerate(VENDOR_ID, product_id))
            except OSError:
                continue

        if not matches:
            # A fallback by product name handles firmware revisions that keep
            # the same device name but receive a new product ID.
            try:
                all_devices = hid.enumerate(VENDOR_ID, 0)
            except OSError:
                all_devices = []
            matches = [
                item
                for item in all_devices
                if any(
                    token.lower() in str(item.get("product_string", "")).lower()
                    for token in PRODUCT_NAMES
                )
            ]

        if not matches:
            return None

        # Cloud III Wireless exposes the battery command on usage page 0xFEF3,
        # usage 1. Keep a name/PID fallback for receiver firmware variations.
        preferred = [
            item
            for item in matches
            if int(item.get("usage_page", 0)) == 65299
            and int(item.get("usage", 0)) == 1
        ]
        if preferred:
            return preferred[0]

        return max(
            matches,
            key=lambda item: (
                int(item.get("usage", 0)),
                int(item.get("usage_page", 0)),
            ),
        )

    def read(self) -> dict:
        with self._lock:
            info = self._find_device_info()
            if info is None:
                return {"state": "unavailable", "name": DEVICE_NAME, "percent": None}

            device = None
            try:
                device = hid.device()
                device.open_path(info["path"])
                device.set_nonblocking(False)

                # Cloud III Wireless battery request. The native monitor sends
                # a 52-byte HID output report and reads a 20-byte response;
                # byte 4 of that response is the percentage.
                request = [0] * 52
                request[0] = 0x66
                request[1] = 0x89
                device.write(request)
                response = device.read(20, 1000)
                if len(response) <= 4:
                    return {"state": "unavailable", "name": DEVICE_NAME, "percent": None}

                percent = int(response[4])
                if not 0 <= percent <= 100:
                    return {"state": "unavailable", "name": DEVICE_NAME, "percent": None}

                name = str(info.get("product_string") or DEVICE_NAME).strip()
                return {"state": "ready", "name": name, "percent": percent}
            except (OSError, RuntimeError, ValueError, TypeError, KeyError):
                return {"state": "unavailable", "name": DEVICE_NAME, "percent": None}
            finally:
                if device is not None:
                    try:
                        device.close()
                    except OSError:
                        pass


def _draw_headset(draw: ImageDraw.ImageDraw, color: tuple[int, int, int, int]) -> None:
    """Draw a compact headset silhouette around the battery indicator."""
    draw.arc((5, 2, 27, 26), 180, 360, fill=color, width=2)
    draw.rounded_rectangle((3, 13, 8, 24), radius=2, fill=color)
    draw.rounded_rectangle((24, 13, 29, 24), radius=2, fill=color)


def _draw_small_headset(draw: ImageDraw.ImageDraw, color: tuple[int, int, int, int]) -> None:
    """Draw a small headset mark beside the large percentage."""
    draw.arc((26, 5, 32, 14), 180, 360, fill=color, width=1)
    draw.rounded_rectangle((25, 9, 27, 16), radius=1, fill=color)
    draw.rounded_rectangle((30, 9, 32, 16), radius=1, fill=color)


def _load_percent_font(draw: ImageDraw.ImageDraw, text: str):
    font_paths = (
        r"C:\Windows\Fonts\seguisb.ttf",
        r"C:\Windows\Fonts\arialbd.ttf",
    )
    for size in (26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15):
        for font_path in font_paths:
            try:
                font = ImageFont.truetype(font_path, size)
                left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
                if right - left <= 25 and bottom - top <= 22:
                    return font
            except OSError:
                continue
    return ImageFont.load_default()


def create_battery_icon(percent: int) -> Image.Image:
    image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    outline = (105, 196, 245, 255)

    text = str(percent)
    font = _load_percent_font(draw, text)
    # Give the percentage the main visual area; the small headset acts as the
    # device marker and remains visible after Windows scales the tray image.
    draw.rounded_rectangle((0, 5, 26, 27), radius=3, fill=(20, 35, 48, 235))
    _draw_small_headset(draw, outline)
    left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
    text_width = right - left
    text_x = ((26 - text_width) // 2) - left
    text_y = (32 - (bottom - top)) // 2 - top - 1
    draw.text(
        (text_x, text_y),
        text,
        font=font,
        fill=(255, 255, 255, 255),
        stroke_width=1,
        stroke_fill=(20, 35, 48, 255),
    )
    return image


def create_status_icon() -> Image.Image:
    image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    warning = (240, 190, 62, 255)
    _draw_headset(draw, warning)
    draw.line((16, 12, 16, 18), fill=warning, width=2)
    draw.ellipse((15, 20, 17, 22), fill=warning)
    return image


def _publish_battery_snapshot(snapshot: dict) -> None:
    local_app_data = os.environ.get("LOCALAPPDATA")
    if not local_app_data:
        return
    directory = Path(local_app_data) / "Red-Rood" / "BatteryMonitor"
    target = directory / "hyperx.json"
    temporary = directory / "hyperx.json.tmp"
    payload = {**snapshot, "updatedAtUtc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
    try:
        directory.mkdir(parents=True, exist_ok=True)
        temporary.write_text(json.dumps(payload, ensure_ascii=True), encoding="utf-8")
        os.replace(temporary, target)
    except OSError:
        # Battery display remains usable if publishing for Stream Deck fails.
        try:
            temporary.unlink(missing_ok=True)
        except OSError:
            pass


class TrayApp:
    def __init__(self) -> None:
        self.reader = BatteryReader()
        self.snapshot = {"state": "unavailable", "name": DEVICE_NAME, "percent": None}
        self.stop_event = threading.Event()
        self.icon = pystray.Icon(
            "HyperXBatteryTray",
            create_status_icon(),
            "HyperX: buscando bateria...",
            menu=pystray.Menu(
                pystray.MenuItem(self._status_text, lambda: False),
                pystray.Menu.SEPARATOR,
                pystray.MenuItem("Actualizar ahora", self._refresh_now),
                pystray.MenuItem(
                    "Iniciar con Windows",
                    self._toggle_startup,
                    checked=lambda item: self._startup_enabled(),
                ),
                pystray.Menu.SEPARATOR,
                pystray.MenuItem("Salir", self._quit),
            ),
        )

    def _status_text(self, _item) -> str:
        if self.snapshot["state"] == "ready":
            return f"{self.snapshot['name']}: {self.snapshot['percent']}%"
        return "HyperX: bateria no disponible"

    def _refresh_now(self, _icon=None, _item=None) -> None:
        self.snapshot = self.reader.read()
        _publish_battery_snapshot(self.snapshot)
        if self.snapshot["state"] == "ready":
            percent = int(self.snapshot["percent"])
            label = f"HyperX: {percent}%"
            self.icon.icon = create_battery_icon(percent)
            self.icon.title = f"{label} - {self.snapshot['name']}"
        else:
            self.icon.icon = create_status_icon()
            self.icon.title = "HyperX: bateria no disponible"
        self.icon.update_menu()

    def _refresh_loop(self) -> None:
        while not self.stop_event.wait(REFRESH_SECONDS):
            self._refresh_now()

    def _startup_command(self) -> str:
        script_path = str(Path(__file__).resolve())
        pythonw = Path(sys.executable).with_name("pythonw.exe")
        executable = str(pythonw if pythonw.exists() else Path(sys.executable))
        return f'"{executable}" "{script_path}"'

    def _startup_enabled(self) -> bool:
        try:
            with winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Run",
                0,
                winreg.KEY_READ,
            ) as key:
                winreg.QueryValueEx(key, "HyperXBatteryTray")
                return True
        except FileNotFoundError:
            return False

    def _toggle_startup(self, _icon=None, item=None) -> None:
        with winreg.CreateKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
        ) as key:
            if item is not None and item.checked:
                winreg.SetValueEx(key, "HyperXBatteryTray", 0, winreg.REG_SZ, self._startup_command())
            else:
                try:
                    winreg.DeleteValue(key, "HyperXBatteryTray")
                except FileNotFoundError:
                    pass

    def _quit(self, _icon=None, _item=None) -> None:
        self.stop_event.set()
        self.icon.stop()

    def run(self) -> None:
        self._refresh_now()
        threading.Thread(target=self._refresh_loop, daemon=True).start()
        self.icon.run()


def main() -> int:
    parser = argparse.ArgumentParser(description="Monitor de bateria HyperX Cloud III Wireless")
    parser.add_argument("--probe", action="store_true", help="imprime una lectura JSON y termina")
    args = parser.parse_args()

    reader = BatteryReader()
    if args.probe:
        print(json.dumps(reader.read(), ensure_ascii=True))
        return 0

    if not ensure_notice_seen():
        return 0

    TrayApp().run()
    return 0


def ensure_notice_seen() -> bool:
    registry_path = r"Software\Red-Rood\HyperXCloudIIIWirelessBatteryTray"
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, registry_path) as key:
            seen, _ = winreg.QueryValueEx(key, "NoticeVersion")
            if seen == 2:
                return True
    except OSError:
        pass

    message = (
        "PROYECTO PERSONAL\n\n"
        "Creado para uso propio. Que el repositorio sea publico no significa que este programa se ofrezca "
        "como producto o servicio. No es oficial ni cuenta con soporte. "
        "Puede mostrar datos incorrectos o dejar de funcionar. No lo uses como unica referencia para decisiones "
        "importantes. Se ofrece tal cual, sin promesa de actualizaciones.\n\n"
        "Pulsa Aceptar para continuar."
    )
    answer = ctypes.windll.user32.MessageBoxW(
        None,
        message,
        "Aviso - HyperX Cloud III Wireless",
        0x00000001 | 0x00000040 | 0x00000100,  # OK/Cancel, information icon, default Cancel.
    )
    if answer != 1:  # IDOK
        return False

    try:
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, registry_path) as key:
            winreg.SetValueEx(key, "NoticeVersion", 0, winreg.REG_DWORD, 2)
    except OSError:
        # The app can still run; the notice will appear again next time.
        pass
    return True

if __name__ == "__main__":
    raise SystemExit(main())
