
The No Hang Daemon
==================

`Nohang` is a highly flexible full-featured daemon for Linux that correctly prevents out of memory.

### What is the problem?

OOM killer doesn't prevent OOM conditions.

### Solution

Use of [earlyoom](https://github.com/rfjakob/earlyoom) or nohang, but nohang is more featured.

### Demo

`while true; do tail /dev/zero; done` with nohang https://youtu.be/DefJBaKD7C8

### Features

- convenient configuration with a config file with well-commented parameters (38 parameters in config)
- `SIGKILL` and `SIGTERM` as signals that can be sent to the victim
- `zram` support (`mem_used_total` as trigger)
- desktop notifications of attempts to prevent OOM
- low memory notifications
- black, white, prefer, avoid lists via regex
- possibility of restarting processes via command like `systemctl restart something` if the process is selected as a victim
- possibility of decrease `oom_score_adj`
- prevention of killing innocent victim via `oom_score_min`, `min_delay_after_sigterm` and `min_delay_after_sigkill` parameters
- customizable intensity of monitoring

### An exaple of stdout

```
2018-06-30 Sat 19:42:56
  MemAvailable (0 MiB, 0.0 %) < mem_min_sigterm (470 MiB, 8.0 %)
  SwapFree (457 MiB, 7.8 %) < swap_min_sigterm (470 MiB, 8.0 %)
  Preventing OOM: trying to send the SIGTERM signal to tail,
  Pid: 14884, Badness: 866, VmRSS: 5181 MiB, VmSwap: 4983 MiB
  Success
```

### Requirements

- Linux 3.14+
- Python 3.4+

### Memory and CPU usage

- VmRSS is about 12 MiB
- CPU usage depends on the level of available memory

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

Default path to config after installation is
```
/etc/nohang/nohang.conf 
```

Read config and edit values before the start of the program. Execute `sudo systemctl restart nohang` for apply changes.

### Feedback

Please, create [issues](https://github.com/hakavlad/nohang/issues).

