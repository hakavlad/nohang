% PSI-TOP(1) | General Commands Manual

# NAME
psi-top - print the PSI metrics values for every cgroup.

# SYNOPSIS
**psi-top** [**OPTION**]...

# DESCRIPTION
**psi-top** is a script that prints the PSI metrics values for every cgroup. **psi-top** is part of the nohang package.

# OPTIONS

#### -h, \--help
Show this help message and exit.

#### -m METRICS, \--metrics METRICS
Metrics: memory, io, or cpu.

# EXAMPLES
```
$ psi-top

$ psi-top --metrics io

$ psi-top -m cpu
```

# REPORTING BUGS
Please direct questions and bug reports to <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
<https://github.com/hakavlad/nohang>

# SEE ALSO
oom-sort(1), psi2log(1), nohang(8)
