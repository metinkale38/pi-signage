#!/bin/bash

RPI_HOST=$1

if [ -z "$RPI_HOST" ]; then
    echo "Usage: $0 user@hostname-or-ip"
    exit 1
fi

ssh $RPI_HOST "sudo mount -o remount,rw /mnt"
rsync -avzv -W --rsync-path="sudo rsync" ./features/*/ $RPI_HOST:/mnt
rsync -avzv -W --rsync-path="sudo rsync" ./targets/chromium/ $RPI_HOST:/mnt
rsync -avzv -W --rsync-path="sudo rsync" ./config/ $RPI_HOST:/mnt/signage/config
ssh $RPI_HOST "sudo reboot"