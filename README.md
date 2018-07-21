
# Nohang

Nohang is a highly configurable daemon for Linux which is able to correctly prevent [out of memory](https://en.wikipedia.org/wiki/Out_of_memory) (OOM) conditions and save [disk cache](https://en.wikipedia.org/wiki/Page_cache).

## What is the problem?

OOM killer doesn't prevent OOM conditions. And OOM conditions may cause [freezes](https://en.wikipedia.org/wiki/Hang_(computing)), [livelocks](https://en.wikipedia.org/wiki/Deadlock#Livelock), drop caches and killing (via SIGKILL) multiple processes instead of terminating (via SIGTERM) one process.

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

- convenient configuration with a well commented config file (there are 35 parameters in the config)
- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- `zram` support (`mem_used_total` as a trigger)
- customizable intensity of monitoring
- desktop notifications: results of preventings OOM and low memory warnings
- prefer and avoid lists via regex matching
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- look at the [config](https://github.com/hakavlad/nohang/blob/master/nohang.conf) to find more

## Demo

[Video](https://youtu.be/DefJBaKD7C8): nohang prevents OOM after the command `while true; do tail /dev/zero; done` has been executed.

## Requirements

- `Linux 3.14+` and `Python 3.4+` for basic use
- `libnotify` (Fedora, Arch) or `libnotify-bin` (Debian, Ubuntu) to show GUI notifications

## Memory and CPU usage

- VmRSS is 10 — 14 MiB depending on the settings
- CPU usage depends on the level of available memory (the frequency of memory status checks increases as the amount of available memory decreases) and monitoring intensity (can be changed by user via config)

## Status

The program is unstable and some fixes are required before the first stable version will be released (need documentation, translation, review and some optimisation).

## Download

```bash
$ git clone https://github.com/hakavlad/nohang.git
$ cd nohang
```

## Installation and start for systemd users

```bash
$ sudo ./install.sh
```

## Purge

```bash
$ sudo ./purge.sh
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
2. The frequency of checking the level of available memory (and CPU usage)
3. The prevention of killing innocent victims
4. Impact on the badness of processes via matching their names with regular expressions
5. The execution of a specific command instead of sending the SIGTERM signal
6. GUI notifications:
   - results of preventing OOM
   - low memory warnings
7. Preventing the slowing down of the program
8. Output verbosity

Just read the description of the parameters and edit the values. Please restart nohang to apply changes. Default path to the config arter installing via `./install.sh` is `/etc/nohang/nohang.conf`.

## Feedback

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.
