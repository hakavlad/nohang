### Automated build version of dev branch

%define build_timestamp %{lua: print(os.date("%Y%m%d.%H"))}
%global appname nohang

Name:           %{appname}-dev
Version:        0.1
Release:        %{build_timestamp}%{?dist}
Summary:        Highly configurable OOM prevention daemon

License:        MIT
URL:            https://github.com/hakavlad/nohang
Source0:        %{url}/archive/dev/%{name}-%{build_timestamp}.tar.gz
BuildArch:      noarch

%if 0%{?el7}
BuildRequires:  systemd
%else
BuildRequires:  systemd-rpm-macros
%endif
Requires:       logrotate
%if 0%{?fedora} || 0%{?rhel} >= 8
Recommends:     %{name}-desktop
%endif
%{?systemd_requires}

%description
Nohang is a highly configurable daemon for Linux which is able to correctly
prevent out of memory (OOM) and keep system responsiveness in low
memory conditions.

To enable and start:

  systemctl enable --now %{appname}


%package        desktop
Summary:        Desktop version of %{name}
BuildArch:      noarch

Requires:       %{name} = %{version}-%{release}
Requires:       libnotify

%description    desktop
Desktop version of %{name}.


%prep
%autosetup -n %{appname}-dev


%build
%make_build


%install
%make_install BINDIR=%{_bindir} CONFDIR=%{_sysconfdir} SYSTEMDUNITDIR=%{_unitdir}
echo "v%{version}-%{build_timestamp}" > %{buildroot}%{_sysconfdir}/%{appname}/version


%post
%systemd_post %{appname}.service

%preun
%systemd_preun %{appname}.service

%postun
%systemd_postun_with_restart %{appname}.service

### Desktop
%post desktop
%systemd_post %{appname}-desktop.service

%preun desktop
%systemd_preun %{appname}-desktop.service

%postun desktop
%systemd_postun_with_restart %{appname}-desktop.service


%files
%license LICENSE
%doc README.md CHANGELOG.md
%{_bindir}/%{appname}
%{_bindir}/oom-sort
%{_bindir}/psi-top
%{_bindir}/psi2log
%{_mandir}/man1/*
%{_sysconfdir}/%{appname}/%{appname}.conf.default
%{_sysconfdir}/%{appname}/version
%{_sysconfdir}/logrotate.d/%{appname}
%{_unitdir}/%{appname}.service
%dir %{_sysconfdir}/%{appname}/
%config(noreplace) %{_sysconfdir}/%{appname}/%{appname}.conf

%files desktop
%{_sysconfdir}/%{appname}/%{appname}-desktop.conf.default
%{_unitdir}/%{appname}-desktop.service
%config(noreplace) %{_sysconfdir}/%{appname}/%{appname}-desktop.conf


%changelog
* Sun Nov 17 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-16.20191117gitaef8af6
- Update to latest git snapshot

* Mon Oct 14 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-15.20191005git2a3209c
- Update to latest git snapshot

* Thu Sep 19 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-14.20190919git286ed84
- Update to latest git snapshot

* Tue Sep 10 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-10.20190910gite442e41
- Update to latest git snapshot
- Add 'desktop' package

* Thu Sep 05 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-8.20190905git6db1833
- Update to latest git snapshot

* Sun Sep 01 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-7.20190901git4c1b5ee
- Update to latest git snapshot

* Sat Aug 31 2019 Artem Polishchuk <ego.cordatus@gmail.com> - 0.1-5.20190831gitf3baa58
- Initial package

