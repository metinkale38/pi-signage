#!/bin/bash

find / -xdev -type f -name "*.symlink" -print0 | while IFS= read -r -d '' file; do
    target=$(cat "$file" | tr -d '\r')
    link_name="${file%.symlink}"
    echo "Transformiere: $file -> $link_name"

    mkdir -p "$(dirname "$link_name")"
    ln -sfn "$target" "$link_name"
    rm "$file"
done