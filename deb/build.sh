#!/bin/sh -v
mkdir deb/package
make build_deb DESTDIR=deb/package BINDIR=/usr/bin SYSTEMDUNITDIR=/lib/systemd/system
cd deb
cp -r DEBIAN package/
fakeroot dpkg-deb --build package
