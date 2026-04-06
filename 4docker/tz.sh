#!/usr/bin/env bash
set -e

if [ ! -f /usr/share/zoneinfo/Europe/Paris ]; then
    if [ "$1" = "apt" ]; then
        apt-get install -y --no-install-recommends tzdata \
        && rm -rf /var/lib/apt/lists/*
    elif [ "$1" = "apk" ]; then
        apk add --no-cache tzdata
    else
        exit 1
    fi
fi

echo "Europe/Paris" > /etc/timezone
ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
