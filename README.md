
The No Hang Daemon
==================

`Nohang` is a highly configurable daemon for Linux which is able to correctly prevent out of memory conditions.

### What is the problem?

OOM killer doesn't prevent OOM conditions.

### Solutions

- Use of [earlyoom](https://github.com/rfjakob/earlyoom). This is a simple OOM preventer written in C.
- Use of nohang. This is an advanced OOM preventer written in Python.

### Some features

- convenient configuration with a well commented config file (there are 35 parameters in the config)
- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- `zram` support (`mem_used_total` as a trigger)
- customizable intensity of monitoring
- desktop notifications: results of preventings OOM and low memory warnings
- prefer and avoid lists via regex matching
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- look at the [config](https://github.com/hakavlad/nohang/blob/master/nohang.conf) to find more

### Demo

[Video](https://youtu.be/DefJBaKD7C8): nohang prevents OOM after the command `while true; do tail /dev/zero; done` has been executed.


### An example of output

```
  MemAvailable (0 MiB, 0.0 %) < mem_min_sigterm (588 MiB, 10.0 %)
  SwapFree (943 MiB, 8.8 %) < swap_min_sigterm (1076 MiB, 10.0 %)
  Preventing OOM: trying to send the SIGTERM signal to tail,
  Pid: 14636, Badness: 777, VmRSS: 4446 MiB, VmSwap: 8510 MiB
  Success
```

### Requirements

- `Linux 3.14+` (because the MemAvailable parameter appeared in /proc/meminfo since kernel version 3.14) and `Python 3.4+` (compatibility with earlier versions was not tested) for basic usage
- `libnotify` (Fedora, Arch) or `libnotify-bin` (Debian, Ubuntu) for desktop notifications and `sudo` for desktop notifications as root

### Memory and CPU usage

- VmRSS is 10 — 13.5 MiB depending on the settings
- CPU usage depends on the level of available memory (the frequency of memory status checks increases as the amount of available memory decreases) and monitoring intensity (can be changed by user via config)

### Status

The program is unstable and some fixes are required before the first stable version will be released (need documentation, translation, review and some optimisation).

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

The program can be configured by editing the [config file](https://github.com/hakavlad/nohang/blob/master/nohang.conf). The configuration includes the following sections:

- Thresholds for sending signals to victims
- Intensity of monitoring (and CPU usage)
- Prevention of killing innocent victims
- Avoid and prefer victim names via regex matching
- Execute the command instead of sending the SIGTERM signal
- GUI notifications: results of preventing OOM and low memory warnings
- Self-defense and preventing slowing down the program
- Output verbosity

Just read the description of the parameters and edit the values. Please restart nohang to apply changes. Default path to the config arter installing via `./install.sh` is `/etc/nohang/nohang.conf`.

### Feedback

Please create [issues](https://github.com/hakavlad/nohang/issues). Use cases, feature requests and any questions are welcome.

