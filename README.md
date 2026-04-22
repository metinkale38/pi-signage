# PI Signage

A simple digital signage solution for Raspberry Pi. It allows you to display images, videos, and web pages on a connected display.

## Modes of operation:

### MPV
- Slideshow mode for images and videos

#### Instructions for MPV:
1. Install MPV with ./install.sh mpv pi@HOST
2. Open https://metinkale38.github.io/pi-signage/
3. Fill in rclone configuration to sync media files from cloud storage. Use "remote" as the name of the remote.

### Chromium
- Kiosk mode for web pages

#### Instructions for Chromium:
1. Install Chromium with ./install.sh chromium pi@HOST
2. Open https://metinkale38.github.io/pi-signage/
3. Fill in the URL of the web page you want to display under "Config". Use http://localhost:8000 for integrated web server.
4. Fill in rclone configuration to sync website from cloud storage. Use "remote" as the name of the remote.

## Features:
- Sync media and web content with rclone
- Integrated Web-Server
- HDMI-CEC support for power control (http://localhost:8000/on and http://localhost:8000/off)
- Easy configuration through BLE