% psi-top(1) | General Commands Manual

# NAME
psi-top - print the PSI metrics values for every cgroup.

# SYNOPSIS
**psi-top** [**OPTION**]...

# DESCRIPTION
psi-top is script that prints the PSI metrics values for every cgroup. psi-top is part of nohang package.

# OPTIONS

#### -h, --help
show this help message and exit

#### -m METRICS, --metrics METRICS
metrics (memory, io or cpu)

# EXAMPLES
$ psi-top

$ psi-top --metrics io

$ psi-top -m cpu

# REPORTING BUGS
Please ask any questions and report bugs at <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Written by Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
Homepage is <https://github.com/hakavlad/nohang>.

# SEE ALSO
oom-sort(1), psi2log(1), nohang(8)
