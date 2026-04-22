#!/bin/bash
apt-get install --no-install-recommends mpv --yes

systemctl daemon-reload
systemctl set-default signage-mpv.target