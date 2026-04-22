#!/bin/bash

OTP="${1:-000000}"
TITLE="PI-SIGNAGE"
GITHUB="github.com/metinkale38/pi-signage"
TTY_DEV="/dev/tty2"

echo -e "\e[H\e[2J\e[3J" | sudo tee $TTY_DEV > /dev/null

{
    echo "================================================================================"
    echo "  $TITLE"
    echo "================================================================================"
    echo "  NODE: $(hostname) | LINK: $GITHUB"
    echo "--------------------------------------------------------------------------------"
    echo -e "\n\n  DEIN LOGIN-CODE:\n"
    echo -e "      \e[1;32m>>> $OTP <<<\e[0m\n"
    echo "________________________________________________________________________________"
} | sudo tee $TTY_DEV



chvt 2

sleep 10

chvt 1