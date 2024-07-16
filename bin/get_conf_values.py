#
# This script reads a configuration file and returns the requested tag value(s).
#
# Inputs: 1) configuration file 
#         2) tag type to extract
#
# Output: List containing value(s) for the requested tag
#

from __future__ import print_function

import getopt
import sys
import os
import array as arr

def usage():
    print("Usage:", os.path.basename(sys.argv[0]), "[-d(ebug)] config_file tag_type", file=sys.stderr)

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
    conf_file = argv[arg_index_start]
    tag = argv[arg_index_start + 1]
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "conf_file:", conf_file, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "tag_type:", tag, file=sys.stderr)

    conf_file_fd = open(conf_file, 'r')
    tag_value_list = []
    if "FEATURE" in tag.upper():
        tag_fields = tag.split("_")
        tag_type = tag_fields[1]
        feature_num = 1
        while True:
            feature_tag = "FEATURE" + str(feature_num) + "_" + tag_type.upper()
            conf_line = conf_file_fd.readline().strip()
            if not conf_line:
                break
            conf_line_fields = conf_line.split("=")
            if conf_line_fields[0] == feature_tag:
                tag_value_list.append(conf_line_fields[1])
                feature_num += 1
    else:
        while True:
            conf_line = conf_file_fd.readline().strip()
            if not conf_line:
                break
            conf_line_fields = conf_line.split("=")
            if conf_line_fields[0] == tag.upper():
                tag_value_list.append(conf_line_fields[1])
                break

    conf_file_fd.close()
    return tag_value_list

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
