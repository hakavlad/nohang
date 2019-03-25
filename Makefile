VERSION ?= $(shell git describe --tags --long --dirty > /etc/nohang/version 2> /dev/null)
PREFIX = /

all:
	@ echo "Nothing to compile. Use: make install, make uninstall, make systemd"

install:
	install -d $(DESTDIR)/$(PREFIX)/usr/sbin
	install -m0755 ./nohang $(DESTDIR)/$(PREFIX)/usr/sbin/nohang
	install -m0755 ./nohang_notify_helper $(DESTDIR)/$(PREFIX)/usr/sbin/nohang_notify_helper

	install -d $(DESTDIR)/$(PREFIX)/usr/bin
	install -m0755 ./oom-sort $(DESTDIR)/$(PREFIX)/usr/bin/oom-sort

	install -d $(DESTDIR)/$(PREFIX)/etc/nohang
	install -m0644 ./nohang.conf $(DESTDIR)/$(PREFIX)/etc/nohang/$(VERSION)
	install -m0644 ./nohang.conf $(DESTDIR)/$(PREFIX)/etc/nohang/nohang.conf.default

	install -m0644 ./nohang.logrotate $(DESTDIR)/$(PREFIX)/etc/logrotate.d/nohang

	install -d $(DESTDIR)/$(PREFIX)/usr/share/man/man1
	gzip -c nohang.1 > $(DESTDIR)/$(PREFIX)/usr/share/man/man1/nohang.1.gz
	gzip -c oom-sort.1 > $(DESTDIR)/$(PREFIX)/usr/share/man/man1/oom-sort.1.gz

	install -d $(DESTDIR)/$(PREFIX)/lib/systemd/system
	install -m0644 ./nohang.service $(DESTDIR)/$(PREFIX)/lib/systemd/system/nohang.service

uninstall:
	# 'make uninstall' must not fail with error if systemctl is unavailable or returns error
	systemctl disable nohang.service || true
	rm -fv $(PREFIX)/usr/sbin/nohang
	rm -fv $(PREFIX)/usr/sbin/nohang_notify_helper
	rm -fv $(PREFIX)/usr/bin/oom-sort
	rm -fv $(PREFIX)/usr/share/man/man1/nohang.1.gz
	rm -fv $(PREFIX)/usr/share/man/man1/oom-sort.1.gz
	rm -fv $(PREFIX)/lib/systemd/system/nohang.service
	rm -fvr $(PREFIX)/etc/nohang/
	rm -fvr $(PREFIX)/etc/logrotate.d/nohang
	rm -fvr $(PREFIX)/var/log/nohang/

systemd:
	systemctl daemon-reload
	systemctl enable nohang.service
	systemctl restart nohang
