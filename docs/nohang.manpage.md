% nohang(8) | Linux System Administrator's Manual

# NAME
nohang - A sophisticated low memory handler

# SYNOPSIS
**nohang** [**OPTION**]...

# DESCRIPTION
nohang is a highly configurable daemon for Linux which is able to correctly prevent out of memory (OOM) and keep system responsiveness in low memory conditions.

# REQUIREMENTS

#### For basic usage:
- Linux (>= 3.14, since MemAvailable appeared in /proc/meminfo)
- Python (>= 3.3)

#### To respond to PSI metrics (optional):
- Linux (>= 4.20) with CONFIG_PSI=y

#### To show GUI notifications (optional):
- notification server (most of desktop environments use their own implementations)
- libnotify (Arch Linux, Fedora, openSUSE) or libnotify-bin (Debian GNU/Linux, Ubuntu)
- sudo if nohang started with UID=0.

# COMMAND-LINE OPTIONS

#### -h, --help
show this help message and exit

#### -v, --version
show version of installed package and exit

#### -m, --memload
consume memory until 40 MiB (MemAvailable + SwapFree) remain free, and terminate the process

#### -c CONFIG, --config CONFIG
path to the config file. This should only be used with one of the following options:
--monitor, --tasks, --check

#### --check
check and show the configuration and exit. This should only be used with -c/--config CONFIG option

#### --monitor
start monitoring. This should only be used with -c/--config CONFIG option

#### --tasks
show tasks state and exit. This should only be used with -c/--config CONFIG option

# FILES

#### $SYSCONFDIR/nohang/nohang.conf
path to vanilla nohang configuration file

#### $SYSCONFDIR/nohang/nohang-desktop.conf
path to configuration file with settings optimized for desktop usage

#### $DATADIR/nohang/nohang.conf
path to file with *default* nohang.conf values

#### $DATADIR/nohang/nohang-desktop.conf
path to file with *default* nohang-desktop.conf values

#### /var/log/nohang/nohang.log
optional log file that stores entries if separate_log=True in the config

#### /etc/logrotate.d/nohang
logrotate config file that controls rotation in /var/log/nohang/

# nohang.conf vs nohang-desktop.conf
- nohang.conf provides vanilla default settings without PSI checking enabled, without any badness correction and without GUI notifications enabled.
- nohang-desktop.conf provides default settings optimized for desktop usage.

# PROBLEMS
The next problems can occur with out-of-tree kernels and modules:

- The ZFS ARC cache is memory-reclaimable, like the Linux buffer cache. However, in contrast to the buffer cache, it currently does not count to MemAvailable [1]. See also [2] and [3].
- Linux kernels without CONFIG_CGROUP_CPUACCT=y (linux-ck, for example) provide incorrect PSI metrics, see this thread [4].

# HOW TO CONFIGURE
The program can be configured by editing the config file. The configuration includes the following sections:

- Memory levels to respond to as an OOM threat
- Response on PSI memory metrics
- The frequency of checking the level of available memory (and CPU usage)
- The prevention of killing innocent victims
- Impact on the badness of processes via matching their names, cmdlines and UIDs with regular expressions
- The execution of a specific command or sending any signal instead of sending the SIGTERM signal
- GUI notifications:
    - notifications of corrective actions taken
    - low memory warnings
- Verbosity
- Misc

Just read the description of the parameters and edit the values. Restart the daemon to apply the changes.

# CHECK CONFIG
Check the config for errors:

$ nohang --check --config /path/to/config

# HOW TO TEST
The safest way is to run **nohang --memload**. This causes memory consumption, and the process will exits before OOM occurs. Another way is to run **tail /dev/zero**. This causes fast memory comsumption and causes OOM at the end. If testing occurs while nohang is running, these processes should be terminated before OOM occurs.

# LOGGING
To view the latest entries in the log (for systemd users):

$ **sudo journalctl -eu nohang.service**

or

$ **sudo journalctl -eu nohang-desktop.service**

You can also enable **separate_log** in the config to logging in **/var/log/nohang/nohang.log**.

# SIGNALS
Sending SIGTERM, SIGINT, SIGQUIT or SIGHUP signals to the nohang process causes it displays corrective action stats and exits.

# REPORTING BUGS
Please ask any questions and report bugs at <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Written by Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
Homepage is <https://github.com/hakavlad/nohang>.

# SEE ALSO
oom-sort(1), psi-top(1), psi2log(1)

# NOTES

1. https://github.com/openzfs/zfs/issues/10255
2. https://github.com/rfjakob/earlyoom/pull/191#issuecomment-622314296
3. https://github.com/hakavlad/nohang/issues/89
4. https://github.com/hakavlad/nohang/issues/25#issuecomment-521390412
