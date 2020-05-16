DESTDIR ?=
PREFIX ?=         /usr/local
SYSCONFDIR ?=     /usr/local/etc
SYSTEMDUNITDIR ?= /usr/local/lib/systemd/system

LOGDIR ?=           /var/log
LOGROTATECONFDIR ?= /etc/logrotate.d

BINDIR ?=  $(PREFIX)/bin
SBINDIR ?= $(PREFIX)/sbin
DATADIR ?= $(PREFIX)/share
DOCDIR ?=  $(DATADIR)/doc/nohang
MANDIR ?=  $(DATADIR)/man

all:
	@ echo "Use: make install, build_deb, make uninstall"

base:
	install -d $(DESTDIR)$(SBINDIR)
	install -m0755 nohang/nohang $(DESTDIR)$(SBINDIR)/nohang

	install -d $(DESTDIR)$(BINDIR)
	install -m0755 tools/oom-sort $(DESTDIR)$(BINDIR)/oom-sort
	install -m0755 tools/psi-top $(DESTDIR)$(BINDIR)/psi-top
	install -m0755 tools/psi2log $(DESTDIR)$(BINDIR)/psi2log

	install -d $(DESTDIR)$(SYSCONFDIR)/nohang

	sed "s|:TARGET_DATADIR:|$(DATADIR)|" nohang/nohang.conf.in > nohang.conf
	sed "s|:TARGET_DATADIR:|$(DATADIR)|" nohang/nohang-desktop.conf.in > nohang-desktop.conf

	install -m0644 nohang.conf $(DESTDIR)$(SYSCONFDIR)/nohang/nohang.conf
	install -m0644 nohang-desktop.conf $(DESTDIR)$(SYSCONFDIR)/nohang/nohang-desktop.conf

	install -d $(DESTDIR)$(DATADIR)/nohang

	install -m0644 nohang.conf $(DESTDIR)$(DATADIR)/nohang/nohang.conf
	install -m0644 nohang-desktop.conf $(DESTDIR)$(DATADIR)/nohang/nohang-desktop.conf

	-git describe --tags --long --dirty > version
	install -m0644 version $(DESTDIR)$(DATADIR)/nohang/version

	rm -fv nohang.conf
	rm -fv nohang-desktop.conf
	rm -fv version

	install -d $(DESTDIR)$(MANDIR)/man1
	gzip -c nohang/nohang.1 > $(DESTDIR)$(MANDIR)/man1/nohang.1.gz
	gzip -c tools/oom-sort.1 > $(DESTDIR)$(MANDIR)/man1/oom-sort.1.gz
	gzip -c tools/psi-top.1 > $(DESTDIR)$(MANDIR)/man1/psi-top.1.gz
	gzip -c tools/psi2log.1 > $(DESTDIR)$(MANDIR)/man1/psi2log.1.gz

	install -d $(DESTDIR)$(DOCDIR)
	install -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md
	install -m0644 CHANGELOG.md $(DESTDIR)$(DOCDIR)/CHANGELOG.md

	install -d $(DESTDIR)$(LOGROTATECONFDIR)
	install -m0644 nohang/nohang.logrotate $(DESTDIR)$(LOGROTATECONFDIR)/nohang

units:
	install -d $(DESTDIR)$(SYSTEMDUNITDIR)
	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" nohang/nohang.service.in > nohang.service
	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" nohang/nohang-desktop.service.in > nohang-desktop.service
	install -m0644 nohang.service $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	install -m0644 nohang-desktop.service $(DESTDIR)$(SYSTEMDUNITDIR)/nohang-desktop.service
	rm -fv nohang.service
	rm -fv nohang-desktop.service

chcon:
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/nohang-desktop.service

daemon-reload:
	-systemctl daemon-reload

build_deb: base units

install: base units chcon daemon-reload

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/nohang
	rm -fv $(DESTDIR)$(BINDIR)/oom-sort
	rm -fv $(DESTDIR)$(BINDIR)/psi-top
	rm -fv $(DESTDIR)$(BINDIR)/psi2log
	rm -fv $(DESTDIR)$(MANDIR)/man1/nohang.1.gz
	rm -fv $(DESTDIR)$(MANDIR)/man1/oom-sort.1.gz
	rm -fv $(DESTDIR)$(MANDIR)/man1/psi-top.1.gz
	rm -fv $(DESTDIR)$(MANDIR)/man1/psi2log.1.gz
	rm -fvr $(DESTDIR)$(LOGROTATECONFDIR)/nohang
	rm -fvr $(DESTDIR)$(DOCDIR)/
	rm -fvr $(DESTDIR)$(LOGDIR)/nohang/
	rm -fvr $(DESTDIR)$(DATADIR)/nohang/
	rm -fvr $(DESTDIR)$(SYSCONFDIR)/nohang/

uninstall-units:
	# 'make uninstall' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop nohang.service || true
	-systemctl stop nohang-desktop.service || true
	-systemctl disable nohang.service || true
	-systemctl disable nohang-desktop.service || true
	-rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	-rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/nohang-desktop.service

uninstall: uninstall-base uninstall-units daemon-reload
