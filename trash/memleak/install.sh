#!/bin/sh
cp ./memleak /usr/sbin/memleak
cp ./memleak.service /lib/systemd/system/memleak.service
systemctl daemon-reload
