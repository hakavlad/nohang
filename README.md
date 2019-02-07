
# Nohang

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) and keep system responsiveness in low memory conditions.

![pic](https://i.imgur.com/Hq1JPMs.png)

## What is the problem?

OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop [caches](https://en.wikipedia.org/wiki/Page_cache) and processes to be killed (via sending [SIGKILL](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGKILL)) instead of trying to terminate them correctly (via sending [SIGTERM](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGTERM) or takes other corrective action). Some applications may crash if it's impossible to allocate memory.

Here are the statements of some users:

> "How do I prevent Linux from freezing when out of memory?
Today I (accidentally) ran some program on my Linux box that quickly used a lot of memory. My system froze, became unresponsive and thus I was unable to kill the offender.
How can I prevent this in the future? Can't it at least keep a responsive core or something running?"

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory)

> "With or without swap it still freezes before the OOM killer gets run automatically. This is really a kernel bug that should be fixed (i.e. run OOM killer earlier, before dropping all disk cache). Unfortunately kernel developers and a lot of other folk fail to see the problem. Common suggestions such as disable/enable swap, buy more RAM, run less processes, set limits etc. do not address the underlying problem that the kernel's low memory handling sucks camel's balls."

— [serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory#comment417508_390625)

Also look at [Why are low memory conditions handled so badly?](https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/) (discussion with 480+ posts on r/linux).

## Solution

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple and very lightweight OOM preventer written in C (the best choice for emedded and old servers). It has a minimum dependencies and can work with oldest kernels.
- Use of [oomd](https://github.com/facebookincubator/oomd). This is a userspace OOM killer for linux systems whitten in C++ and developed by Facebook. Needs Linux 4.20+.
- Use of nohang (maybe this is a good choice for modern desktops and servers if you need fine tuning).

The tools listed above may work at the same time on one computer.

## Some features

- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- the ability to send any signal instead of SIGTERM for processes with certain names ([screenshot](https://i.imgur.com/cs1PRC5.png))
- impact on the badness of processes via matching their names, cmdlines and UIDs with regular expressions
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim (or run any other command)
- GUI notifications:
    - OOM prevention results (displays sended signal and displays PID and name of victim)
    - Low memory warnings (displays available memory and name of fattest process)
- `zram` support (`mem_used_total` as a trigger)
- `PSI` support (since Linux 4.20+, using `/proc/pressure/memory` and `some avg10` as a trigger)
- customizable intensity of monitoring
- convenient configuration with a ~~well~~ commented [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf)

## Requirements

For basic usage:
- `Linux` 3.14+ (since `MemAvailable` appeared in `/proc/meminfo`)
- `Python` 3.3+ (not tested with previous)

To show GUI notifications:
- [notification server](https://wiki.archlinux.org/index.php/Desktop_notifications#Notification_servers) (most of desktop environments use their own implementations)
- `libnotify` (Fedora, Arch Linux) or `libnotify-bin` (Debian GNU/Linux, Ubuntu)
- `sudo` if nohang started with UID=0

To use `PSI` (pressure stall information):
- `Linux` 4.20+

## Memory and CPU usage

- VmRSS is about 10 MiB
- CPU usage depends on the level of available memory and monitoring intensity

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

## How to configure nohang

The program can be configured by editing the [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf). The configuration includes the following sections:

1. Memory levels to respond to as an OOM threat
2. The frequency of checking the level of available memory (and CPU usage)
3. The prevention of killing innocent victims
4. Impact on the badness of processes via matching their names, cmdlines and UIDs with regular expressions
5. The execution of a specific command or sending any signal instead of sending the SIGTERM signal
6. GUI notifications:
   - results of preventing OOM
   - low memory warnings
7. Output verbosity

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

## Known problems

- Awful documentation
- Slowly starting, slowly looking for a victim, especially when using swapspace (although this should be enough for more than 95% of all cases, IMHO)
- It is written in an interpreted language and is actually a prototype

## Todo

- Rewrite all code in Golang with tests and good documentation.

## Nohang don't help you

if you run
```bash
$ while true; do setsid tail /dev/zero; done
```

## Contribution

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.

## Changelog

- In progress
    - Improve modifing badness by matching with RE pattern: 
        - Add suppot matching `cmdline` and `euid` with regular expressions
        - Adding the ability to set many different badness_adj for processes depending on the matching `name`, `cmdline` and `euid` with the specified regular expressions
        - Fix: replace `re.fullmatch()` by `re.search()`
        - Validation RE patterns at startup
    - Improve output:
        - Display `UID`, `oom_score`, `oom_score_adj`, `VmSize`, `RssAnon`, `RssFile`, `RssShmem`, `state`, `realpath` and `cmdline` of the victim in corrective action reports
        - Print in terminal with colors
        - Print statistics on corrective actions after each corrective action
    - Improve poll rate algorithm
    - Improve improve victim search algorithm (do it ~30% faster)
    - Improve limiting `oom_score_adj`: now it can works without UID=0
    - Improve GUI warnings:
        - Find env without run `ps`
        - Handle all timeouts when notify-send starts
    - Fix conf parsing: use of `line.partition('=')` instead of `line.split('=')`
    - Add `PSI` support (using `/proc/pressure/memory`, need Linux 4.20+)
    - Add `oom-sort`
    - Redesign of the config
    - Remove CLI options
    - Remove self-defense options from config, use systemd unit scheduling instead
    - Add the ability to send any signal instead of SIGTERM for processes with certain names
    - Handle UnicodeDecodeError if victim name consists of many unicode characters

- [v0.1](https://github.com/hakavlad/nohang/releases/tag/v0.1), 2018-11-23
    - 1st release
