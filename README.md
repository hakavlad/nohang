![pic](https://i.imgur.com/iWRrV5f.png)

# nohang

[![Build Status](https://travis-ci.org/hakavlad/nohang.svg?branch=master)](https://travis-ci.org/hakavlad/nohang)
[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/nohang.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/nohang/alerts/)

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) and keep system responsiveness in low memory conditions.

## What is the problem?

OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop [caches](https://en.wikipedia.org/wiki/Page_cache) and processes to be killed (via sending [SIGKILL](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGKILL)) instead of trying to terminate them correctly (via sending [SIGTERM](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGTERM) or takes other corrective action). Some applications may crash if it's impossible to allocate memory.

Here are the statements of some users:

> "How do I prevent Linux from freezing when out of memory?
Today I (accidentally) ran some program on my Linux box that quickly used a lot of memory. My system froze, became unresponsive and thus I was unable to kill the offender.
How can I prevent this in the future? Can't it at least keep a responsive core or something running?"

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory)

> "With or without swap it still freezes before the OOM killer gets run automatically. This is really a kernel bug that should be fixed (i.e. run OOM killer earlier, before dropping all disk cache). Unfortunately kernel developers and a lot of other folk fail to see the problem. Common suggestions such as disable/enable swap, buy more RAM, run less processes, set limits etc. do not address the underlying problem that the kernel's low memory handling sucks camel's balls."

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory#comment417508_390625)

> "The traditional Linux OOM killer works fine in some cases, but in others it kicks in too late, resulting in the system entering a [livelock](https://en.wikipedia.org/wiki/Deadlock#Livelock) for an indeterminate period."

— [engineering.fb.com](https://engineering.fb.com/production-engineering/oomd/)

Also look at this discussions:
- Why are low memory conditions handled so badly? [[r/linux](https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/)]
- Memory management "more effective" on Windows than Linux? (in preventing total system lockup) [[r/linux](https://www.reddit.com/r/linux/comments/aqd9mh/memory_management_more_effective_on_windows_than/)]
- Let's talk about the elephant in the room - the Linux kernel's inability to gracefully handle low memory pressure [[original LKML post](https://lkml.org/lkml/2019/8/4/15) | [r/linux](https://www.reddit.com/r/linux/comments/cmg48b/lets_talk_about_the_elephant_in_the_room_the/) | [Hacker News](https://news.ycombinator.com/item?id=20620545) | [slashdot](https://linux.slashdot.org/story/19/08/06/1839206/linux-performs-poorly-in-low-ram--memory-pressure-situations-on-the-desktop) | [phoronix](https://www.phoronix.com/forums/forum/phoronix/general-discussion/1118164-yes-linux-does-bad-in-low-ram-memory-pressure-situations-on-the-desktop) | [opennet.ru](https://www.opennet.ru/opennews/art.shtml?num=51231) | [linux.org.ru](https://www.linux.org.ru/forum/talks/15151526)]

## Solution

Use one of the userspace OOM killers.
- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple, stable and tiny OOM preventer written in C (the best choice for emedded and old servers). It has a minimum dependencies and can work with oldest kernels.
- Use of [oomd](https://github.com/facebookincubator/oomd). This is a userspace OOM killer for linux systems written in C++ and developed by Facebook. This is the best choice for use in large data centers. It needs Linux 4.20+.
- Use of [low-memory-monitor](https://gitlab.freedesktop.org/hadess/low-memory-monitor/). There's a [project announcement](http://www.hadess.net/2019/08/low-memory-monitor-new-project.html).
- Use of `nohang`: nohang is earlyoom on steroids and has many useful features, see below. Maybe this is a good choice for modern desktops and servers if you need fine-tuning.

Of course, you can also [download more RAM](https://downloadmoreram.com/), tune [virtual memory](https://www.kernel.org/doc/Documentation/sysctl/vm.txt), use [zram](https://www.kernel.org/doc/Documentation/blockdev/zram.txt)/[zswap](https://www.kernel.org/doc/Documentation/vm/zswap.txt) and use [limits](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html) for cgroups.

## Some features

- Sending the SIGTERM signal is default corrective action. If the victim does not respond to SIGTERM, with a further drop in the level of memory it gets SIGKILL;
- Customizing victim selection: impact on the badness of processes via matching their names, cgroups, exe realpathes, environs, cmdlines and euids with specified regular expressions;
- Customizing corrective actions: if the name or control group of the victim matches a certain regex pattern, you can run any command instead of sending the SIGTERM signal (the default corrective action) to the victim. For example:
    - `sysmemctl restart foo`;
    - `kill -INT $PID` (you can override the signal sent to the victim, $PID will be replaced by the victim's PID);
    - `kill -TERM $PID && script.sh` (in addition to sending any signal, you can run a specified script).
- GUI notifications:
    - Notification of corrective actions taken and displaying the name and PID of the victim;
    - Low memory warnings (displays available memory).
- [zram](https://www.kernel.org/doc/Documentation/blockdev/zram.txt) support (`mem_used_total` as a trigger);
- [PSI](https://lwn.net/Articles/759658/) ([pressure stall information](https://facebookmicrosites.github.io/psi/)) support;
- Easy configuration with a commented [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf).

## Demo

- Old demo: `nohang` prevents Out Of Memory with GUI notifications: [https://youtu.be/ChTNu9m7uMU](https://youtu.be/ChTNu9m7uMU).
- New demo: `nohang` prevents Out Of Memory with GUI notifications: [https://youtu.be/UCwZS5uNLu0](https://youtu.be/UCwZS5uNLu0).

## Requirements

For basic usage:
- `Linux` >= 3.14 (since `MemAvailable` appeared in `/proc/meminfo`)
- `Python` >= 3.3

To show GUI notifications:
- [notification server](https://wiki.archlinux.org/index.php/Desktop_notifications#Notification_servers) (most of desktop environments use their own implementations)
- `libnotify` (Fedora, Arch Linux) or `libnotify-bin` (Debian GNU/Linux, Ubuntu)
- `sudo` if nohang started with UID=0

To use `PSI`:
- `Linux` >= 4.20 with `CONFIG_PSI=y`.

## Memory and CPU usage

- VmRSS is about 10 - 12 MiB instead of the settings, about 10 MiB by default.
- CPU usage depends on the level of available memory and monitoring intensity.

## How to install

For RPM-based Linux distributions (Fedora, RHEL, openSUSE) there's a [Copr package](https://copr.fedorainfracloud.org/coprs/atim/nohang/).

To install on Fedora 30+:
```bash
$ sudo dnf copr enable atim/nohang
$ sudo dnf install nohang
$ sudo systemctl enable --now nohang
```

To install on CentOS 7:
```bash
$ sudo yum install yum-plugin-copr
$ sudo yum copr enable atim/nohang
$ sudo yum install nohang
$ sudo systemctl enable nohang
$ sudo systemctl start nohang
```

For Arch Linux there's an [AUR package](https://aur.archlinux.org/packages/nohang-git/). Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers). For example,
```bash
$ yay -S nohang-git
$ sudo systemctl enable --now nohang
```

To install on Debian and Ubuntu please make a deb package.

To install the latest version on any distro:
```bash
$ git clone https://github.com/hakavlad/nohang.git
$ cd nohang
$ sudo make install  # `sudo make install-desktop` to enable GUI notifications by default
```

To enable and start on systems with systemd:
```bash
$ sudo make systemd
```

To enable and start on systems without systemd please make a PR to fix Makefile.

To uninstall:
```bash
$ sudo make uninstall
```

## Command line options

```
./nohang -h
usage: nohang [-h] [-v] [-p] [-c CONFIG] [-cc CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         print version
  -p, --print-proc-table
                        print table of processes with their badness values
  -c CONFIG, --config CONFIG
                        path to the config file, default values:
                        ./nohang.conf, /etc/nohang/nohang.conf
  -cc CONFIG, --check-config CONFIG
                        check and print config
```

## How to configure

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

## Print table of processes with their badness values

Run `sudo nohang -p` to see the table of prosesses with their badness values, oom_scores, names, UIDs etc.

<details>
 <summary>Output example</summary>

```
Config: /etc/nohang/nohang.conf
###################################################################################################################
#    PID     PPID  badness  oom_score  oom_score_adj        eUID  S  VmSize  VmRSS  VmSwap  Name             CGroup
#-------  -------  -------  ---------  -------------  ----------  -  ------  -----  ------  ---------------  --------
#    336        1        1          1              0           0  S      85     25       0  systemd-journal  /system.slice/systemd-journald.service
#    383        1        0          0          -1000           0  S      46      5       0  systemd-udevd    /system.slice/systemd-udevd.service
#    526     2238        7          7              0        1000  S     840     96       0  kate             /user.slice/user-1000.slice/session-7.scope
#    650        1        3          3              0        1000  S     760     50       0  kate             /user.slice/user-1000.slice/session-7.scope
#    731        1        0          0              0         100  S     126      4       0  systemd-timesyn  /system.slice/systemd-timesyncd.service
#    756        1        0          0              0         105  S     181      3       0  rtkit-daemon     /system.slice/rtkit-daemon.service
#    759        1        0          0              0           0  S     277      7       0  accounts-daemon  /system.slice/accounts-daemon.service
#    761        1        0          0              0           0  S     244      3       0  rsyslogd         /system.slice/rsyslog.service
#    764        1        0          0           -900         108  S      45      5       0  dbus-daemon      /system.slice/dbus.service
#    805        1        0          0              0           0  S      46      5       0  systemd-logind   /system.slice/systemd-logind.service
#    806        1        0          0              0           0  S      35      3       0  irqbalance       /system.slice/irqbalance.service
#    813        1        0          0              0           0  S      29      3       0  cron             /system.slice/cron.service
#    814        1       11         11              0           0  S     176    160       0  memlockd         /system.slice/memlockd.service
#    815        1        0          0            -10           0  S      32      9       0  python3          /fork.slice/fork-bomb.slice/fork-bomb-killer.slice/fork-bomb-killer.service
#    823        1        0          0              0           0  S      25      4       0  smartd           /system.slice/smartd.service
#    826        1        0          0              0         113  S      46      3       0  avahi-daemon     /system.slice/avahi-daemon.service
#    850      826        0          0              0         113  S      46      0       0  avahi-daemon     /system.slice/avahi-daemon.service
#    868        1        0          0              0           0  S     281      8       0  polkitd          /system.slice/polkit.service
#    903        1        1          1              0           0  S    4094     16       0  stunnel4         /system.slice/stunnel4.service
#    940        1        0          0           -600           0  S      39     10       0  python3          /nohang.slice/nohang.service
#   1014        1        0          0              0          13  S      22      2       0  obfs-local       /system.slice/obfs-local.service
#   1015        1        0          0              0        1000  S      36      4       0  ss-local         /system.slice/ss-local.service
#   1023        1        0          0              0         116  S      33      2       0  dnscrypt-proxy   /system.slice/dnscrypt-proxy.service
#   1029        1        1          1              0         119  S    4236     16       0  privoxy          /system.slice/privoxy.service
#   1035        1        0          0              0           0  S     355      6       0  lightdm          /system.slice/lightdm.service
#   1066        1        0          0              0           0  S      45      7       0  wpa_supplicant   /system.slice/wpa_supplicant.service
#   1178        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty1.service
#   1294        1        0          0          -1000           0  S       4      1       0  watchdog         /system.slice/watchdog.service
#   1632        1        1          1              0        1000  S    1391     22       0  pulseaudio       /user.slice/user-1000.slice/session-2.scope
#   1689     1632        0          0              0        1000  S     125      5       0  gconf-helper     /user.slice/user-1000.slice/session-2.scope
#   1711        1        0          0              0           0  S     367      8       0  udisksd          /system.slice/udisks2.service
#   1819        1        0          0              0           0  S     304      8       0  upowerd          /system.slice/upower.service
#   1879        1        0          0              0        1000  S      64      7       0  systemd          /user.slice/user-1000.slice/user@1000.service/init.scope
#   1880     1879        0          0              0        1000  S     229      2       0  (sd-pam)         /user.slice/user-1000.slice/user@1000.service/init.scope
#   1888        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty2.service
#   1889        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty3.service
#   1890        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty4.service
#   1891        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty5.service
#   1892        1        0          0              0           0  S      14      2       0  agetty           /system.slice/system-getty.slice/getty@tty6.service
#   1893     1035       14         14              0           0  R     623    208       0  Xorg             /system.slice/lightdm.service
#   1904        1        0          0              0         111  S      64      7       0  systemd          /user.slice/user-111.slice/user@111.service/init.scope
#   1905     1904        0          0              0         111  S     229      2       0  (sd-pam)         /user.slice/user-111.slice/user@111.service/init.scope
#   1916     1904        0          0              0         111  S      44      3       0  dbus-daemon      /user.slice/user-111.slice/user@111.service/dbus.service
#   1920        1        0          0              0         111  S     215      5       0  at-spi2-registr  /user.slice/user-111.slice/session-c2.scope
#   1922     1904        0          0              0         111  S     278      6       0  gvfsd            /user.slice/user-111.slice/user@111.service/gvfs-daemon.service
#   1935     1035        0          0              0           0  S     238      6       0  lightdm          /user.slice/user-1000.slice/session-7.scope
#   1942        1        0          0              0        1000  S     210      9       0  gnome-keyring-d  /user.slice/user-1000.slice/session-7.scope
#   1944     1935        1          1              0        1000  S     411     21       0  mate-session     /user.slice/user-1000.slice/session-7.scope
#   1952     1879        0          0              0        1000  S      45      5       0  dbus-daemon      /user.slice/user-1000.slice/user@1000.service/dbus.service
#   1981     1944        0          0              0        1000  S      11      0       0  ssh-agent        /user.slice/user-1000.slice/session-7.scope
#   1984     1879        0          0              0        1000  S     278      6       0  gvfsd            /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#   1990     1879        0          0              0        1000  S     341      5       0  at-spi-bus-laun  /user.slice/user-1000.slice/user@1000.service/at-spi-dbus-bus.service
#   1995     1990        0          0              0        1000  S      44      4       0  dbus-daemon      /user.slice/user-1000.slice/user@1000.service/at-spi-dbus-bus.service
#   1997     1879        0          0              0        1000  S     215      5       0  at-spi2-registr  /user.slice/user-1000.slice/user@1000.service/at-spi-dbus-bus.service
#   2000     1879        0          0              0        1000  S     184      5       0  dconf-service    /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2009     1944        2          2              0        1000  S    1308     35       0  mate-settings-d  /user.slice/user-1000.slice/session-7.scope
#   2013     1944        2          2              0        1000  S     436     32       0  marco            /user.slice/user-1000.slice/session-7.scope
#   2024     1944        4          4              0        1000  S    1258     55       0  caja             /user.slice/user-1000.slice/session-7.scope
#   2032        1        1          1              0        1000  S     333     18       0  msd-locate-poin  /user.slice/user-1000.slice/session-7.scope
#   2033     1879        0          0              0        1000  S     348     11       0  gvfs-udisks2-vo  /user.slice/user-1000.slice/user@1000.service/gvfs-udisks2-volume-monitor.service
#   2036     1944        1          1              0        1000  S     331     17       0  polkit-mate-aut  /user.slice/user-1000.slice/session-7.scope
#   2038     1944        5          5              0        1000  S     682     78       0  mate-panel       /user.slice/user-1000.slice/session-7.scope
#   2041     1944        2          2              0        1000  S     514     31       0  nm-applet        /user.slice/user-1000.slice/session-7.scope
#   2046     1944        1          1              0        1000  S     495     25       0  mate-power-mana  /user.slice/user-1000.slice/session-7.scope
#   2047     1944        2          2              0        1000  S     692     32       0  mate-volume-con  /user.slice/user-1000.slice/session-7.scope
#   2049     1944        3          3              0        1000  S     548     44       0  mate-screensave  /user.slice/user-1000.slice/session-7.scope
#   2059     1879        0          0              0        1000  S     263      5       0  gvfs-goa-volume  /user.slice/user-1000.slice/user@1000.service/gvfs-goa-volume-monitor.service
#   2076     1879        0          0              0        1000  S     352      7       0  gvfsd-trash      /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#   2077     1879        0          0              0        1000  S     362      7       0  gvfs-afc-volume  /user.slice/user-1000.slice/user@1000.service/gvfs-afc-volume-monitor.service
#   2087     1879        0          0              0        1000  S     263      5       0  gvfs-mtp-volume  /user.slice/user-1000.slice/user@1000.service/gvfs-mtp-volume-monitor.service
#   2093     1879        0          0              0        1000  S     275      6       0  gvfs-gphoto2-vo  /user.slice/user-1000.slice/user@1000.service/gvfs-gphoto2-volume-monitor.service
#   2106     1879        3          3              0        1000  S     544     42       0  wnck-applet      /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2108     1879        1          1              0        1000  S     396     21       0  notification-ar  /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2112     1879        1          1              0        1000  S     499     25       0  mate-sensors-ap  /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2113     1879        1          1              0        1000  S     390     21       0  mate-brightness  /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2114     1879        1          1              0        1000  S     534     22       0  mate-multiload-  /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2118     1879        2          2              0        1000  S     547     29       0  clock-applet     /user.slice/user-1000.slice/user@1000.service/dbus.service
#   2152     1879        1          1              0        1000  S     218     22       0  gvfsd-metadata   /user.slice/user-1000.slice/user@1000.service/gvfs-metadata.service
#   2206        1        3          3              0         110  S     106     48       0  tor              /system.slice/system-tor.slice/tor@default.service
#   2229        1        3          3              0        1000  S     999     42       0  kactivitymanage  /user.slice/user-1000.slice/session-7.scope
#   2238        1        0          0              0        1000  S     150      9       0  kdeinit5         /user.slice/user-1000.slice/session-7.scope
#   2239     2238        3          3              0        1000  S     648     41       0  klauncher        /user.slice/user-1000.slice/session-7.scope
#   3959        1        1          1              0           0  S     615     18       0  NetworkManager   /system.slice/NetworkManager.service
#   3977     3959        0          0              0           0  S      20      4       0  dhclient         /system.slice/NetworkManager.service
#   5626     1879        0          0              0        1000  S     355      7       0  gvfsd-network    /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#   5637     1879        1          1              0        1000  S     623     14       0  gvfsd-smb-brows  /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#   6296     1879        0          0              0        1000  S     435      7       0  gvfsd-dnssd      /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#  11129     1879        3          3              0        1000  S     597     42       0  kded5            /user.slice/user-1000.slice/user@1000.service/dbus.service
#  11136     1879        2          2              0        1000  S     639     39       0  kuiserver5       /user.slice/user-1000.slice/user@1000.service/dbus.service
#  11703     1879        3          3              0        1000  S     500     45       0  mate-system-mon  /user.slice/user-1000.slice/user@1000.service/dbus.service
#  16798     1879        0          0              0        1000  S     346     10       0  gvfsd-http       /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
#  18133        1        3          3              0        1000  S     760     49       0  kate             /user.slice/user-1000.slice/session-7.scope
#  18144     2038        1          1              0        1000  S     301     23       0  lxterminal       /user.slice/user-1000.slice/session-7.scope
#  18147    18144        0          0              0        1000  S      14      2       0  gnome-pty-helpe  /user.slice/user-1000.slice/session-7.scope
#  18148    18144        1          1              0        1000  S      42     26       0  bash             /user.slice/user-1000.slice/session-7.scope
#  18242     2238        1          1              0        1000  S     194     14       0  file.so          /user.slice/user-1000.slice/session-7.scope
#  18246    18148        0          0              0           0  S      54      4       0  sudo             /user.slice/user-1000.slice/session-7.scope
#  19003        1        0          0              0           0  S     310     12       0  packagekitd      /system.slice/packagekit.service
#  26993     2038       91         91              0        1000  S    3935   1256       0  firefox-esr      /user.slice/user-1000.slice/session-7.scope
#  27275    26993      121        121              0        1000  S    3957   1684       0  Web Content      /user.slice/user-1000.slice/session-7.scope
#  30374        1        1          1              0        1000  S     167     14       0  VBoxXPCOMIPCD    /user.slice/user-1000.slice/session-7.scope
#  30380        1        2          2              0        1000  S     958     27       0  VBoxSVC          /user.slice/user-1000.slice/session-7.scope
#  30549    30380       86         86              0        1000  S    5332   1192       0  VirtualBox       /user.slice/user-1000.slice/session-7.scope
#  30875        1        1          1              0        1000  S     345     26       0  leafpad          /user.slice/user-1000.slice/session-7.scope
#  32689        1        7          7              0        1000  S     896     99       0  dolphin          /user.slice/user-1000.slice/session-7.scope
###################################################################################################################
Process with highest badness (found in 55 ms):
  PID: 27275, Name: Web Content, badness: 121
```
</details>


## Logging

To view the latest entries in the log (for systemd users):
```bash
$ sudo journalctl -eu nohang
```

You can also enable `separate_log` in the config to logging in `/var/log/nohang/nohang.log`.

## Additional tools: oom-sort, psi-top, psi-monitor


### oom-sort

`oom-sort` is an additional diagnostic tool that will be installed with `nohang` package. It sorts the processes in descending order of their `oom_score` and also displays `oom_score_adj`, `Uid`, `Pid`, `Name`, `VmRSS`, `VmSwap` and optionally `cmdline`. Run `oom-sort --help` for more info.

Usage:

```
$ oom-sort
```

<details>
 <summary>Output example</summary>

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

### psi-top

It needs `Linux` >= 4.20 with `CONFIG_PSI=y`.

<details>
 <summary>Output example</summary>

```
$ psi-top
cgroup2 root dir: /sys/fs/cgroup/unified
      avg10  avg60 avg300         avg10  avg60 avg300  cgroup2
      -----  ----- ------         -----  ----- ------  ---------
some  46.72  31.48  22.60 | full  45.67  30.53  21.55  [SYSTEM]
some  44.29  28.54  20.08 | full  43.42  27.88  19.43  /user.slice
some  45.92  28.77  20.19 | full  45.05  28.17  19.56  /user.slice/user-1000.slice
some   1.44   4.67   9.24 | full   1.44   4.65   9.20  /user.slice/user-1000.slice/user@1000.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/pulseaudio.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-daemon.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/dbus.socket
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-udisks2-volume-monitor.service
some   0.25   1.97   4.05 | full   0.25   1.96   4.03  /user.slice/user-1000.slice/user@1000.service/xfce4-notifyd.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/init.scope
some   0.00   0.66   1.99 | full   0.00   0.66   1.97  /user.slice/user-1000.slice/user@1000.service/gpg-agent.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-gphoto2-volume-monitor.service
some   0.93   0.75   0.20 | full   0.93   0.75   0.20  /user.slice/user-1000.slice/user@1000.service/at-spi-dbus-bus.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-metadata.service
some   0.00   2.44   6.78 | full   0.00   2.43   6.74  /user.slice/user-1000.slice/user@1000.service/dbus.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-mtp-volume-monitor.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /user.slice/user-1000.slice/user@1000.service/gvfs-afc-volume-monitor.service
some  44.99  28.30  19.41 | full  44.10  27.70  18.79  /user.slice/user-1000.slice/session-2.scope
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /nohang.slice
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /nohang.slice/nohang.service
some   0.00   0.31   0.53 | full   0.00   0.31   0.53  /init.scope
some   7.25  11.40  13.34 | full   7.23  11.32  13.24  /system.slice
some   0.00   0.01   0.02 | full   0.00   0.01   0.02  /system.slice/systemd-udevd.service
some   0.00   0.58   1.55 | full   0.00   0.58   1.55  /system.slice/cronie.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/sys-kernel-config.mount
some   0.00   0.22   0.35 | full   0.00   0.22   0.35  /system.slice/polkit.service
some   0.00   0.06   0.20 | full   0.00   0.06   0.20  /system.slice/rtkit-daemon.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/sys-kernel-debug.mount
some   0.00   0.14   0.62 | full   0.00   0.14   0.62  /system.slice/accounts-daemon.service
some   7.86  11.48  12.56 | full   7.84  11.42  12.51  /system.slice/lightdm.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/ModemManager.service
some   0.00   1.82   5.47 | full   0.00   1.81   5.43  /system.slice/systemd-journald.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/dev-mqueue.mount
some   0.00   1.64   4.07 | full   0.00   1.64   4.07  /system.slice/NetworkManager.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/tmp.mount
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/lvm2-lvmetad.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/dev-disk-by\x2duuid-5d7355c0\x2dc131\x2d40c5\x2d8541\x2d1e04ad7c8b8d.swap
some   0.00   0.09   0.11 | full   0.00   0.09   0.11  /system.slice/upower.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/udisks2.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/dev-hugepages.mount
some   0.00   0.27   0.49 | full   0.00   0.27   0.48  /system.slice/dbus.service
some   0.00   0.00   0.00 | full   0.00   0.00   0.00  /system.slice/system-getty.slice
some   0.00   0.12   0.20 | full   0.00   0.12   0.20  /system.slice/avahi-daemon.service
some   0.00   0.18   0.30 | full   0.00   0.18   0.30  /system.slice/systemd-logind.service
```
</details>

### psi-monitor

It needs `Linux` >= 4.20 with `CONFIG_PSI=y`.

<details>
 <summary>Output example</summary>

```
$ psi-monitor
Set target to SYSTEM_WIDE to monitor /proc/pressure
Starting psi-monitor, target: SYSTEM_WIDE, period: 2
------------------------------------------------------------------------------------------------------------------
 some cpu pressure   || some memory pressure | full memory pressure ||  some io pressure    |  full io pressure
---------------------||----------------------|----------------------||----------------------|---------------------
 avg10  avg60 avg300 ||  avg10  avg60 avg300 |  avg10  avg60 avg300 ||  avg10  avg60 avg300 |  avg10  avg60 avg300
------ ------ ------ || ------ ------ ------ | ------ ------ ------ || ------ ------ ------ | ------ ------ ------
  0.17   0.83   0.57 ||  11.54  49.25  32.03 |  11.27  45.70  29.59 ||  42.80  78.67  42.78 |  42.09  74.13  39.81
  0.14   0.80   0.57 ||   9.63  47.67  31.81 |   9.41  44.24  29.39 ||  40.12  77.01  42.68 |  39.54  72.62  39.73
  0.11   0.77   0.56 ||   7.88  46.11  31.60 |   7.70  42.79  29.19 ||  32.85  74.49  42.39 |  32.38  70.25  39.46
  0.09   0.75   0.56 ||   6.45  44.60  31.38 |   6.31  41.39  28.99 ||  27.08  72.09  42.11 |  26.69  67.98  39.19
  0.07   0.72   0.55 ||   5.28  43.14  31.16 |   5.16  40.04  28.79 ||  22.90  69.86  41.85 |  22.58  65.89  38.95
  0.06   0.70   0.55 ||   4.33  41.73  30.95 |   4.23  38.73  28.60 ||  18.75  67.57  41.56 |  18.49  63.73  38.69
  0.05   0.67   0.55 ||   7.35  41.05  30.88 |   7.26  38.15  28.54 ||  20.24  66.25  41.46 |  20.03  62.53  38.61
  0.04   0.65   0.54 ||   6.38  39.77  30.68 |   6.31  36.96  28.36 ||  17.48  64.24  41.21 |  17.31  60.65  38.38
  0.03   0.63   0.54 ||   5.22  38.47  30.47 |   5.17  35.75  28.17 ||  14.67  62.21  40.94 |  14.53  58.73  38.13
  0.02   0.61   0.54 ||   4.27  37.21  30.27 |   4.23  34.58  27.97 ||  12.02  60.17  40.66 |  11.90  56.81  37.87
  0.02   0.59   0.53 ||   3.50  36.00  30.06 |   3.46  33.45  27.78 ||  10.20  58.27  40.40 |  10.10  55.01  37.62
  0.01   0.57   0.53 ||   2.86  34.82  29.85 |   2.83  32.36  27.59 ||   8.35  56.36  40.12 |   8.27  53.21  37.36
^CExit
$ psi-monitor /user.slice
Set target to /user.slice
Starting psi-monitor, target: /user.slice, period: 2
------------------------------------------------------------------------------------------------------------------
 some cpu pressure   || some memory pressure | full memory pressure ||  some io pressure    |  full io pressure
---------------------||----------------------|----------------------||----------------------|---------------------
 avg10  avg60 avg300 ||  avg10  avg60 avg300 |  avg10  avg60 avg300 ||  avg10  avg60 avg300 |  avg10  avg60 avg300
------ ------ ------ || ------ ------ ------ | ------ ------ ------ || ------ ------ ------ | ------ ------ ------
  0.00   0.00   0.00 ||   7.20  12.43  18.37 |   6.82  11.85  17.21 ||  31.15  40.69  36.31 |  30.08  39.47  34.62
  0.00   0.00   0.00 ||   5.90  12.03  18.24 |   5.59  11.46  17.09 ||  25.50  39.35  36.06 |  24.63  38.18  34.39
  0.00   0.00   0.00 ||   4.83  11.63  18.12 |   4.57  11.09  16.97 ||  20.88  38.07  35.81 |  20.17  36.93  34.15
  0.00   0.00   0.00 ||   3.95  11.25  17.99 |   3.74  10.72  16.86 ||  17.10  36.82  35.57 |  16.52  35.72  33.92
  0.00   0.00   0.00 ||   3.24  10.88  17.87 |   3.06  10.37  16.74 ||  14.00  35.62  35.33 |  13.52  34.55  33.68
  0.00   0.00   0.00 ||   2.65  10.53  17.75 |   2.51  10.03  16.63 ||  11.46  34.45  35.08 |  11.07  33.42  33.45
^CExit
```
</details>

## Contribution

Use cases, feature requests and any questions are [welcome](https://github.com/hakavlad/nohang/issues).

## Changelog

See [CHANGELOG.md](https://github.com/hakavlad/nohang/blob/master/CHANGELOG.md)
