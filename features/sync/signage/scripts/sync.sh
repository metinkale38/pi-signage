#!/bin/bash

CONFIG="/signage/config/rclone.conf"
SOURCE="remote:."
DEST="/mnt/signage/media"

RCLONE_EXTRA_OPTS=$(grep "#rclone-opts" "$CONFIG" | sed 's/#rclone-opts=//')

CHECK_CMD="rclone --config \"$CONFIG\" check \"$SOURCE\" \"$DEST\" $RCLONE_EXTRA_OPTS --one-way --quiet"

if eval "$CHECK_CMD"; then
    echo "No changes detected. Skipping sync."
    exit 0
else
    echo "Changes detected. Starting sync..."
    mount -o remount,rw /mnt

    SYNC_CMD="rclone --config \"$CONFIG\" sync \"$SOURCE\" \"$DEST\" $RCLONE_EXTRA_OPTS --delete-after --size-only --transfers 1"

    if eval "$SYNC_CMD"; then
        sync
        mount -o remount,ro /mnt
        systemctl restart $(basename $(readlink -f /etc/systemd/system/default.target))
        exit 0
    else
        mount -o remount,ro /mnt
        exit 1
    fi
fi