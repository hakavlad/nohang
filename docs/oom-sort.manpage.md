% OOM-SORT(1) | General Commands Manual

# NAME
oom-sort - sort processes by oom_score

# SYNOPSIS
**oom-sort** [**OPTION**]...

# DESCRIPTION
**oom-sort** is a script that sorts tasks by oom_score by default. **oom-sort** is part of the **nohang** package.

# OPTIONS

#### -h, \--help
Show this help message and exit.

#### \--num NUM, -n NUM
Maximum number of lines; default: 99999.

#### \--len LEN, -l LEN
Maximum cmdline length; default: 99999.

#### \--sort SORT, -s SORT
Sort by unit; available units: oom_score, oom_score_adj, UID, PID, Name, VmRSS, VmSwap, cmdline (optional); default unit: oom_score.

# REPORTING BUGS
Please direct questions and bug reports to <https://github.com/hakavlad/nohang/issues>.

# AUTHOR
Alexey Avramov <hakavlad@gmail.com>.

# HOMEPAGE
<https://github.com/hakavlad/nohang>

# SEE ALSO
psi-top(1), psi2log(1), nohang(8)
