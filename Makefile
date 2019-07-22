DESTDIR ?=
BINDIR ?= /usr/local/bin
SYSTEMDUNITDIR ?= /etc/systemd/system
CONFDIR ?= /etc
MANDIR ?= /usr/share/man/man1
LOGDIR ?= /var/log

all:
	@ echo "Use: make install, make systemd, make uninstall"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m0755 ./nohang $(DESTDIR)$(BINDIR)/nohang
	install -m0755 ./nohang_notify_helper $(DESTDIR)$(BINDIR)/nohang_notify_helper
	install -m0755 ./oom-sort $(DESTDIR)$(BINDIR)/oom-sort
	install -m0755 ./psi-top $(DESTDIR)$(BINDIR)/psi-top
	install -m0755 ./psi-monitor $(DESTDIR)$(BINDIR)/psi-monitor

	install -d $(DESTDIR)$(CONFDIR)/nohang
	-git describe --tags --long --dirty > ./version
	-install -m0644 ./version $(DESTDIR)$(CONFDIR)/nohang/version
	-rm -fvr ./version

	install -m0644 ./nohang.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf
	install -m0644 ./nohang.conf $(DESTDIR)$(CONFDIR)/nohang/nohang.conf.default

	install -d $(DESTDIR)$(CONFDIR)/logrotate.d
	install -m0644 ./nohang.logrotate $(DESTDIR)$(CONFDIR)/logrotate.d/nohang

	install -d $(DESTDIR)$(MANDIR)
	gzip -c nohang.1 > $(DESTDIR)$(MANDIR)/nohang.1.gz
	gzip -c oom-sort.1 > $(DESTDIR)$(MANDIR)/oom-sort.1.gz

	-install -d $(DESTDIR)$(SYSTEMDUNITDIR)
	-install -m0644 ./nohang.service $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/nohang.service

uninstall:
	# 'make uninstall' must not fail with error if systemctl is unavailable or returns error
	-systemctl disable nohang.service || true
	rm -fv $(DESTDIR)$(BINDIR)/nohang
	rm -fv $(DESTDIR)$(BINDIR)/nohang_notify_helper
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
