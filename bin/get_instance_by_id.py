#
# This script extracts a data instance (by id) from a data location (directory or file).
#
# Inputs: 1) data (directory or file) 
#         2) id to extract
#
# Output: List containing value(s) for the requested instance
#

from __future__ import print_function

import getopt
import sys
import os
import csv

def usage():
    print("Usage:", os.path.basename(sys.argv[0]), "[-d(ebug)] data instance_id", file=sys.stderr)

def main(argv):
    arg_index_start = 0
    DEBUG = "FALSE"
    try:
        opts, args = getopt.getopt(argv, 'd', ['debug'])
        if not args:
            usage()
            sys.exit(2)
    except getopt.GetoptError as err:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-d'):
            DEBUG = "TRUE"
            arg_index_start = 1

    # arguments
    if not argv[arg_index_start + 1]:
        usage()
        sys.exit(2)
    data = argv[arg_index_start]
    inst_id = argv[arg_index_start + 1]
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "data:", data, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "inst_id:", inst_id, file=sys.stderr)

    if os.path.isfile(data):
        csv_file = csv.reader(open(data, "r"), delimiter=",")
        for row in csv_file:
            if row[0] == inst_id:
                return row

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
