#!/bin/sh -v
mkdir deb/package
make build_deb \
	DESTDIR=deb/package \
	BINDIR=/usr/bin \
	CONFDIR=/etc \
	SYSTEMDUNITDIR=/lib/systemd/system \
	MANDIR=/usr/share/man/man1
cd deb
cp -r DEBIAN package/
fakeroot dpkg-deb --build package
