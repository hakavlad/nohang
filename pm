#!/usr/bin/env python3

from ctypes import CDLL
from time import sleep
from sys import argv, exit
import os
import logging


"""
--target /system.slice
--period 2
--log-file ./psi.log
"""


separate_log = True
log_file = './psi-monitor.log'

period = 2


cpu_file = "./cpu"
memory_file = "./memory"
io_file = "./io"

"""

"""


#

try:
    target = argv[1]  # '.'
    print('Set target to {}'.format(argv[1]))
except IndexError:
    print('Set target to SYSTEM_WIDE to monitor /proc/pressure')
    target = 'SYSTEM_WIDE'

# target = 'SYSTEM_WIDE'


if target == 'SYSTEM_WIDE':
    cpu_file = "/proc/pressure/cpu"
    memory_file = "/proc/pressure/memory"
    io_file = "/proc/pressure/io"
else:
    cpu_file = target + "/cpu.pressure"
    memory_file = target + "/memory.pressure"
    io_file = target + "/io.pressure"

###############################################################################


def mlockall():

    MCL_CURRENT = 1
    MCL_FUTURE = 2
    MCL_ONFAULT = 4

    libc = CDLL('libc.so.6', use_errno=True)

    result = libc.mlockall(
        MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT
    )
    if result != 0:
        result = libc.mlockall(
            MCL_CURRENT | MCL_FUTURE
        )
        if result != 0:
            pass
        else:
            pass
    else:
        pass


def psi_file_mem_to_metrics(psi_path):

    with open(psi_path) as f:
        psi_list = f.readlines()
    # print(psi_list)
    some_list, full_list = psi_list[0].split(' '), psi_list[1].split(' ')
    # print(some_list, full_list)
    some_avg10 = some_list[1].split('=')[1]
    some_avg60 = some_list[2].split('=')[1]
    some_avg300 = some_list[3].split('=')[1]

    full_avg10 = full_list[1].split('=')[1]
    full_avg60 = full_list[2].split('=')[1]
    full_avg300 = full_list[3].split('=')[1]

    return (some_avg10, some_avg60, some_avg300,
            full_avg10, full_avg60, full_avg300)


def psi_file_cpu_to_metrics(psi_path):

    with open(psi_path) as f:
        psi_list = f.readlines()
    # print(psi_list)
    some_list = psi_list[0].split(' ')
    # print(some_list, full_list)
    some_avg10 = some_list[1].split('=')[1]
    some_avg60 = some_list[2].split('=')[1]
    some_avg300 = some_list[3].split('=')[1]

    return (some_avg10, some_avg60, some_avg300)


def log(*msg):
    """
    """
    print(*msg)
    if separate_log:
        logging.info(*msg)


###############################################################################


logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s: %(message)s")


mlockall()





try:
    (c_some_avg10, c_some_avg60, c_some_avg300
     ) = psi_file_cpu_to_metrics(cpu_file)

    (m_some_avg10, m_some_avg60, m_some_avg300,
     m_full_avg10, m_full_avg60, m_full_avg300
     ) = psi_file_mem_to_metrics(memory_file)

    (i_some_avg10, i_some_avg60, i_some_avg300,
     i_full_avg10, i_full_avg60, i_full_avg300
     ) = psi_file_mem_to_metrics(io_file)
except Exception:
    log('Cannot open pressure files')
    log('Exit')
    exit()





"""
if not os.path.exists('/proc/pressure'):
    print('PSI path does not exist. Exit.')
    exit()
"""


log('Starting psi-monitor, target: {}, period: {}'.format(target, period))
log('----------------------------------------------------------------------'
    '--------------------------------------------')
log(' some cpu pressure   || some memory pressure | full memory pressure ||'
    '  some io pressure    |  full io pressure')
log('---------------------||----------------------|----------------------||'
    '----------------------|---------------------')
log(' avg10  avg60 avg300 ||  avg10  avg60 avg300 |  avg10  avg60 avg300 ||'
    '  avg10  avg60 avg300 |  avg10  avg60 avg300')
log('------ ------ ------ || ------ ------ ------ | ------ ------ ------ ||'
    ' ------ ------ ------ | ------ ------ ------')


while True:

    (c_some_avg10, c_some_avg60, c_some_avg300
     ) = psi_file_cpu_to_metrics(cpu_file)

    (m_some_avg10, m_some_avg60, m_some_avg300,
     m_full_avg10, m_full_avg60, m_full_avg300
     ) = psi_file_mem_to_metrics(memory_file)

    (i_some_avg10, i_some_avg60, i_some_avg300,
     i_full_avg10, i_full_avg60, i_full_avg300
     ) = psi_file_mem_to_metrics(io_file)

    log('{} {} {} || {} {} {} | {} {} {} || {} {} {} | {} {} {}'.format(

        c_some_avg10.rjust(6),
        c_some_avg60.rjust(6),
        c_some_avg300.rjust(6),

        m_some_avg10.rjust(6),
        m_some_avg60.rjust(6),
        m_some_avg300.rjust(6),
        m_full_avg10.rjust(6),
        m_full_avg60.rjust(6),
        m_full_avg300.rjust(6),

        i_some_avg10.rjust(6),
        i_some_avg60.rjust(6),
        i_some_avg300.rjust(6),
        i_full_avg10.rjust(6),
        i_full_avg60.rjust(6),
        i_full_avg300.rjust(6)

    ))

    try:
        sleep(period)
    except KeyboardInterrupt:
        log('Exit')
        exit()
