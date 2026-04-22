#!/bin/bash

systemctl mask getty@tty1.service

id -u chromium &>/dev/null || adduser --disabled-password --gecos "" chromium
for g in video input audio render; do getent group $g >/dev/null && usermod -aG $g chromium; done

apt-get install --no-install-recommends sway chromium libwayland-client0 libgbm1 seatd --yes