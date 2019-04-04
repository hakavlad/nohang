#!/usr/bin/env python3

# ms-monitor/

from memco import *
import time

# once or 1, log or 2, inplace or 3
mode = '3'

# период цикла печати
period = 0.2

# параметры визуализации
used = '$'
free = '~'
len_visual = 14

# нахождение и печать параметров, возвращает показатели и принимает показатели для нахождения дельт
def printer(old_list):

    mem_tup = mem_check_main()

    mem_available = mem_tup[0]
    swap_total = mem_tup[1]
    swap_free = mem_tup[2]

    tn = time.time()
    delta = tn - old_list[4]

    mem_busy = mem_total - mem_available
    swap_busy = swap_total - swap_free

    mem_swap_total = mem_total + swap_total
    mem_swap_free = mem_available + swap_free
    mem_swap_busy = mem_busy + swap_busy

    delta_mem =  (mem_busy - old_list[0]) / delta
    delta_swap =  (swap_busy - old_list[1]) / delta
    delta_all = (mem_swap_busy - old_list[2]) / delta

    if swap_total == 0:

#1###################################################################################

        # печать без свопа

            mem_visual = (
                used * round(mem_busy / mem_total * len_visual)
                ).ljust(len_visual, free)

            print(
                '           MEM'
                )

            print(
                'TOTAL {}'.format(
                    human(mem_total), 
                    )
                )
            print(
                'N/A   {} {}'.format(
                    human(mem_busy), 
                    percent(mem_busy / mem_total), 
                    )
                )
            print(
                'AVAIL {} {}'.format(
                    human(mem_available), 
                    percent(mem_available / mem_total), 
                    )
                )
            print(
                'DELTA {}'.format(
                    human(delta_mem), 
                    )
                )
            print(
                '{} {}'.format(
                    old_list[3], mem_visual
                    )
                )


#2###################################################################################

    else:

        with open('/proc/swaps') as file:
            swaps_list = file.readlines()[1:]

        zram_id_list = []

        disk_swap_size = 0
        disk_swap_used = 0
        zram_swap_size = 0
        zram_swap_used = 0

        for i in swaps_list:

            x = swaps_raw(i)

            if x[0].startswith('/dev/zram'):

                zram_swap_size += int(x[1])
                zram_swap_used += int(x[2])

                zram_id_list.append(x[0][9:])

            else:

                disk_swap_size += int(x[1])
                disk_swap_used += int(x[2])

        if zram_swap_size == 0:

#3###################################################################################

            # печать своп без зрам

            mem_visual = (
                used * round(mem_busy / mem_total * len_visual)
                ).ljust(len_visual, free)
            swap_visual = (
                used * round(swap_busy / swap_total * len_visual)
                ).ljust(len_visual, free)
            mem_swap_visual = (
                used * round(mem_swap_busy / mem_swap_total * len_visual)
                ).ljust(len_visual, free)

            print(
                '           MEM           SWAP         MEM + SWAP'
                )

            print(
                'TOTAL {}       {}       {}'.format(
                    human(mem_total), 
                    human(swap_total), 
                    human(mem_swap_total), 
                    )
                )
            print(
                'N/A   {} {} {} {} {} {}'.format(
                    human(mem_busy), 
                    percent(mem_busy / mem_total), 
                    human(swap_busy), 
                    percent(swap_busy / swap_total), 
                    human(mem_swap_busy), 
                    percent(mem_swap_busy / mem_swap_total), 
                    )
                )
            print(
                'AVAIL {} {} {} {} {} {}'.format(
                    human(mem_available), 
                    percent(mem_available / mem_total), 
                    human(swap_free), 
                    percent(swap_free / swap_total), 
                    human(mem_swap_free), 
                    percent(mem_swap_free / mem_swap_total), 
                    )
                )
            print(
                'DELTA {}       {}       {}'.format(
                    human(delta_mem), 
                    human(delta_swap), 
                    human(delta_all)
                    )
                )
            print(
                '{} {} {} {}'.format(
                    old_list[3], 
                    mem_visual, 
                    swap_visual, 
                    mem_swap_visual, 
                    )
                )
            print()

#4###################################################################################

        else:

            # суммируем показатели из всех свопов в зрам

            disksize_sum = 0
            mem_used_total_sum = 0

            for i in zram_id_list:
                s = zram_stat(i) # кортеж из disksize и mem_used_total для данного zram id
                disksize_sum += int(s[0])
                mem_used_total_sum += int(s[1])

            # находим показатели для ZRAM
            full = disksize_sum * k + mem_used_total_sum
            profit = zram_swap_used - (full / 1024)
            cr_real = round(zram_swap_used * 1024 / mem_used_total_sum, 2)

#5###################################################################################

            # печать своп + зрам

            mem_visual = (
                used * round(mem_busy / mem_total * len_visual)
                ).ljust(len_visual, free)
            swap_visual = (
                used * round(swap_busy / swap_total * len_visual)
                ).ljust(len_visual, free)
            mem_swap_visual = (
                used * round(mem_swap_busy / mem_swap_total * len_visual)
                ).ljust(len_visual, free)
            zram_visual = (
                used * round(full / 1024 / mem_total * 18)
                ).ljust(18, free)

            print(
                '           MEM           SWAP         MEM + SWAP          ZRAM SWAP'
                )

            print(
                'TOTAL {}       {}       {}        PROFIT {} M'.format(
                    human(mem_total), 
                    human(swap_total), 
                    human(mem_swap_total), 
                    human(profit)
                    )
                )
            print(
                'N/A   {} {} {} {} {} {}  CR      {}'.format(
                    human(mem_busy), 
                    percent(mem_busy / mem_total), 
                    human(swap_busy), 
                    percent(swap_busy / swap_total), 
                    human(mem_swap_busy), 
                    percent(mem_swap_busy / mem_swap_total), 
                    str(cr_real).rjust(7, ' ')
                    )
                )
            print(
                'AVAIL {} {} {} {} {} {}  FULL/MT   {} %'.format(
                    human(mem_available), 
                    percent(mem_available / mem_total), 
                    human(swap_free), 
                    percent(swap_free / swap_total), 
                    human(mem_swap_free), 
                    percent(mem_swap_free / mem_swap_total), 
                    percent(full / 1024 / mem_total)
                    )
                )
            print(
                'DELTA {}       {}       {}'.format(
                    human(delta_mem), 
                    human(delta_swap), 
                    human(delta_all)
                    )
                )
            print(
                '{} {} {} {} {}'.format(
                    old_list[3], 
                    mem_visual, 
                    swap_visual, 
                    mem_swap_visual, 
                    zram_visual
                    )
                )
            print()

#6###################################################################################

        # печать по партициям

        print('FILENAME                       USED                  SIZE     PRIORITY')

        for i in swaps_list:
            x = swaps_raw(i)
            print(
                '{} {} G {} %    {} G {}'.format(
                    str(x[0]).ljust(26, ' '), 
                    human(x[2]), 
                    percent(x[2] / x[1]), human(x[1]), 
                    str(x[3]).rjust(10, ' ')
                    )
                )

    return [mem_busy, swap_busy, mem_swap_busy, movie_dict[(old_list[3])], tn]






try:

    delta = [0, 0, 0, '+----', 0]

    if mode == 'log' or mode == '2':

        while True:
            delta = printer(delta)
            sleep(period)

    elif mode == 'inplace' or mode == '3':

        while True:
            print("\033c")
            delta = printer(delta)
            sleep(period)

    else:

        delta = printer(delta)

except KeyboardInterrupt:
    print()
    exit()

