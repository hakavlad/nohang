DESTDIR ?=
BINDIR ?= /usr/local/bin
CONFDIR ?= /etc
MANDIR ?= /usr/share/man/man1
LOGDIR ?= /var/log
SYSTEMDUNITDIR ?= /etc/systemd/system

all:
	@ echo "Use: make install, make systemd, make uninstall"

install:
	install -d $(DESTDIR)$(BINDIR)

	install -m0755 nohang $(DESTDIR)$(BINDIR)/nohang
	install -m0755 oom-sort $(DESTDIR)$(BINDIR)/oom-sort
	install -m0755 psi-top $(DESTDIR)$(BINDIR)/psi-top
	install -m0755 psi-monitor $(DESTDIR)$(BINDIR)/psi-monitor

	install -d $(DESTDIR)$(CONFDIR)/nohang
	-git describe --tags --long --dirty > version
	-install -m0644 version $(DESTDIR)$(CONFDIR)/nohang/version
	-rm -fv version

	install -m0644 nohang.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf
	install -m0644 nohang.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf.default
	install -m0644 nohang-desktop.conf $(DESTDIR)$(CONFDIR)/nohang/nohang-desktop.conf

	install -d $(DESTDIR)$(CONFDIR)/logrotate.d
	install -m0644 nohang.logrotate $(DESTDIR)$(CONFDIR)/logrotate.d/nohang

	install -d $(DESTDIR)$(MANDIR)
	gzip -c nohang.1 > $(DESTDIR)$(MANDIR)/nohang.1.gz
	gzip -c oom-sort.1 > $(DESTDIR)$(MANDIR)/oom-sort.1.gz

	-install -d $(DESTDIR)$(SYSTEMDUNITDIR)
	-sed "s|:TARGET_BIN:|$(BINDIR)|g;s|:TARGET_CONF:|$(CONFDIR)|g" nohang.service.in > nohang.service
	-install -m0644 nohang.service $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	-rm -fv nohang.service
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service

install-desktop:
	install -d $(DESTDIR)$(BINDIR)

	install -m0755 nohang $(DESTDIR)$(BINDIR)/nohang
	install -m0755 oom-sort $(DESTDIR)$(BINDIR)/oom-sort
	install -m0755 psi-top $(DESTDIR)$(BINDIR)/psi-top
	install -m0755 psi-monitor $(DESTDIR)$(BINDIR)/psi-monitor

	install -d $(DESTDIR)$(CONFDIR)/nohang
	-git describe --tags --long --dirty > version
	-install -m0644 version $(DESTDIR)$(CONFDIR)/nohang/version
	-rm -fv version

	install -m0644 nohang-desktop.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf
	install -m0644 nohang-desktop.conf $(DESTDIR)$(CONFDIR)/nohang/nohang-desktop.conf.default
	install -m0644 nohang.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf.default

	install -d $(DESTDIR)$(CONFDIR)/logrotate.d
	install -m0644 nohang.logrotate $(DESTDIR)$(CONFDIR)/logrotate.d/nohang

	install -d $(DESTDIR)$(MANDIR)
	gzip -c nohang.1 > $(DESTDIR)$(MANDIR)/nohang.1.gz
	gzip -c oom-sort.1 > $(DESTDIR)$(MANDIR)/oom-sort.1.gz

	-install -d $(DESTDIR)$(SYSTEMDUNITDIR)
	-sed "s|:TARGET_BIN:|$(BINDIR)|g;s|:TARGET_CONF:|$(CONFDIR)|g" nohang.service.in > nohang.service
	-install -m0644 nohang.service $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	-rm -fv nohang.service
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service

uninstall:
	# 'make uninstall' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop nohang.service || true
	-systemctl disable nohang.service || true
	-systemctl daemon-reload
	rm -fv $(DESTDIR)$(BINDIR)/nohang
	rm -fv $(DESTDIR)$(BINDIR)/oom-sort
	rm -fv $(DESTDIR)$(BINDIR)/psi-top
	rm -fv $(DESTDIR)$(BINDIR)/psi-monitor
	rm -fv $(DESTDIR)$(MANDIR)/nohang.1.gz
	rm -fv $(DESTDIR)$(MANDIR)/oom-sort.1.gz
	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	rm -fvr $(DESTDIR)$(CONFDIR)/nohang/
	rm -fvr $(DESTDIR)$(CONFDIR)/logrotate.d/nohang
	rm -fvr $(DESTDIR)$(LOGDIR)/nohang/

systemd:
	-systemctl daemon-reload
	-systemctl enable nohang.service
	-systemctl restart nohang
	-systemctl status nohang

pylint:
	-pylint3 -E nohang
	-pylint3 -E oom-sort
	-pylint3 -E psi-top
	-pylint3 -E psi-monitor
