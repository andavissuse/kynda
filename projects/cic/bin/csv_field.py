#
# This script extracts a requested field from a cic rawdata entry.
#
# Inputs: 1) entry (provided as one-line csv file)
#         2) field number
#
# Output: string containing field data
#

from __future__ import print_function

import getopt
import sys
import csv
import subprocess

def usage():
    print("Usage: csv_field.py [-d(ebug)] cic-entry-file field-number", file=sys.stderr)

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
    entry_file = argv[arg_index_start]
    field_num = int(argv[arg_index_start + 1])
    if DEBUG == "TRUE":
        print("*** DEBUG: csv_field.py: entry_file:", entry_file, file=sys.stderr)
        print("*** DEBUG: csv_field.py: field_num:", field_num, file=sys.stderr)

    # read the csv
    with open(entry_file, 'r') as csvfile:
        csv_reader = csv.reader(csvfile)
  
        # Pull out requested field
        for row in csv_reader:
            field_data = row[field_num]
            return(field_data)

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
