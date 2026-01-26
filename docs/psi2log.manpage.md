% PSI2LOG(1) | General Commands Manual

# NAME
psi2log - PSI metrics monitor and logger

# SYNOPSIS
**psi2log** [**OPTION**]...

# DESCRIPTION
**psi2log** is a CLI tool that can check and log PSI metrics from a specified target. **psi2log** is part of the **nohang** package.

# OPTIONS

#### -h, \--help
Show this help message and exit.

#### -t TARGET, \--target TARGET
Target (cgroup_v2 or SYSTEM_WIDE).

#### -i INTERVAL, \--interval INTERVAL
Interval in seconds.

#### -l LOG, \--log LOG
Path to log file.

#### -m MODE, \--mode MODE
Mode (0, 1, or 2).

#### -s SUPPRESS_OUTPUT, \--suppress-output SUPPRESS_OUTPUT
Suppress output.

# EXAMPLES
```
$ psi2log

$ psi2log --mode 2

$ psi2log --target /user.slice --interval 1.5 --log psi.log
```

# SIGNALS
Sending **SIGTERM**, **SIGINT**, **SIGQUIT**, or **SIGHUP** to the **psi2log** process causes it to display peak values and exit.

# REPORTING BUGS
Please direct questions and bug reports to <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
<https://github.com/hakavlad/nohang>

# SEE ALSO
oom-sort(1), psi-top(1), nohang(8)
