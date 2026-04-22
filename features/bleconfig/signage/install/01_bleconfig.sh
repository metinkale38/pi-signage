#!/bin/bash

apt-get install --no-install-recommends dhcpcd5 bluez python3-pip python3-dev libdbus-1-dev libglib2.0-dev --yes
pip3 install bless --break-system-packages

systemctl mask getty@tty2.service
systemctl mask autovt@tty2.service