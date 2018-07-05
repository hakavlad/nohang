
The No Hang Daemon
==================

`Nohang` is a highly flexible full-featured daemon for Linux which is able to correctly prevent out of memory conditions.

### What is the problem?

OOM killer doesn't prevent OOM conditions.

### Solution

Use of [earlyoom](https://github.com/rfjakob/earlyoom) or nohang, but nohang is more featured.

### Demo

[Video](https://youtu.be/DefJBaKD7C8): nohang prevents OOM after command `while true; do tail /dev/zero; done` has been executed.

### Some features

- convenient configuration with a config file with well-commented parameters (38 parameters in config)
- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- `zram` support (`mem_used_total` as trigger)
- customizable intensity of monitoring
- desktop notifications: results of preventings OOM and low memory warnings
- black, white, prefer, avoid lists via regex
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- possibility of decrease `oom_score_adj` before find victim (relevant for chromium)
- prevention of killing innocent victim via `oom_score_min`, `min_delay_after_sigterm` and `min_delay_after_sigkill` parameters
- look at the [config](https://github.com/hakavlad/nohang/blob/master/nohang.conf) to find more features

### An exaple of output

```
MemAvail: 2975 M, 50.6 % | SwapFree: 10758 M, 100.0 %
MemAvail: 2976 M, 50.6 % | SwapFree: 10758 M, 100.0 %
MemAvail:    0 M,  0.0 % | SwapFree: 10281 M,  95.6 %
MemAvail:    0 M,  0.0 % | SwapFree:  9918 M,  92.2 %
MemAvail:    0 M,  0.0 % | SwapFree:  8659 M,  80.5 %
MemAvail:    0 M,  0.0 % | SwapFree:  7235 M,  67.3 %
MemAvail:   19 M,  0.3 % | SwapFree:  6851 M,  63.7 %
MemAvail:    0 M,  0.0 % | SwapFree:  5780 M,  53.7 %
MemAvail:    0 M,  0.0 % | SwapFree:  5008 M,  46.6 %
MemAvail:    0 M,  0.0 % | SwapFree:  4199 M,  39.0 %
MemAvail:    0 M,  0.0 % | SwapFree:  3502 M,  32.6 %
MemAvail:    0 M,  0.0 % | SwapFree:  2929 M,  27.2 %
MemAvail:    0 M,  0.0 % | SwapFree:  2446 M,  22.7 %
MemAvail:    0 M,  0.0 % | SwapFree:  2093 M,  19.5 %
MemAvail:    0 M,  0.0 % | SwapFree:  1573 M,  14.6 %
MemAvail:    0 M,  0.0 % | SwapFree:  1320 M,  12.3 %
MemAvail:    0 M,  0.0 % | SwapFree:  1117 M,  10.4 %
MemAvail:    0 M,  0.0 % | SwapFree:   943 M,   8.8 %

2018-07-06 Fri 03:04:37
  MemAvailable (0 MiB, 0.0 %) < mem_min_sigterm (588 MiB, 10.0 %)
  SwapFree (943 MiB, 8.8 %) < swap_min_sigterm (1076 MiB, 10.0 %)
  Preventing OOM: trying to send the SIGTERM signal to tail,
  Pid: 14636, Badness: 777, VmRSS: 4446 MiB, VmSwap: 8510 MiB
  Success
MemAvail:  173 M,  2.9 % | SwapFree:  3363 M,  31.3 %
MemAvail: 4700 M, 80.0 % | SwapFree:  8986 M,  83.5 %
MemAvail: 4668 M, 79.4 % | SwapFree:  8997 M,  83.6 %
MemAvail: 4610 M, 78.5 % | SwapFree:  9024 M,  83.9 %
MemAvail: 4533 M, 77.2 % | SwapFree:  9037 M,  84.0 %

```

### Requirements

- Linux 3.14+
- Python 3.4+

### Memory and CPU usage

- VmRSS is about 12 MiB
- CPU usage depends on the level of available memory (the frequency of memory status checks increases as the amount of available memory decreases) and monitorong intensity (can be changed by user via config)

### Download
```bash
git clone https://github.com/hakavlad/nohang.git
cd nohang
```

### Installation and start for systemd users

```bash
sudo ./install.sh
```
### Purge

```bash
sudo ./purge.sh
```

### Command line options

```
./nohang --help
usage: nohang [-h] [-c CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        path to the config file, default values:
                        ./nohang.conf, /etc/nohang/nohang.conf
```

### How to configure nohang

Default path to config after installation is `/etc/nohang/nohang.conf`. The config is well commented. Read config and edit values before the start of the program.  Execute `sudo systemctl restart nohang` for apply changes.

### Feedback

Please, create [issues](https://github.com/hakavlad/nohang/issues).

