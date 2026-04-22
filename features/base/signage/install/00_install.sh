#!/bin/bash
# mount boot
mount -o remount,rw /boot/firmware
mount --bind -o rw / /mnt

iw dev wlan0 set power_save off

apt-get update

systemctl disable --now ModemManager avahi-daemon polkit e2scrub_reap.service rpi-resize-swap-file.service disable NetworkManager-wait-online.service
systemctl mask NetworkManager-wait-online.service

apt-get purge -y cloud-init && rm -rf /etc/cloud/ /var/lib/cloud/
apt-get autoremove -y


sed -i 's/console=tty1/console=tty3 quiet loglevel=3 vt.global_cursor_default=0 logo.nologo/' /boot/firmware/cmdline.txt
grep -q "disable_splash=1" /boot/firmware/config.txt || echo "disable_splash=1" | tee -a /boot/firmware/config.txt
