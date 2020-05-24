# Changelog

This changelog is outdated. It will be updated later.

## [Unreleased]

- Added new CLI options:
    - -v, --version
    - -m, --memload
    - --monitor
    - --tasks
    - --check-config
- Possible process crashes are fixed:
    - Fixed crash at startup due to `UnicodeDecodeError` on some systems
    - Handled  `UnicodeDecodeError` if victim name consists of many unicode characters ([rfjakob/earlyoom#110](https://github.com/rfjakob/earlyoom/issues/110))
    - Fixed process crash before performing corrective actions if Python 3.4 or lower are used to interpret nohang
- Improve output:
    - Display `oom_score`, `oom_score_adj`, `Ancestry`, `EUID`, `State`, `VmSize`, `RssAnon`, `RssFile`, `RssShmem`, `CGroup_v1`, `CGroup_v2`, `Realpath`, `Cmdline` and `Lifetime` of the victim in corrective action reports
    - Added memory report interval
    - Added delta memory info (the rate of change of available memory)
    - Print statistics on corrective actions after each corrective action
    - Added ability to print a process table before each corrective action
    - Added the ability to log into a separate file
- Improved GUI warnings:
    - Reduced the idle time of the daemon in the process of launching a notification
    - All notify-send calls are made using the `nohang_notify_helper` script, in which all timeouts are handled (not anymore: nohang_notify_helper has been removed)
    - Native python implementation of `env` search without running `ps` to notify all users if nohang started with UID=0.
- Improved modifing badness via matching with regular expressions:
    - Added the ability to set many different `badness_adj` for processes depending on the matching `Name`, `CGroup_v1`, `CGroup_v2`, `cmdline`, `realpath`, `environ` and `EUID` with the specified regular expressions ([issue #11](https://github.com/hakavlad/nohang/issues/11))
    - Fix: replace `re.fullmatch()` by `re.search()`
- Reduced memory usage:
    - Reduced memory usage and startup time (using `sys.argv` instead of `argparse`)
    - Reduced memory usage with `mlockall()` using `MCL_ONFAULT` ([rfjakob/earlyoom#112](https://github.com/rfjakob/earlyoom/issues/112))
- Lock all memory by default using mlockall()
- Added new tools:
    - `oom-sort`
    - `psi-top`
    - `psi2log`
- Improve poll rate algorithm
- Fixed Makefile for installation on CentOS 7 (remove gzip `-k` option).
- Added `max_post_sigterm_victim_lifetime` option: send SIGKILL to the victim if it doesn't respond to SIGTERM for a certain time
- Added `post_kill_exe` option (the ability to run any command after killing a victim)
- Added `warning_exe` option (the ability to run any command instead of GUI low memory warnings)
- Added `victim_cache_time` option
- Improved victim search algorithm (do it ~30% faster) ([rfjakob/earlyoom#114](https://github.com/rfjakob/earlyoom/issues/114))
- Improved limiting `oom_score_adj`: now it can works with UID != 0
- Fixed conf parsing: use of `line.partition('=')` instead of `line.split('=')`
- Removed self-defense options from the config, use systemd unit scheduling instead
- Added the ability to send any signal instead of SIGTERM for processes with certain names
- Added support for `PSI`
- Recheck memory levels after finding a victim to prevent killing innocent victims in some cases ([issue #20](https://github.com/hakavlad/nohang/issues/20))
- Now one corrective action to one victim can be applied only once.
- Ignoring zram by default, checking for this has become optional.
- Improved user input validation
- Improved documentation
- Handle signals (SIGTERM, SIGINT, SIGQUIT, SIGHUP), print total stat by corrective actions at exit.

## [0.1] - 2018-11-23

[unreleased]: https://github.com/hakavlad/nohang/compare/v0.1...HEAD
[0.1]: https://github.com/hakavlad/nohang/releases/tag/v0.1
