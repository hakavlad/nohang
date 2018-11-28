#
PREFIX = /

all:
	@ echo "Nothing to compile. Use: make install, make uninstall, make systemd"

install:
	install -d $(DESTDIR)/$(PREFIX)/usr/sbin
	install -m0755 ./nohang $(DESTDIR)/$(PREFIX)/usr/sbin/nohang
	
	install -d $(DESTDIR)/$(PREFIX)/usr/sbin
	install -m0755 ./nohang_notify_low_mem $(DESTDIR)/$(PREFIX)/usr/sbin/nohang_notify_low_mem
	
	install -d $(DESTDIR)/$(PREFIX)/usr/bin
	install -m0755 ./oom-top $(DESTDIR)/$(PREFIX)/usr/bin/oom-top
	
	install -d $(DESTDIR)/$(PREFIX)/etc/nohang
	install -m0644 ./nohang.conf $(DESTDIR)/$(PREFIX)/etc/nohang
	install -m0644 ./nohang.conf.backup $(DESTDIR)/$(PREFIX)/etc/nohang
	
	install -d $(DESTDIR)/$(PREFIX)/usr/share/man/man1
	gzip -k -c nohang.1 > $(DESTDIR)/$(PREFIX)/usr/share/man/man1/nohang.1.gz
	
	install -d $(DESTDIR)/$(PREFIX)/lib/systemd/system
	install -m0644 ./nohang.service $(DESTDIR)/$(PREFIX)/lib/systemd/system/nohang.service
	
uninstall:
	# 'make uninstall' must not fail with error if systemctl is unavailable or returns error
	systemctl disable nohang.service || true
	rm -fv $(PREFIX)/usr/sbin/nohang
	rm -fv $(PREFIX)/usr/sbin/nohang_notify_low_mem
	rm -fv $(PREFIX)/usr/bin/oom-top
	rm -fv $(PREFIX)/usr/share/man/man1/nohang.1.gz
	rm -fv $(PREFIX)/lib/systemd/system/nohang.service
	rm -fvr $(PREFIX)/etc/nohang/
	
systemd:
	systemctl daemon-reload
	systemctl enable nohang.service
	systemctl restart nohang
