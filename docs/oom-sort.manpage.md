% oom-sort(1) | General Commands Manual

# NAME
oom-sort - sort processes by oom_score

# SYNOPSIS
**oom-sort** [**OPTION**]...

# DESCRIPTION
oom-sort is script that sorts tasks by oom_score by default. oom-sort is part of nohang package.

# OPTIONS

#### -h, --help
show this help message and exit

#### --num NUM, -n NUM
max number of lines; default: 99999

#### --len LEN, -l LEN
max cmdline length; default: 99999

#### --sort SORT, -s SORT
sort by unit; available units: oom_score, oom_score_adj, UID, PID, Name, VmRSS, VmSwap, cmdline (optional); default unit: oom_score

# REPORTING BUGS
Please ask any questions and report bugs at <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Written by Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
Homepage is <https://github.com/hakavlad/nohang>.

# SEE ALSO
psi-top(1), psi2log(1), nohang(8)
