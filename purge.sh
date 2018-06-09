#!/bin/bash -v
systemctl stop nohang
systemctl disable nohang
rm -f /usr/local/share/man/man1/nohang.1.gz
rm -f /etc/systemd/system/nohang.service
rm -rf /etc/nohang
rm -f /usr/local/bin/nohang
