#!/bin/sh
[ "$UID" -eq 0 ] || { echo "This script must run as root!"; exit 1; }

/etc/pihole/myblocklist.sh
sleep 10
pihole -g
sleep 10
/etc/init.d/pihole-FTL restart
