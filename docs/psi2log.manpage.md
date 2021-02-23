% psi2log(1) | General Commands Manual

# NAME
psi2log \- PSI metrics monitor and logger

# SYNOPSIS
**psi2log** [**OPTION**]...

# DESCRIPTION
psi2log is a CLI tool that can check and log PSI metrics from specified target. psi2log is part of nohang package.

# OPTIONS

#### -h, --help
show this help message and exit

#### -t TARGET, --target TARGET
target (cgroup_v2 or SYTSTEM_WIDE)

#### -i INTERVAL, --interval INTERVAL
interval in sec

#### -l LOG, --log LOG
path to log file

#### -m MODE, --mode MODE
mode (0, 1 or 2)

#### -s SUPPRESS_OUTPUT, --suppress-output SUPPRESS_OUTPUT
suppress output

# EXAMPLES
$ psi2log

$ psi2log --mode 2

$ psi2log --target /user.slice --interval 1.5 --log psi.log

# SIGNALS
Sending SIGTERM, SIGINT, SIGQUIT or SIGHUP signals to the psi2log process causes it displays peak values and exits..

# REPORTING BUGS
Please ask any questions and report bugs at <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Written by Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
Homepage is <https://github.com/hakavlad/nohang>.

# SEE ALSO
oom-sort(1), psi-top(1), nohang(8)
