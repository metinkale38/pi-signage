#!/bin/bash

MODE=$1
RPI_HOST=$2

if [[ ! "$MODE" =~ ^(chromium|mpv)$ ]] || [ -z "$RPI_HOST" ]; then
    echo "Usage: $0 [chromium|mpv] user@hostname-or-ip"
    exit 1
fi

rsync -avzv -W --rsync-path="sudo rsync" ./features/*/ $RPI_HOST:/
rsync -avzv -W --rsync-path="sudo rsync" ./targets/$MODE/ $RPI_HOST:/
rsync -avzv -W --rsync-path="sudo rsync" ./config/ $RPI_HOST:/signage/config

ssh $RPI_HOST << EOF
    sudo chmod +x /signage/scripts/*.sh
    sudo chmod +x /signage/install/*.sh

    for f in /signage/install/[0-9][0-9]*.sh; do
        if [ -f "\$f" ]; then
            sudo bash -x "\$f" || exit 1
        fi
    done
EOF