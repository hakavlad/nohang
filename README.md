
# Nohang

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) and keep system responsiveness in low memory conditions.

## What is the problem?

OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop [caches](https://en.wikipedia.org/wiki/Page_cache) and processes to be killed (via sending [SIGKILL](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGKILL)) instead of trying to terminate them correctly (via sending [SIGTERM](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGTERM) or takes other corrective action). Some applications may crash if it's impossible to allocate memory.

![pic](https://i.imgur.com/9yuZOOf.png)

Here are the statements of some users:

> "How do I prevent Linux from freezing when out of memory?
Today I (accidentally) ran some program on my Linux box that quickly used a lot of memory. My system froze, became unresponsive and thus I was unable to kill the offender.
How can I prevent this in the future? Can't it at least keep a responsive core or something running?"

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory)

> "With or without swap it still freezes before the OOM killer gets run automatically. This is really a kernel bug that should be fixed (i.e. run OOM killer earlier, before dropping all disk cache). Unfortunately kernel developers and a lot of other folk fail to see the problem. Common suggestions such as disable/enable swap, buy more RAM, run less processes, set limits etc. do not address the underlying problem that the kernel's low memory handling sucks camel's balls."

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory#comment417508_390625)

Also look at [Why are low memory conditions handled so badly?](https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/)

## Solution

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple and tiny OOM preventer written in C (the best choice for emedded and old servers). It has a minimum dependencies and can work with oldest kernels.
- Use of [oomd](https://github.com/facebookincubator/oomd). This is a userspace OOM killer for linux systems whitten in C++ and developed by Facebook. This is the best choice for use in large data centers. It needs Linux 4.20+.
- Use of `nohang` (maybe this is a good choice for modern desktops and servers if you need fine tuning).

The tools listed above may work at the same time on one computer.

#### See also

- `memlockd` is a daemon that locks files into memory. Then if a machine starts paging heavily the chance of being able to login successfully is significantly increased.

## Some features

- Sending the SIGTERM signal is default corrective action. If the victim does not respond to SIGTERM, with a further drop in the level of memory it gets SIGKILL.
- Impact on the badness of processes via matching their
    - names,
    - cmdlines and
    - eUIDs
    with specified regular expressions
- If the name of the victim matches a certain regex pattern, you can run any command instead of sending the SIGTERM signal (the default corrective action) to the victim. For example:
    - `sysmemctl restart foo`
    - `kill -INT $PID` (you can override the signal sent to the victim, $PID will be replaced by the victim's PID)
    - `kill -TERM $PID && script.sh` (in addition to sending any signal, you can run a specified script)
- GUI notifications:
    - Notification of corrective actions taken and displaying the name and PID of the victim
    - Low memory warnings (displays available memory)
- [zram](https://www.kernel.org/doc/Documentation/blockdev/zram.txt) support (`mem_used_total` as a trigger)
- Initial [PSI](https://lwn.net/Articles/759658/) ([pressure stall information](https://facebookmicrosites.github.io/psi/)) support ([demo](https://youtu.be/2m2c9TGva1Y))
- Easy configuration with a ~~well~~ commented [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf)

## Requirements

For basic usage:
- `Linux` 3.14+ (since `MemAvailable` appeared in `/proc/meminfo`)
- `Python` 3.3+ (not tested with previous)

To show GUI notifications:
- [notification server](https://wiki.archlinux.org/index.php/Desktop_notifications#Notification_servers) (most of desktop environments use their own implementations)
- `libnotify` (Fedora, Arch Linux) or `libnotify-bin` (Debian GNU/Linux, Ubuntu)
- `sudo` if nohang started with UID=0

To use `PSI`:
- `Linux` 4.20+

## Memory and CPU usage

- VmRSS is about 10 - 12 MiB instead of the settings, about 10 MiB by default.
- CPU usage depends on the level of available memory and monitoring intensity.

## Download, install, uninstall

Please use the latest [release version](https://github.com/hakavlad/nohang/releases). Current version may be unstable.

To download the latest stable version (v0.1):
```bash
$ wget -ct0 https://github.com/hakavlad/nohang/archive/v0.1.tar.gz
$ tar xvzf v0.1.tar.gz
$ cd nohang-0.1
```

or to clone the latest unstable:
```bash
$ git clone https://github.com/hakavlad/nohang.git
$ cd nohang
```

To install:
```bash
$ sudo make install
```

To enable and start on systems with systemd:
```bash
$ sudo make systemd
```

To uninstall:
```bash
$ sudo make uninstall
```

For Arch Linux, there's an [AUR package](https://aur.archlinux.org/packages/nohang-git/). Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers). For example,

```bash
$ yay -S nohang-git
$ sudo systemctl start nohang
$ sudo systemctl enable nohang
```

## Command line options

```
./nohang -h
usage: nohang [-h] [-c CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        path to the config file, default values:
                        ./nohang.conf, /etc/nohang/nohang.conf
```

## How to configure nohang

The program can be configured by editing the [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf). The configuration includes the following sections:

1. Memory levels to respond to as an OOM threat
2. Response on PSI memory metrics
3. The frequency of checking the level of available memory (and CPU usage)
4. The prevention of killing innocent victims
5. Impact on the badness of processes via matching their names, cmdlines and UIDs with regular expressions
6. The execution of a specific command or sending any signal instead of sending the SIGTERM signal
7. GUI notifications:
   - notifications of corrective actions taken
   - low memory warnings
8. Verbosity
9. Misc

Just read the description of the parameters and edit the values. Please restart nohang to apply changes. Default path to the config after installing is `/etc/nohang/nohang.conf`.


## oom-sort

`oom-sort` is an additional diagnostic tool that will be installed with `nohang` package. It sorts the processes in descending order of their `oom_score` and also displays `oom_score_adj`, `Uid`, `Pid`, `Name`, `VmRSS`, `VmSwap` and optionally `cmdline`. Run `oom-sort --help` for more info.

Usage:

```
$ oom-sort
```

Output like follow:

```
oom_score oom_score_adj   Uid   Pid Name             VmRSS   VmSwap   cmdline
--------- ------------- ----- ----- --------------- -------- -------- -------
      314           300  1000   991 chromium            84 M      0 M /usr/lib/chromium/chromium --type=renderer --field-trial-handle=868244496792098610,5765419126773948943,131072 --service-pipe-token=14782672631740123203 --lang=ru --user-data-dir=/tmp/tmp.TJ91B6F0zB --disable-client-side-phishing-detection --enable-offline-auto-reload --enable-offline-auto-reload-visible-only --num-raster-threads=1 --service-request-channel-token=14782672631740123203 --renderer-client-id=4 --no-v8-untrusted-code-mitigations --shared-files=v8_context_snapshot_data:100,v8_natives_data:101
      307           300  1000  1124 chromium            44 M      0 M /usr/lib/chromium/chromium --type=renderer --field-trial-handle=868244496792098610,5765419126773948943,131072 --service-pipe-token=10276223625123198448 --lang=ru --user-data-dir=/tmp/tmp.TJ91B6F0zB --disable-client-side-phishing-detection --enable-offline-auto-reload --enable-offline-auto-reload-visible-only --num-raster-threads=1 --service-request-channel-token=10276223625123198448 --renderer-client-id=6 --no-v8-untrusted-code-mitigations --shared-files=v8_context_snapshot_data:100,v8_natives_data:101
      217           200  1000   962 chromium            99 M      0 M /usr/lib/chromium/chromium --type=gpu-process --field-trial-handle=868244496792098610,5765419126773948943,131072 --user-data-dir=/tmp/tmp.TJ91B6F0zB --disable-breakpad --gpu-preferences=KAAAAAAAAACAAABAAQAAAAAAAAAAAGAAAAAAAAEAAAAIAAAAAAAAAAgAAAAAAAAA --user-data-dir=/tmp/tmp.TJ91B6F0zB --service-request-channel-token=2848128951654484113
      202           200  1000  1032 chromium            16 M      0 M /usr/lib/chromium/chromium --type=-broker
       43             0  1000   736 firefox-esr        251 M      0 M /usr/lib/firefox-esr/firefox-esr
       21             0  1000   914 chromium           124 M      0 M /usr/lib/chromium/chromium --show-component-extension-options --ignore-gpu-blacklist --no-default-browser-check --disable-pings --media-router=0 --enable-remote-extensions --user-data-dir=/tmp/tmp.TJ91B6F0zB
       17             0  1000   844 Web Content        103 M      0 M /usr/lib/firefox-esr/plugin-container -greomni /usr/lib/firefox-esr/omni.ja -appomni /usr/lib/firefox-esr/browser/omni.ja -appdir /usr/lib/firefox-esr/browser 736 true tab
       16             0  1000 31555 dolphin             95 M      0 M dolphin
       15             0     0   863 Xorg                92 M      0 M /usr/lib/xorg/Xorg :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
        8             0   110   860 tor                 50 M      0 M /usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /etc/tor/torrc --RunAsDaemon 0
        8             0  1000   918 chromium            48 M      0 M /usr/lib/chromium/chromium --type=zygote --user-data-dir=/tmp/tmp.TJ91B6F0zB
        7             0  1000  1106 mate-panel          43 M      0 M mate-panel
        6             0  1000  1157 wnck-applet         35 M      0 M /usr/lib/mate-panel/wnck-applet
```

Kthreads, zombies and Pid 1 will not be displayed.

## Logging

To view the latest entries in the log (for systemd users):

```bash
$ sudo journalctl -eu nohang
```
See also `man journalctl`.

You can also enable `separate_log` in the config to logging in `/var/log/nohang/nohang.log`.

## Known problems

- Awful documentation.

## Nohang don't help you

if you run
```bash
$ while true; do setsid tail /dev/zero; done
```

(although with some settings nohang can even handle it)

## Contribution

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.

## Changelog

- In progress
    - [x] Improve output:
        - [x] Display `oom_score`, `oom_score_adj`, `Ancestry`, `EUID`, `State`, `VmSize`, `RssAnon`, `RssFile`, `RssShmem`, `Realpath`, `Cmdline` and `Lifetime` of the victim in corrective action reports
        - [x] Add memory report interval
        - [x] Add delta memory info (the rate of change of available memory)
        - [x] Print statistics on corrective actions after each corrective action
        - [x] Added ability to print a process table before each corrective action
        - [x] Added the ability to log into a separate file
    - [x] Improve poll rate algorithm
    - [x] Add `max_post_sigterm_victim_lifetime` option: send SIGKILL to the victim if it doesn't respond to SIGTERM for a certain time
    - [x] Improve victim search algorithm (do it ~30% faster) ([rfjakob/earlyoom#114](https://github.com/rfjakob/earlyoom/issues/114))
    - [x] Improve limiting `oom_score_adj`: now it can works with UID != 0
    - [x] Fixed process crash before performing corrective actions if Python 3.3 or Python 3.4 are used to interpret nohang
    - [x] Improve GUI warnings:
        - [x] Find env without run `ps`
        - [x] Handle all timeouts when notify-send starts
    - [x] Fix conf parsing: use of `line.partition('=')` instead of `line.split('=')`
    - [x] Add `oom-sort`
    - [x] Add `--version` and `--test` flags
    - [x] Remove self-defense options from config, use systemd unit scheduling instead
    - [x] Add the ability to send any signal instead of SIGTERM for processes with certain names
    - [x] Handle `UnicodeDecodeError` if victim name consists of many unicode characters ([rfjakob/earlyoom#110](https://github.com/rfjakob/earlyoom/issues/110))
    - [x] Reduce memory usage with `mlockall()` using `MCL_ONFAULT` ([rfjakob/earlyoom#112](https://github.com/rfjakob/earlyoom/issues/112)) and lock all memory by default
    - [x] Reduce memory usage and startup time (using `sys.argv` instead of `argparse`)
    - [x] Add initial support for `PSI`
    - [x] Improve modifing badness via matching with regular expressions:
        - [x] Adding the ability to set many different `badness_adj` for processes depending on the matching `name`, `cmdline` and `euid` with the specified regular expressions ([issue #74](https://github.com/hakavlad/nohang/issues/11))
        - [x] Fix: replace `re.fullmatch()` by `re.search()`
    - [ ] Redesign of the GUI notifications
    - [ ] Improve user input validation
    - [ ] Improve documentation

- [v0.1](https://github.com/hakavlad/nohang/releases/tag/v0.1), 2018-11-23: Initial release
