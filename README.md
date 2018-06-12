
The No Hang Daemon
==================

`Nohang` - аналог [earlyoom](https://github.com/rfjakob/earlyoom) с поддержкой `zram` и `SIGTERM`. При дефиците доступной памяти `nohang` корректно завершает наиболее прожорливые процессы сигналом `SIGTERM` или `SIGKILL`, тем самым препятствуя зависанию, а также избыточному убийству процессов ядерным `OOM killer`'ом.

### Зачем это нужно?

Затем, что этот демон реализует востребованный функционал. Судите сами:

"А можете рассказать, как сделать OOM Killer более агрессивным? Например, в ситуации, когда приложение открыло/создало множество мелких файлов и держит их в памяти, при внезапной нехватке памяти ядро пытается высвободить эти файловые страницы, что вешает систему намертво со 100%-м дисковым I/O на несколько (десятков) минут. А ведь зачастую гораздо проще просто грохнуть само приложение с дальнешим его перезапуском."
https://habr.com/company/flant/blog/348324/#comment_10659202

"Говно какое-то этот оом-киллер, нихрена не работает.
Но чтобы это нормально работало, я думаю, нужен какой-то демон, который постоянно мониторит потребление памяти и прибивает тот процесс, который резко начинает набирать обороты. В общем сам этот демон будет проц грузить, хотя можно ограничить процессы, которые он будет проверять только пользовательскими процессами, добавить black-white list ну и настраиваемый интервал проверки.
Короче если кто-то напишет будет круто."
https://www.linux.org.ru/forum/general/13074074#comment-13074864

"Сегодня скормил пикарду 100-дисковое издание Бетховена и тот сожрал 16 гб памяти вместе с 8 гб zram (коэффициент сжатия был 3.5). Со swappiness 100 zram начал наполняться на 80% памяти, а когда сам достиг 80%, то сжатие продолжилось с новой силой и полной загрузкой ядра. По окончанию банкета система встала колом, потому что киллер опять сцуко не пришел (ждал 10 минут)."
https://www.linux.org.ru/forum/general/13074074/page1?lastmod=1481740875388#comment-13077387

"Система таки становится неюзабельной если продолжать стараться забивать ее вплоть до исчерпания RAM+ZRAM. Ничего неудивительного, памяти то нет. Но в случае с дисковым свопом ты начинаешь заранее замечать что дело плохо. По ощущениям ZRAM не тормозит вообще, потому ты ничего не подозреваешь до часа икс и система становится колом."
https://www.linux.org.ru/forum/talks/12684213?lastmod=1466676523241#comment-12684906

"И IRL ты никогда не знаешь, в какой момент момент твои данные перестанут умещаться в оперативку. Потому zram -- удел embedded систем, где это может быть детерминировано."
https://2ch.hk/s/res/2310304.html#2311483, https://archive.li/idixk

`Nohang` позволяет избавиться от перечисленных выше проблем, корректно завершая наиболее прожорливые процессы (с наибольшим oom_score) сигналом `SIGTERM` (или `SIGKILL`) не дожидаясь когда система "встанет колом". `Nohang` позволяет не бояться зависаний при использовании `zram`.

### Зачем нужен nohang, если уже есть earlyoom?

- `earlyoom` завершает (точнее убивает) процессы исключительно с помощью сигнала `SIGKILL`, в то время как `nohang` дает возможность сначала отправлять `SIGTERM`, и только если процесс не реагирует на `SIGTERM` - отправляется сигнал `SIGKILL`.
- `earlyoom` не поддерживает работу со `zram` и не реагирует на общую долю `zram` в памяти (`mem_used_total`). Это может привести к тому, что система все также встанет колом, как если бы `earlyoom` и не было (если `disksize` большой, а энтропия сжимаемых данных велика). `Nohang` позволяет избавиться от этой проблемы. По умолчанию если доля `zram` достигнет 60% памяти - будет отправлен сигнал `SIGTERM` процессу с наибольшим `oom_score`.

### Особенности
- задача - препятствовать зависанию системы при нехватке доступной памяти, а также корректное завершение процессов с целью увеличения объема доступной памяти
- демон на Python 3, VmRSS не более 13 MiB
- требуется ядро `Linux 3.14` или новее
- периодически проверяет объем доступной памяти, при дефиците памяти отправляет `SIGKILL` или `SIGTERM` процессу с наибольшим `oom_score`
- поддержка работы со `zram`, возможность реакции на `mem_used_total`
- удобный конфиг с возможностью тонкой настройки
- аргументы командной строки -h/--help и -c/--config
- возможность раздельного задания уровней `MemAvailable`, `SwapFree`, `mem_used_total` для отпраки `SIGTERM` и `SIGKILL`, возможность задания в процентах (%), кибибайтах (K), мебибайтах (M), гибибайтах (G)
- возможность снижения `oom_score_adj` процессов, чьи `oom_score_adj` завышены (актуально для `chromium`)
- лучший алгоритм выбора периодов между проверками доступной памяти: при больших объемах доступной памяти нет смысла проверять ее состояние часто, поэтому период проверки уменьшается по мере уменьшения размера доступной памяти
- интенсивность мониторинга можно гибко настраивать (параметры конфига `rate_mem`, `rate_swap`, `rate_zram`)
- по умолчанию память заблокирована с помощью `mlockall()` для предотвращения своппинга процесса
- по умолчанию высокий приоритет процесса `nice -20`, может регулироваться через конфиг
- предотвращение самоубийства с помощью `self_oom_score_adj = -1000`
- возможность задания `oom_score_min` для предотвращения убийства невиновных
- verbosity: опциональность печати параметров конфига при старте программы, опциональность печати результатов проверки памяти
- возможность предотвращения избыточного убийства процессов с помощью задания миниального `oom_score` для убиваемых процессов и установка минимальной задержки просле отправки сигналов (параметры конфига `min_delay_after_sigkill` и `min_delay_after_sigterm`)
- наличие `man` страницы
- наличие установщика для пользователей `systemd`
- протестировано на `Debian 9 x86_64`, `Debian 8 i386`, `Fedora 28 x86_64`
- пример вывода с отчетом об успешной отпраке сигнала:
```
MemAvail:     0M   0.0%, SwapFree:   706M   6.0%, MemUsedZram:   357M   6.1%
MemAvail:     0M   0.0%, SwapFree:   411M   3.5%, MemUsedZram:   362M   6.2%
+ MemAvail (0M, 0.0%) < mem_min_sigterm (235M, 4.0%)
  SwapFree (411M, 3.5%) < swap_min_sigterm (470M, 4.0%)
  Try to send signal 15 to python3, Pid 3930, oom_score 903
  Success
MemAvail:   107M   1.8%, SwapFree:  3461M  29.5%, MemUsedZram:   311M   5.3%
MemAvail:  5159M  87.8%, SwapFree: 11311M  96.3%, MemUsedZram:   186M   3.2%
```

### Установка и удаление для пользователей systemd
```bash
git clone https://github.com/hakavlad/nohang.git
cd nohang
```
Установка
```bash
sudo ./install.sh
```
Удаление вместе с конфигом
```bash
sudo ./purge.sh
```
Удалить всё, кроме конфига
```bash
sudo ./uninstall.sh
```

### Настройка
`Nohang` настраивается с помощью [конфига](https://github.com/hakavlad/nohang/blob/master/nohang.conf), расположенного после установки 
по адресу
```
/etc/nohang/nohang.conf
```
К опциям прилагается описание. Отредактируйте значения параметров в соответствии с вашими предпочтениями и перезапустите сервис командой `sudo systemctl restart nohang`.


### Почему Python, а не C?

- Скорость разработки на Python значительно выше. Больше фич за приемлемое время.
- Практически единственный минус Python - большее потребление памяти процессом.


### Известные баги
В рабочем алгоритме известных нет, если найдете - пишите в [Issues](https://github.com/hakavlad/nohang/issues).

