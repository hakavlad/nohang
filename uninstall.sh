#!/bin/bash -v
systemctl stop nohang
systemctl disable nohang
rm /usr/local/share/man/man1/nohang.1.gz
rm /etc/systemd/system/nohang.service
rm /usr/local/bin/nohang
