#!/bin/sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
rm -rf /home/chromium/.config/chromium/SingletonLock
CONFIG_FILE="/mnt/signage/config/config"

config=""
[ -r "$CONFIG_FILE" ] && config="$(cat "$CONFIG_FILE")"

exec chromium --ozone-platform=wayland \
          --enable-features=UseOzonePlatform \
          --kiosk \
          --no-first-run \
          --disable-translate \
          --disable-features=Translate,MediaRouter,WaylandWindowDecorations \
          --incognito \
          --disable-infobars \
          --no-sandbox \
          --disable-sync \
          --use-gl=egl \
          --use-angle=gles \
          --no-memcheck \
          --start-fullscreen \
          --autoplay-policy=no-user-gesture-required \
          --enable-features=VaapiVideoDecoder \
          --disable-web-security \
          --user-data-dir="/tmp/chrome_kiosk" \
          "$config"