#!/bin/bash

# Sicherstellen, dass wir im richtigen Verzeichnis sind
cd /mnt/signage/media || exit

while true; do
  # Prüfen, ob Dateien vorhanden sind, um "Spam-Restarts" zu vermeiden
  if ls /mnt/signage/media/* >/dev/null 2>&1; then
    /usr/bin/mpv \
      --vo=drm \
      --hwdec=auto-safe \
      --image-display-duration=10 \
      --loop-playlist=inf \
      --player-operation-mode=pseudo-gui \
      /signage/media/* > /dev/tty1 2>&1
  else
    echo "Keine Medien gefunden, warte 10s..." > /dev/tty1
    sleep 10
  fi

  # Kurze Pause vor dem nächsten Versuch (verhindert CPU-Last bei Fehlern)
  sleep 2
done