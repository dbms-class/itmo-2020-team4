# encoding: UTF-8

import argparse
import logging


# Разбирает аргументы командной строки.
# Выплевывает структуру с полями, соответствующими каждому аргументу.
def parse_cmd_line():
    parser = argparse.ArgumentParser(description='Эта программа НЕ вычисляет 2+2 при помощи реляционной СУБД')
    parser.add_argument('--pg-host', help='PostgreSQL host name', default='localhost')
    parser.add_argument('--pg-port', help='PostgreSQL port', default=5432)
    parser.add_argument('--pg-user', help='PostgreSQL user', default='')
    parser.add_argument('--pg-password', help='PostgreSQL password', default='')
    parser.add_argument('--pg-database', help='PostgreSQL database', default='')
    parser.add_argument('--sqlite-file', help='SQLite3 database file. Type :memory: to use in-memory SQLite3 database',
                        default=None)
    parser.add_argument("-v", "--verbose", action='store_true', help='Debug loglevel')
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(format='%(levelname)s:\t%(message)s', level=logging.DEBUG)
        logging.debug("Debug logging is ON")
    del args.verbose
    return args
