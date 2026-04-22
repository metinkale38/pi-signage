#!/bin/bash

systemctl disable NetworkManager
systemctl disable wpa_supplicant
systemctl mask NetworkManager
systemctl enable dhcpcd