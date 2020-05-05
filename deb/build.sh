#!/bin/sh -v
make \
	DESTDIR=deb/package \
	PREFIX=/usr \
	SYSCONFDIR=/etc \
	SYSTEMDUNITDIR=/lib/systemd/system \
	build_deb
cd deb
cp -r DEBIAN package/
fakeroot dpkg-deb --build package
