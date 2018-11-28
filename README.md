
# Nohang

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) and keep system responsiveness in low memory conditions.

## What is the problem?

OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop [caches](https://en.wikipedia.org/wiki/Page_cache) and processes to be killed (via sending [SIGKILL](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGKILL)) instead of trying to terminate them correctly (via sending [SIGTERM](https://en.wikipedia.org/wiki/Signal_(IPC)#SIGTERM) or takes other corrective action). Some applications may crash if it's impossible to allocate memory.

Here are the statements of some users:

> "How do I prevent Linux from freezing when out of memory?
Today I (accidentally) ran some program on my Linux box that quickly used a lot of memory. My system froze, became unresponsive and thus I was unable to kill the offender.
How can I prevent this in the future? Can't it at least keep a responsive core or something running?"

([serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory))

> "With or without swap it still freezes before the OOM killer gets run automatically. This is really a kernel bug that should be fixed (i.e. run OOM killer earlier, before dropping all disk cache). Unfortunately kernel developers and a lot of other folk fail to see the problem. Common suggestions such as disable/enable swap, buy more RAM, run less processes, set limits etc. do not address the underlying problem that the kernel's low memory handling sucks camel's balls."

([serverfault](https://serverfault.com/questions/390623/how-do-i-prevent-linux-from-freezing-when-out-of-memory#comment417508_390625))

Also look at [Why are low memory conditions handled so badly?](https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/) (discussion with 480+ posts on r/linux).


## Solution

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple and lightweight OOM preventer written in C.
- Use of [oomd](https://github.com/facebookincubator/oomd). This is a userspace OOM killer for linux systems whitten in C++ and developed by Facebook.
- Use of nohang.

## Some features

- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- impact on the badness of processes via matching their names with regular expressions
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- GUI notifications: OOM prevention results and low memory warnings
- `zram` support (`mem_used_total` as a trigger)
- customizable intensity of monitoring
- convenient configuration with a well commented [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf)


## Demo

Nohang prevents Out Of Memory with GUI notifications: [video](https://youtu.be/ChTNu9m7uMU)

![pic](https://i.imgur.com/wTZCtrN.png)

## Requirements

For basic usage:
- `Linux` 3.14+
- `Python` 3.4+

To show GUI notifications:
- `libnotify` (Fedora, Arch Linux) or `libnotify-bin` (Debian GNU/Linux, Ubuntu)
- `sudo` and `procps` if nohang is started as root

## Memory and CPU usage

- VmRSS is 10 — 14 MiB depending on the settings (about 10 MiB by default)
- CPU usage depends on the level of available memory (the frequency of memory status checks increases as the amount of available memory decreases) and monitoring intensity (can be changed by the user via the config)

## Download, install, uninstall

Please use the latest [release version](https://github.com/hakavlad/nohang/releases). Current version may be more unstable.

```bash
$ git clone https://github.com/hakavlad/nohang.git
$ cd nohang
```

Run without installing (low memory warnings may not work; note that processes with UID != your UID will not receive signals if nohang is started as a regular user):

```
$ ./nohang
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

For Arch Linux, there's an [AUR package](https://aur.archlinux.org/packages/nohang-git/). Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers).


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
2. The frequency of checking the level of available memory (and CPU usage)
3. The prevention of killing innocent victims
4. Impact on the badness of processes via matching their names with regular expressions
5. The execution of a specific command instead of sending the SIGTERM signal
6. GUI notifications:
   - results of preventing OOM
   - low memory warnings
7. Preventing the slowing down of the program
8. Output verbosity

Just read the description of the parameters and edit the values. Please restart nohang to apply changes. Default path to the config after installing is `/etc/nohang/nohang.conf`.


## Oom-top

`oom-top` is an additional diagnostic utility from the nohang package. It sorts the processes in descending order of their oom_score and also displays oom_score_adj, Pid, Name, VmRSS, VmSwap. It will be installed together with nohang. 

Usage:

```
$ oom-top
```

Output like this (monitors top 20 processes with period = 1 sec):

```
oom_score oom_adj oom_score_adj   Pid Name                 RSS       Swap
--------- ------- ------------- ----- --------------- --------- ---------
      314       5           300  2397 chromium             84 M       0 M
      307       5           300  2470 chromium             44 M       0 M
      217       3           200  2378 chromium            101 M       0 M
      202       3           200  2444 chromium             16 M       0 M
       41       0             0  2526 firefox.real        242 M       0 M
       21       0             0  2327 chromium            126 M       0 M
       18       0             0  2598 Web Content         106 M       0 M
       15       0             0  1816 dolphin              88 M       0 M
       15       0             0  1840 kate                 90 M       0 M
       14       0             0   852 Xorg                 86 M       0 M
       12       0             0  2644 Web Content          70 M       0 M
        8       0             0  1108 mate-panel           50 M       0 M
```

## Logging

If nohang is installed on a system that uses systemd, you can use the following command to view the log:

```bash
$ sudo journalctl -eu nohang
```
See also `man journalctl`.


## Known problems

- Awful documentation

## Feedback

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.
