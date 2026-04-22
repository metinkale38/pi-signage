import logging
import asyncio
import os
import subprocess
import random
from bless import (
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions
)

# --- Konfiguration ---
WIFI_CONF = "/mnt/signage/config/wifi"
GENERAL_CONF = "/mnt/signage/config/config"
RCLONE_CONF = "/mnt/signage/config/rclone.conf"
MOUNT_POINT = "/mnt"
TTY_DEV = "/dev/tty2"

SERVICE_UUID = "610f8446-25e4-42d3-92af-6857f80cf6cd"
CHAR_OTP_UUID = "4d567391-5c91-4d73-9085-7d6e42e4b5a3"
CHAR_WIFI_UUID = "1b355391-3b91-4d73-9085-7d6e42e4b5a0"
CHAR_CONFIG_UUID = "2b455391-3b91-4d73-9085-7d6e42e4b5a1"
CHAR_RCLONE_UUID = "3c566391-4c91-4d73-9085-7d6e42e4b5a2"

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

current_otp = str(random.randint(100000, 999999))
authenticated = False
client_was_connected = False # Fehlte oben in deinen globalen Definitionen

# --- TTY Logik (Einmalig/Statisch) ---

def init_tty_static(otp):
    """Beschreibt TTY2 einmalig beim Start."""
    try:
        blue, green, white, reset = "\033[1;34m", "\033[1;32m", "\033[1;37m", "\033[0m"
        clear = "\033[c\033[2J\033[H"
        line = "=" * 60
        layout = (
            f"{clear}{blue}{line}\n"
            f"  {white}PI-SIGNAGE\n"
            f"{blue}{line}\n"
            f"  GITHUB: https://github.com/metinkale38/pi-signage \n"
            f"{blue}{'-' * 60}\n\n"
            f"  OTP-CODE:\n\n"
            f"      {green}>>> {otp} <<<{reset}\n\n"
            f"{blue}{'_' * 60}{reset}\n"
            f"  System will reboot after disconnect if changes were made.\n"
        )
        with open(TTY_DEV, "w") as tty:
            tty.write(layout)
    except Exception as e:
        logger.error(f"TTY Setup Error: {e}")

async def auto_switch_back(delay=15):
    await asyncio.sleep(delay)
    subprocess.run(["chvt", "1"])

# --- Hilfsfunktionen ---

def manage_mount(mode="ro"):
    subprocess.run(["mount", "-o", f"remount,{mode}", MOUNT_POINT])

def write_to_file(filepath, data):
    if not authenticated: return

    logger.info(f"Schreibe Datei {filepath}...")
    manage_mount("rw")
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, "w") as f:
        f.write(data)
    os.sync()
    manage_mount("ro")

# --- BLE Callbacks ---

def on_read(characteristic: BlessGATTCharacteristic):
    if characteristic.uuid == CHAR_OTP_UUID:
        return bytearray("Enter Code", "utf-8")
    if not authenticated:
        return bytearray("LOCKED", "utf-8")

    path = {
        CHAR_WIFI_UUID: WIFI_CONF,
        CHAR_CONFIG_UUID: GENERAL_CONF,
        CHAR_RCLONE_UUID: RCLONE_CONF
    }.get(characteristic.uuid)

    if path and os.path.exists(path):
        with open(path, "r") as f:
            return bytearray(f.read(), "utf-8")
    return bytearray("", "utf-8")

# --- BLE Callbacks ---

def on_write(characteristic: BlessGATTCharacteristic, value: bytearray):
    global authenticated
    val = value.decode("utf-8").strip()

    if characteristic.uuid == CHAR_OTP_UUID:
        if val == "SHOWOTP":
            subprocess.run(["chvt", "2"])
            asyncio.create_task(auto_switch_back())
            logger.info("OTP auf TTY2 angezeigt.")

        elif val == current_otp:
            authenticated = True
            subprocess.run(["chvt", "1"])
            logger.info("Authentifizierung erfolgreich.")

        elif val == "REBOOT" and authenticated:
            logger.info("Reboot-Befehl empfangen. Starte neu...")
            os.system("sync")
            os.system("sleep 1 && sudo reboot &")

    elif authenticated:
        path = {
            CHAR_WIFI_UUID: WIFI_CONF,
            CHAR_CONFIG_UUID: GENERAL_CONF,
            CHAR_RCLONE_UUID: RCLONE_CONF
        }.get(characteristic.uuid)
        if path:
            write_to_file(path, val)

# --- Main Loop ---

async def run():
    # Bluetooth & TTY Hardware Setup
    os.system('rfkill unblock bluetooth && hciconfig hci0 up')
    os.system(f'setterm -cursor off -blank 0 > {TTY_DEV} 2>/dev/null')

    # TTY2 EINMALIG beschreiben
    init_tty_static(current_otp)

    server = BlessServer(name="pi-signage")
    server.read_request_func = on_read
    server.write_request_func = on_write

    await server.add_new_service(SERVICE_UUID)

    for uuid in [CHAR_OTP_UUID, CHAR_WIFI_UUID, CHAR_CONFIG_UUID, CHAR_RCLONE_UUID]:
        await server.add_new_characteristic(
            SERVICE_UUID, uuid,
            GATTCharacteristicProperties.read | GATTCharacteristicProperties.write,
            bytearray("Init", "utf-8"),
            GATTAttributePermissions.readable | GATTAttributePermissions.writeable
        )

    await server.start()
    logger.info("BLE Server läuft...")
    while True:
        await asyncio.sleep(1)

if __name__ == "__main__":
    asyncio.run(run())