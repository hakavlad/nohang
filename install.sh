#!/bin/bash -v

cp -f nohang /usr/local/bin/
chmod 755 /usr/local/bin/nohang

mkdir /etc/nohang
chmod 755 /etc/nohang
cp -f nohang.conf /etc/nohang/
chmod 644 /etc/nohang/nohang.conf

gzip -k nohang.1
mkdir /usr/local/share/man/man1
chmod 755 /usr/local/share/man/man1
cp -f nohang.1.gz /usr/local/share/man/man1/
chmod 644 /usr/local/share/man/man1/nohang.1.gz

cp -f nohang.service /etc/systemd/system/
chmod 644 /etc/systemd/system/nohang.service
systemctl daemon-reload
systemctl enable nohang
systemctl restart nohang
