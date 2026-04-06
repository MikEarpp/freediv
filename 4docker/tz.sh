#!/usr/bin/env bash
set -e
[ -f /usr/share/zoneinfo/Europe/Paris ] || {
    if [ "$1" = "apt" ]; then
        apt-get install -y --no-install-recommends tzdata \
        && rm -rf /var/lib/apt/lists/*
    elif [ "$1" = "apk" ]; then
        apk add --no-cache tzdata
    else
        exit 1
    fi
}
echo "Europe/Paris" > /etc/timezone
ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
