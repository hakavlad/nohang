
# Nohang

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) and keep system responsiveness in low memory conditions.

## What is the problem?

OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop [caches](https://en.wikipedia.org/wiki/Page_cache) and processes to be killed (via sending [SIGKILL](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGKILL)) instead of trying to terminate them correctly (via sending [SIGTERM](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGTERM) or takes other corrective action). Some applications may crash if it's impossible to allocate memory.

![pic](https://i.imgur.com/9yuZOOf.png)

Here are the statements of some users:

> "How do I prevent Linux from freezing when out of memory?
Today I (accidentally) ran some program on my Linux box that quickly used a lot of memory. My system froze, became unresponsive and thus I was unable to kill the offender.
How can I prevent this in the future? Can't it at least keep a responsive core or something running?"

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory)

> "With or without swap it still freezes before the OOM killer gets run automatically. This is really a kernel bug that should be fixed (i.e. run OOM killer earlier, before dropping all disk cache). Unfortunately kernel developers and a lot of other folk fail to see the problem. Common suggestions such as disable/enable swap, buy more RAM, run less processes, set limits etc. do not address the underlying problem that the kernel's low memory handling sucks camel's balls."

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory#comment417508_390625)

Also look at [Why are low memory conditions handled so badly?](https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/)

## Solution

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple, stable and tiny OOM preventer written in C (the best choice for emedded and old servers). It has a minimum dependencies and can work with oldest kernels.
- Use of [oomd](https://github.com/facebookincubator/oomd). This is a userspace OOM killer for linux systems whitten in C++ and developed by Facebook. This is the best choice for use in large data centers. It needs Linux 4.20+.
- Use of `nohang` (maybe this is a good choice for modern desktops and servers if you need fine tuning).

The tools listed above may work at the same time on one computer.

#### See also

- `memlockd` is a daemon that locks files into memory. Then if a machine starts paging heavily the chance of being able to login successfully is significantly increased.

## Some features

- Sending the SIGTERM signal is default corrective action. If the victim does not respond to SIGTERM, with a further drop in the level of memory it gets SIGKILL.
- Impact on the badness of processes via matching their
    - names,
    - cgroups,
    - realpathes,
    - environs,
    - cmdlines and
    - euids
    with specified regular expressions
- If the name of the victim matches a certain regex pattern, you can run any command instead of sending the SIGTERM signal (the default corrective action) to the victim. For example:
    - `sysmemctl restart foo`
    - `kill -INT $PID` (you can override the signal sent to the victim, $PID will be replaced by the victim's PID)
    - `kill -TERM $PID && script.sh` (in addition to sending any signal, you can run a specified script)
- GUI notifications:
    - Notification of corrective actions taken and displaying the name and PID of the victim
    - Low memory warnings (displays available memory)
- [zram](https://www.kernel.org/doc/Documentation/blockdev/zram.txt) support (`mem_used_total` as a trigger)
- Initial [PSI](https://lwn.net/Articles/759658/) ([pressure stall information](https://facebookmicrosites.github.io/psi/)) support ([demo](https://youtu.be/2m2c9TGva1Y))
- Easy configuration with a ~~well~~ commented [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf)

## Requirements

For basic usage:
- `Linux` 3.14+ (since `MemAvailable` appeared in `/proc/meminfo`)
- `Python` 3.3+ (not tested with previous)

To show GUI notifications:
- [notification server](https://wiki.archlinux.org/index.php/Desktop_notifications#Notification_servers) (most of desktop environments use their own implementations)
- `libnotify` (Fedora, Arch Linux) or `libnotify-bin` (Debian GNU/Linux, Ubuntu)
- `sudo` if nohang started with UID=0

To use `PSI`:
- `Linux` 4.20+

## Memory and CPU usage

- VmRSS is about 10 - 12 MiB instead of the settings, about 10 MiB by default.
- CPU usage depends on the level of available memory and monitoring intensity.

## Download, install, uninstall

Please use the latest [release version](https://github.com/hakavlad/nohang/releases). Current version may be unstable.

To download the latest stable version (v0.1):
```bash
$ wget -ct0 https://github.com/hakavlad/nohang/archive/v0.1.tar.gz
$ tar xvzf v0.1.tar.gz
$ cd nohang-0.1
```

or to clone the latest unstable:
```bash
$ git clone https://github.com/hakavlad/nohang.git
$ cd nohang
```

To install:
```bash
$ sudo make install
```

To enable and start on systems with systemd:
```bash
$ sudo make systemd
```

To uninstall:
```bash
$ sudo make uninstall
```

For Arch Linux, there's an [AUR package](https://aur.archlinux.org/packages/nohang-git/). Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers). For example,

```bash
$ yay -S nohang-git
$ sudo systemctl start nohang
$ sudo systemctl enable nohang
```

## Command line options

```
./nohang -h
usage: nohang [-h] [-v] [-t] [--ppt] [-c CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         print version
  -t, --test            print some tests
  -p, --print-proc-table
                        print table of processes with their badness values
  -c CONFIG, --config CONFIG
                        path to the config file, default values:
                        ./nohang.conf, /etc/nohang/nohang.conf
```

## How to configure nohang

The program can be configured by editing the [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf). The configuration includes the following sections:

1. Memory levels to respond to as an OOM threat
2. Response on PSI memory metrics
3. The frequency of checking the level of available memory (and CPU usage)
4. The prevention of killing innocent victims
5. Impact on the badness of processes via matching their names, cgroups, realpaths, cmdlines and UIDs with certain regular expressions
6. The execution of a specific command or sending any signal instead of sending the SIGTERM signal
7. GUI notifications:
   - notifications of corrective actions taken
   - low memory warnings (or executing certain command instead)
8. Verbosity
9. Misc

Just read the description of the parameters and edit the values. Please restart nohang to apply the changes. Default path to the config after installing is `/etc/nohang/nohang.conf`.


## oom-sort

`oom-sort` is an additional diagnostic tool that will be installed with `nohang` package. It sorts the processes in descending order of their `oom_score` and also displays `oom_score_adj`, `Uid`, `Pid`, `Name`, `VmRSS`, `VmSwap` and optionally `cmdline`. Run `oom-sort --help` for more info.

Usage:

```
$ oom-sort
```

<details>
 <summary>Output like follow</summary>

```
oom_score oom_score_adj  UID   PID Name            VmRSS   VmSwap   cmdline
--------- ------------- ---- ----- --------------- ------- -------- -------
       23             0    0   964 Xorg               58 M     22 M /usr/libexec/Xorg -background none :0 vt01 -nolisten tcp -novtswitch -auth /var/run/lxdm/lxdm-:0.auth
       13             0 1000  1365 pcmanfm            38 M     10 M pcmanfm --desktop --profile LXDE
       10             0 1000  1408 dnfdragora-upda     9 M     27 M /usr/bin/python3 /bin/dnfdragora-updater
        5             0    0   822 firewalld           0 M     19 M /usr/bin/python3 /usr/sbin/firewalld --nofork --nopid
        5             0 1000  1364 lxpanel            18 M      2 M lxpanel --profile LXDE
        5             0 1000  1685 nm-applet           6 M     12 M nm-applet
        5             0 1000  1862 lxterminal         16 M      2 M lxterminal
        4             0  996   890 polkitd             8 M      6 M /usr/lib/polkit-1/polkitd --no-debug
        4             0 1000  1703 pnmixer             6 M     11 M pnmixer
        3             0    0   649 systemd-journal    10 M      1 M /usr/lib/systemd/systemd-journald
        3             0 1000  1360 openbox             9 M      2 M openbox --config-file /home/user/.config/openbox/lxde-rc.xml
        3             0 1000  1363 notification-da     3 M     10 M /usr/libexec/notification-daemon
        2             0 1000  1744 clipit              5 M      3 M clipit
        2             0 1000  2619 python3             9 M      0 M python3 /bin/oom-sort
        1             0    0   809 rsyslogd            3 M      3 M /usr/sbin/rsyslogd -n
        1             0    0   825 udisksd             2 M      2 M /usr/libexec/udisks2/udisksd
        1             0    0   873 sssd_nss            4 M      1 M /usr/libexec/sssd/sssd_nss --uid 0 --gid 0 --logger=files
        1             0    0   876 systemd-logind      2 M      2 M /usr/lib/systemd/systemd-logind
        1             0    0   907 abrt-dump-journ     2 M      1 M /usr/bin/abrt-dump-journal-oops -fxtD
        1             0    0   920 NetworkManager      3 M      2 M /usr/sbin/NetworkManager --no-daemon
        1             0 1000  1115 systemd             4 M      1 M /usr/lib/systemd/systemd --user
        1             0 1000  1118 (sd-pam)            0 M      5 M (sd-pam)
        1             0 1000  1366 xscreensaver        5 M      0 M xscreensaver -no-splash
        1             0 1000  1851 gvfsd-trash         3 M      1 M /usr/libexec/gvfsd-trash --spawner :1.6 /org/gtk/gvfs/exec_spaw/0
        1             0 1000  1969 gvfsd-metadata      6 M      0 M /usr/libexec/gvfsd-metadata
        1             0 1000  2262 bash                5 M      0 M bash
        0         -1000    0   675 systemd-udevd       0 M      4 M /usr/lib/systemd/systemd-udevd
        0         -1000    0   787 auditd              0 M      1 M /sbin/auditd
        0             0    0   807 ModemManager        0 M      1 M /usr/sbin/ModemManager
        0             0    0   808 smartd              0 M      1 M /usr/sbin/smartd -n -q never
        0             0    0   810 alsactl             0 M      0 M /usr/sbin/alsactl -s -n 19 -c -E ALSA_CONFIG_PATH=/etc/alsa/alsactl.conf --initfile=/lib/alsa/init/00main rdaemon
        0             0    0   811 mcelog              0 M      0 M /usr/sbin/mcelog --ignorenodev --daemon --foreground
        0             0  172   813 rtkit-daemon        0 M      0 M /usr/libexec/rtkit-daemon
        0             0    0   814 VBoxService         0 M      1 M /usr/sbin/VBoxService -f
        0             0    0   817 rngd                0 M      1 M /sbin/rngd -f
        0          -900   81   818 dbus-daemon         3 M      0 M /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
        0             0    0   823 irqbalance          0 M      0 M /usr/sbin/irqbalance --foreground
        0             0   70   824 avahi-daemon        0 M      0 M avahi-daemon: running [linux.local]
        0             0    0   826 sssd                0 M      2 M /usr/sbin/sssd -i --logger=files
        0             0  995   838 chronyd             1 M      0 M /usr/sbin/chronyd
        0             0    0   849 gssproxy            0 M      1 M /usr/sbin/gssproxy -D
        0             0    0   866 abrtd               0 M      2 M /usr/sbin/abrtd -d -s
        0             0   70   870 avahi-daemon        0 M      0 M avahi-daemon: chroot helper
        0             0    0   871 sssd_be             0 M      2 M /usr/libexec/sssd/sssd_be --domain implicit_files --uid 0 --gid 0 --logger=files
        0             0    0   875 accounts-daemon     0 M      1 M /usr/libexec/accounts-daemon
        0             0    0   906 abrt-dump-journ     1 M      2 M /usr/bin/abrt-dump-journal-core -D -T -f -e
        0             0    0   908 abrt-dump-journ     1 M      2 M /usr/bin/abrt-dump-journal-xorg -fxtD
        0             0    0   950 crond               2 M      1 M /usr/sbin/crond -n
        0             0    0   951 atd                 0 M      0 M /usr/sbin/atd -f
        0             0    0   953 lxdm-binary         0 M      0 M /usr/sbin/lxdm-binary
        0             0    0  1060 dhclient            0 M      2 M /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhclient-enp0s3.pid -lf /var/lib/NetworkManager/dhclient-939eab05-4796-3792-af24-9f76cf53ca7f-enp0s3.lease -cf /var/lib/NetworkManager/dhclient-enp0s3.conf enp0s3
        0             0    0  1105 lxdm-session        0 M      1 M /usr/libexec/lxdm-session
        0             0 1000  1123 pulseaudio          0 M      3 M /usr/bin/pulseaudio --daemonize=no
        0             0 1000  1124 lxsession           1 M      2 M /usr/bin/lxsession -s LXDE -e LXDE
        0             0 1000  1134 dbus-daemon         2 M      0 M /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
        0             0 1000  1215 imsettings-daem     0 M      1 M /usr/libexec/imsettings-daemon
        0             0 1000  1218 gvfsd               3 M      1 M /usr/libexec/gvfsd
        0             0 1000  1223 gvfsd-fuse          0 M      1 M /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f -o big_writes
        0             0 1000  1309 VBoxClient          0 M      0 M /usr/bin/VBoxClient --display
        0             0 1000  1310 VBoxClient          0 M      0 M /usr/bin/VBoxClient --clipboard
        0             0 1000  1311 VBoxClient          0 M      0 M /usr/bin/VBoxClient --draganddrop
        0             0 1000  1312 VBoxClient          0 M      0 M /usr/bin/VBoxClient --display
        0             0 1000  1313 VBoxClient          1 M      0 M /usr/bin/VBoxClient --clipboard
        0             0 1000  1316 VBoxClient          0 M      0 M /usr/bin/VBoxClient --seamless
        0             0 1000  1318 VBoxClient          0 M      0 M /usr/bin/VBoxClient --seamless
        0             0 1000  1320 VBoxClient          0 M      0 M /usr/bin/VBoxClient --draganddrop
        0             0 1000  1334 ssh-agent           0 M      0 M /usr/bin/ssh-agent /bin/sh -c exec -l bash -c "/usr/bin/startlxde"
        0             0 1000  1362 lxpolkit            0 M      1 M lxpolkit
        0             0 1000  1370 lxclipboard         0 M      1 M lxclipboard
        0             0 1000  1373 ssh-agent           0 M      1 M /usr/bin/ssh-agent -s
        0             0 1000  1485 agent               0 M      1 M /usr/libexec/geoclue-2.0/demos/agent
        0             0 1000  1751 menu-cached         0 M      1 M /usr/libexec/menu-cache/menu-cached /run/user/1000/menu-cached-:0
        0             0 1000  1780 at-spi-bus-laun     0 M      1 M /usr/libexec/at-spi-bus-launcher
        0             0 1000  1786 dbus-daemon         1 M      0 M /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 3
        0             0 1000  1792 at-spi2-registr     1 M      1 M /usr/libexec/at-spi2-registryd --use-gnome-session
        0             0 1000  1840 gvfs-udisks2-vo     0 M      2 M /usr/libexec/gvfs-udisks2-volume-monitor
        0             0 1000  1863 gnome-pty-helpe     1 M      0 M gnome-pty-helper
        0             0 1000  1864 bash                0 M      1 M bash
        0             0    0  1899 sudo                0 M      1 M sudo -i
        0             0    0  1901 bash                0 M      1 M -bash
        0             0    0  1953 oomd_bin            0 M      0 M oomd_bin -f /sys/fs/cgroup/unified
        0          -600    0  2562 python3            10 M      0 M python3 /usr/sbin/nohang --config /etc/nohang/nohang.conf
```
</details>

Kthreads, zombies and Pid 1 will not be displayed.

## Logging

To view the latest entries in the log (for systemd users):

```bash
$ sudo journalctl -eu nohang
```
See also `man journalctl`.

You can also enable `separate_log` in the config to logging in `/var/log/nohang/nohang.log`.

## Known issues

- Awful documentation
- Non-optimal default settings (I do not know which settings are optimal for most users; you need a configuration for better experience)
- No installation option for non-systemd users
- No deb/rpm packages

## Contribution

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.

## Changelog

- In progress
    - [x] Added new CLI options:
        - [x] -v, --version
        - [x] -t, --test
        - [x] -p, --print-proc-table
    - [x] Possible process crashes are fixed:
        - [x] Fixed crash at startup due to `UnicodeDecodeError` on some systems
        - [x] Handled  `UnicodeDecodeError` if victim name consists of many unicode characters ([rfjakob/earlyoom#110](https://github.com/rfjakob/earlyoom/issues/110))
        - [x] Fixed process crash before performing corrective actions if Python 3.4 or lower are used to interpret nohang
    - [x] Improve output:
        - [x] Display `oom_score`, `oom_score_adj`, `Ancestry`, `EUID`, `State`, `VmSize`, `RssAnon`, `RssFile`, `RssShmem`, `CGroup`, `Realpath`, `Cmdline` and `Lifetime` of the victim in corrective action reports
        - [x] Added memory report interval
        - [x] Added delta memory info (the rate of change of available memory)
        - [x] Print statistics on corrective actions after each corrective action
        - [x] Added ability to print a process table before each corrective action
        - [x] Added the ability to log into a separate file
    - [x] Improved GUI warnings:
        - [x] Reduced the idle time of the daemon in the process of launching a notification
        - [x] All notify-send calls are made using the `nohang_notify_helper` script, in which all timeouts are handled
        - [x] Native python implementation of `env` search without running `ps` to notify all users if nohang started with UID=0.
        - [x] Messages are sent to the helper via a temporary file in `/dev/shm`
        - [x] Deduplication of frequently repeated identical notifications (for example, if the victim does not respond to SIGTERM)
    - [x] Improved modifing badness via matching with regular expressions:
        - [x] Added the ability to set many different `badness_adj` for processes depending on the matching `Name`, `CGroup`, `cmdline`, `realpath` and `EUID` with the specified regular expressions ([issue #74](https://github.com/hakavlad/nohang/issues/11))
        - [x] Fix: replace `re.fullmatch()` by `re.search()`
    - [x] Reduced memory usage:
        - [x] Reduced memory usage and startup time (using `sys.argv` instead of `argparse`)
        - [x] Reduced memory usage with `mlockall()` using `MCL_ONFAULT` ([rfjakob/earlyoom#112](https://github.com/rfjakob/earlyoom/issues/112)) and lock all memory by default
    - [x] Improve poll rate algorithm
    - [x] Fixed Makefile for installation on CentOS 7 (remove gzip `-k` option).
    - [x] Added `max_post_sigterm_victim_lifetime` option: send SIGKILL to the victim if it doesn't respond to SIGTERM for a certain time
    - [x] Added `post_kill_exe` option (the ability to run any command after killing the victim)
    - [x] Added `warning_exe` option (the ability to run any command instead of GUI low memory warnings)
    - [x] Improved victim search algorithm (do it ~30% faster) ([rfjakob/earlyoom#114](https://github.com/rfjakob/earlyoom/issues/114))
    - [x] Improved limiting `oom_score_adj`: now it can works with UID != 0
    - [x] Fixed conf parsing: use of `line.partition('=')` instead of `line.split('=')`
    - [x] Added `oom-sort`
    - [x] Removed self-defense options from the config, use systemd unit scheduling instead
    - [x] Added the ability to send any signal instead of SIGTERM for processes with certain names
    - [x] Added initial support for `PSI`
    - [x] Improved user input validation
    - [x] Improved documentation

- [v0.1](https://github.com/hakavlad/nohang/releases/tag/v0.1), 2018-11-23: Initial release
