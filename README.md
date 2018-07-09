
The No Hang Daemon
==================

`Nohang` is a highly configurable daemon for Linux which is able to correctly prevent out of memory conditions.

### What is the problem?

OOM killer doesn't prevent OOM conditions.

### Solutions

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is the simple OOM preventer written in C
- Use of nohang. This is advanced OOM preventer written in Python.

### Some features

- convenient configuration with a well commented config file (there are 38 parameters in the config)
- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- `zram` support (`mem_used_total` as a trigger)
- customizable intensity of monitoring
- desktop notifications: results of preventings OOM and low memory warnings
- black, white, prefer, avoid lists via regex
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- look at the [config](https://github.com/hakavlad/nohang/blob/master/nohang.conf) to find more

### Demo

[Video](https://youtu.be/DefJBaKD7C8): nohang prevents OOM after the command `while true; do tail /dev/zero; done` has been executed.


### An example of output

```
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
```

### Requirements

- Linux 3.14+
- Python 3.4+

### Memory and CPU usage

- VmRSS is 10 - 14 MiB depending on the settings
- CPU usage depends on the level of available memory (the frequency of memory status checks increases as the amount of available memory decreases) and monitoring intensity (can be changed by user via config)

### Status

The program is unstable and some fixes are requird before the first stable version will be released. (Need documentation, translation, review.)

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
./nohang -h
usage: nohang [-h] [-c CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        path to the config file, default values:
                        ./nohang.conf, /etc/nohang/nohang.conf
```

### How to configure nohang

Just read the config and edit the values. Run the command `sudo systemctl restart nohang` to apply the changes.

### Feedback

Please create [issues](https://github.com/hakavlad/nohang/issues).

