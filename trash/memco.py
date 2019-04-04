# memdler common

import os
import glob
import signal
import subprocess
from glob import glob
from time import sleep


# k = mem_total_used / (zram own size)
k = 0.0042


def meminfo():

    # получаем сырой mem_list
    with open('/proc/meminfo') as file:
        mem_list = file.readlines()

    # получаем список названий позиций: MemTotal etc
    mem_list_names = []
    for s in mem_list:
        mem_list_names.append(s.split(':')[0])

    # ищем MemAvailable, обрабатываем исключение
    try:
        mem_available_index = mem_list_names.index('MemAvailable')
    except ValueError:
        print("Your Linux kernel is too old (3.14+ requied), bye!")
        # исключение для ядер < 3.14, не определяющих MemAvailable
        exit()

    # ищем позиции SwapTotl и SwapFree
    swap_total_index = mem_list_names.index('SwapTotal')
    swap_free_index = mem_list_names.index('SwapFree')

    buffers_index = mem_list_names.index('Buffers')
    cached_index = mem_list_names.index('Cached')
    active_index = mem_list_names.index('Active')
    inactive_index = mem_list_names.index('Inactive')
    shmem_index = mem_list_names.index('Shmem')

    # ищем значение MemTotal в KiB
    mem_total = int(mem_list[0].split(':')[1].split(' ')[-2])

    return mem_total, mem_available_index, swap_total_index, swap_free_index, buffers_index, cached_index, active_index, inactive_index, shmem_index


meminfo_tuple = meminfo()

mem_total = meminfo_tuple[0]
mem_available_index = meminfo_tuple[1]
swap_total_index = meminfo_tuple[2]
swap_free_index = meminfo_tuple[3]

buffers_index = meminfo_tuple[4]
cached_index = meminfo_tuple[5]
active_index = meminfo_tuple[6]
inactive_index = meminfo_tuple[7]
shmem_index = meminfo_tuple[8]


def meminfo_num(mem_list, index):
    return int(mem_list[index].split(':')[1].split(' ')[-2])


# выдача основных показателей meminfo, KiB
def mem_check_main():

    with open('/proc/meminfo') as file:
        mem_list = file.readlines()

    mem_available = meminfo_num(mem_list, mem_available_index)
    swap_total = meminfo_num(mem_list, swap_total_index)
    swap_free = meminfo_num(mem_list, swap_free_index)

    return mem_available, swap_total, swap_free


# читать не весь файл, а нужный срез от 0 до 20, например
def mem_check_full():

    with open('/proc/meminfo') as file:
        mem_list = file.readlines()

    mem_available = meminfo_num(mem_list, mem_available_index)
    swap_total = meminfo_num(mem_list, swap_total_index)
    swap_free = meminfo_num(mem_list, swap_free_index)

    buffers = meminfo_num(mem_list, buffers_index)
    cached = meminfo_num(mem_list, cached_index)
    active = meminfo_num(mem_list, active_index)
    inactive = meminfo_num(mem_list, inactive_index)
    shmem = meminfo_num(mem_list, shmem_index)

    return mem_available, swap_total, swap_free, buffers, cached, active, inactive, shmem


# чек общей доступной, для lim2avail
def total_mem_available():

    with open('/proc/meminfo') as file:
        mem_list = file.readlines()

    mem_available = meminfo_num(mem_list, mem_available_index)
    swap_free = meminfo_num(mem_list, swap_free_index)

    return round((swap_free + mem_available) / 1024) # MiB


# добитие байтами рандома
def terminal():
    ex = []
    while True:
        try:
            ex.append(os.urandom(1))
        except MemoryError:
            continue


# перевод дроби в проценты
def percent(num):
    a = str(round(num * 100, 1)).split('.')
    a0 = a[0].rjust(3, ' ')
    a1 = a[1]
    return '{}.{}'.format(a0, a1)


def human(num):
    return str(round(num / 1024.0)).rjust(8, ' ')



# B -> GiB
def humanz(num):
    a = str(round(num / 1073741824, 3))
    a0 = a.split('.')[0].rjust(4, ' ')
    a1 = a.split('.')[1]
    if len(a1) == 1:
        a1 += '00'
    if len(a1) == 2:
        a1 += '0'
    return '{}.{}'.format(a0, a1)



movie_dict = {
    '+----': '-+---', 
    '-+---': '--+--', 
    '--+--': '---+-', 
    '---+-': '----+', 
    '----+': '+----'
        }


def config_parser(config):
    if os.path.exists(config):
        try:
            with open(config) as f:
                name_value_dict = dict()
                for  line in f:
                    a = line.startswith('#')
                    b = line.startswith('\n')
                    c = line.startswith('\t')
                    d = line.startswith(' ')
                    if not a and not b and not c and not d: 
                        a = line.split('=')
                        name_value_dict[a[0].strip()] = a[1].strip()
            return name_value_dict
        except PermissionError:
            print('config: permission error')
    else:
        print('config does not exists')




def swaps_raw(part_string):
    '''анализ строки свопс, возврат кортежа с значениями'''
    part_string_list = part_string.split('\t')
    part_name = part_string_list[0].split(' ')[0]

    part_size = int(part_string_list[-3])
    part_used = int(part_string_list[-2])
    part_prio = int(part_string_list[-1])

    return part_name, part_size, part_used, part_prio



# возвращает disksize и mem_used_total по zram id
def zram_stat(zram_id):
    with open('/sys/block/zram' + zram_id + '/disksize') as file:
        disksize = file.readlines()[0][:-1]
    if os.path.exists('/sys/block/zram' + zram_id + '/mm_stat'):
        with open('/sys/block/zram' + zram_id + '/mm_stat') as file:
            mm_stat = file.readlines()[0][:-1].split(' ')
        mm_stat_list = []
        for i in mm_stat:
            if i != '':
                mm_stat_list.append(i)
        mem_used_total = mm_stat_list[2]
    else:
        with open('/sys/block/zram' + zram_id + '/mem_used_total') as file:
            mem_used_total = file.readlines()[0][:-1]
    return disksize, mem_used_total








# termer(signal.SIGKILL)
# process terminator
# функция поиска жиробаса и его убийства
def terminator(signal):

    subdirs = glob('/proc/*/')
    subdirs.remove('/proc/self/')
    subdirs.remove('/proc/thread-self/')

    pid_list = []
    name_list = []
    oom_score_list = []

    for subdir in subdirs:

        try:

            with open(subdir + 'status') as file:
                status = file.readlines()

            pid_list.append(status[5].split(':')[1][1:-1])
            name_list.append(status[0].split(':')[1][1:-1])

        except Exception:
            pass

        try:

            with open(subdir + 'oom_score') as file:
                oom_score = file.readlines()

            oom_score_list.append(int(oom_score[0][0:-1]))

        except Exception:
            pass

    max_oom_score = sorted(oom_score_list)[-1]
    n = oom_score_list.index(max_oom_score)
    s = sorted(oom_score_list)
    s.reverse()

    if signal == signal.SIGTERM:
        print('\nTRY TO TERM {}, Pid {}\n'.format(name_list[n], pid_list[n]))
    else:
        print('\nTRY TO KILL {}, Pid {}\n'.format(name_list[n], pid_list[n]))

    try:
        os.kill(int(pid_list[n]), signal)
    except ProcessLookupError:
        print('No such process')




def selfterm():
    os.kill(os.getpid(), signal.SIGTERM)





