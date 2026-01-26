% NOHANG(8) | Linux System Administrator\'s Manual

# NAME
nohang - A sophisticated low memory handler

# SYNOPSIS
**nohang** [**OPTION**]...

# DESCRIPTION
**nohang** is a highly configurable daemon for Linux which can correctly prevent out of memory (OOM) and maintain system responsiveness under low memory conditions.

# REQUIREMENTS

#### For basic usage:
- Linux (>= 3.14, since MemAvailable appeared in **/proc/meminfo**)
- Python (>= 3.3)

#### To respond to PSI metrics (optional):
- Linux (>= 4.20) with **CONFIG_PSI=y**

#### To show GUI notifications (optional):
- Notification server (most desktop environments use their own implementations).
- **libnotify** (Arch Linux, Fedora, openSUSE) or **libnotify-bin** (Debian GNU/Linux, Ubuntu).
- sudo if **nohang** started with UID=0.

# COMMAND-LINE OPTIONS

#### -h, \--help
Show this help message and exit.

#### -v, \--version
Show version of installed package and exit.

#### -m, \--memload
Consume memory until 40 MiB (MemAvailable + SwapFree) remain free, then terminate the process.

#### -c CONFIG, \--config CONFIG
Path to the config file. This should only be used with one of the following options:
**\--monitor**, **\--tasks**, **\--check**.

#### \--check
Check and show the configuration and exit. This should only be used with the **-c**/**\--config** option.

#### \--monitor
Start monitoring. This should only be used with the **-c**/**\--config** option.

#### \--tasks
Show tasks state and exit. This should only be used with the **-c**/**\--config** option.

# FILES

#### :SYSCONFDIR:/nohang/nohang.conf
Vanilla **nohang** configuration file.

#### :SYSCONFDIR:/nohang/nohang-desktop.conf
Configuration file with settings optimized for desktop usage.

#### :DATADIR:/nohang/nohang.conf
File with *default* **nohang.conf** values.

#### :DATADIR:/nohang/nohang-desktop.conf
File with *default* **nohang-desktop.conf** values.

#### /var/log/nohang/nohang.log
Optional log file that stores entries if **separate_log=True**.

#### /etc/logrotate.d/nohang
Logrotate config file controlling rotation in **/var/log/nohang/**.

# nohang.conf vs nohang-desktop.conf
- **nohang.conf** provides vanilla default settings without PSI checking, badness correction, or GUI notifications enabled.
- **nohang-desktop.conf** provides default settings optimized for desktop usage.

# KNOWN PROBLEMS
Problems can occur with out-of-tree kernels and modules:

- The ZFS ARC cache is memory-reclaimable, like the Linux buffer cache; however, unlike the buffer cache, it currently does not count to MemAvailable [1]. See also [2] and [3].
- Linux kernels without **CONFIG_CGROUP_CPUACCT=y** (linux-ck, for example) provide incorrect PSI metrics, see this thread [4].

# HOW TO CONFIGURE
The program can be configured by editing the config file; the configuration includes the following sections:

- Memory levels to consider an OOM threat
- Response on PSI memory metrics
- Frequency of checking memory availability (and CPU usage)
- Prevention of killing innocent victims
- Modify process badness by matching their names, cmdlines, and UIDs with regular expressions
- The execution of a specific command or sending any signal instead of SIGTERM
- GUI notifications:
  - notifications of corrective actions taken
  - low memory warnings
- Verbosity
- Misc

Read the parameter descriptions, edit the values, and restart the daemon to apply changes.

# CHECK CONFIG
Check the config for errors:
```
$ nohang --check --config /path/to/config
```

# HOW TO TEST
The safest way is to run **nohang \--memload**. This causes memory consumption; the process will exit before OOM occurs. Another method is running **tail /dev/zero**; this causes fast memory comsumption and OOM at the end. If testing occurs while nohang is running, these processes should be terminated before OOM occurs.

# LOGGING
To view the latest entries in the log (for systemd users):
```
$ sudo journalctl -eu nohang.service
```
or
```
$ sudo journalctl -eu nohang-desktop.service
```
You can also enable **separate_log** in the config to log to **/var/log/nohang/nohang.log**.

# SIGNALS
Sending **SIGTERM**, **SIGINT**, **SIGQUIT**, or **SIGHUP** signals to **nohang** causes it to display corrective action stats and exit.

# REPORTING BUGS
Please direct questions and bug reports to <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
<https://github.com/hakavlad/nohang>

# SEE ALSO
oom-sort(1), psi-top(1), psi2log(1)

# NOTES

1. https://github.com/openzfs/zfs/issues/10255
2. https://github.com/rfjakob/earlyoom/pull/191#issuecomment-622314296
3. https://github.com/hakavlad/nohang/issues/89
4. https://github.com/hakavlad/nohang/issues/25#issuecomment-521390412
