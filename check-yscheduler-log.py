# -*- coding: utf-8 -*-
# If an error is detected, an alert file will be created in
# /var/log/paas/alert/. For example if "gkt job error" is detected,
# a file /var/log/paas/alert/gkt will be created.
#

import os
import logging
from logging.handlers import RotatingFileHandler
import time
import re

YSCH_LOG_FILE='/dianyi/log/yscheduler-web/app.log'
MY_LOG_FILE='/var/log/paas/yscheduler-zabbix.log'
ALERT_DIR='/var/log/paas/alert'
PID_FILE = '/var/run/paas/yscheduler_log_monitor_pid'

def save_pid():
    pid = os.getpid()
    file_obj = file(PID_FILE, 'w')
    file_obj.write(str(pid))
    file_obj.close()

def get_logger():
    logging.basicConfig(format = '[%(levelname)s] [%(asctime)s] %(message)s',
                        level = logging.INFO)
    handlers = [
        RotatingFileHandler(MY_LOG_FILE,
                mode='a',
                maxBytes = 10 * 1024 * 1024,
                backupCount = 10),
    ]               
    fmt = logging.Formatter('[%(levelname)s] [%(asctime)s] %(message)s')
    logger = logging.getLogger()
    for handler in handlers:
        handler.setFormatter(fmt)
        handler.setLevel(logging.INFO)
        logger.addHandler(handler)
    return logger

LOG = get_logger()

def notify_error(project):
    alert_file = '{}/{}'.format(ALERT_DIR, project)
    if not os.path.exists(alert_file):
        open(alert_file, 'w')

def task_error_handler(msg):
    m = re.search('task fail.*job_error', msg)
    if m is not None:
        project = m.group(0).split(' ')[2].split('_')[0]
        LOG.error('User <{}> job error'.format(project))
        notify_error(project)

def yscheduler_error_handler(msg):
    if 'Send email' in msg or 'Send message' in msg:
        LOG.error('YScheduler internal error: msg = {}'.format(msg))
        notify_error('yscheduler')

error_handlers = [
    task_error_handler,
    #yscheduler_error_handler,
]

def main():
    save_pid()

    old_ino = 0
    file_obj = None

    while True:
        try:
            cur_ino = os.stat(YSCH_LOG_FILE).st_ino
            if cur_ino != old_ino:
                if file_obj != None:
                    file_obj.close()
                    file_obj = file(YSCH_LOG_FILE)
                else:
                    file_obj = file(YSCH_LOG_FILE)
                    file_obj.seek(0, os.SEEK_END)
                old_ino = cur_ino

            line = file_obj.readline(10240)
            while line != '':
                for error_handler in error_handlers:
                    error_handler(line[:-1])
                line = file_obj.readline(10240)
        except Exception as e:
            LOG.error(str(e))

        time.sleep(10)

if __name__ == '__main__':
    main()

