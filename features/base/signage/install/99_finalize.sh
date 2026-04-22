#!/bin/bash
sync
raspi-config nonint do_overlayfs 0
reboot