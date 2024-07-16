#
# This script reads a dataset, finds the distances from each entry to a given feature value,
# then outputs a new csv file that lists each entry with its distance to the feature value.
# Output file is sorted based on distance (ascending).
#
# Inputs: 1) dataset file (space-delimited csv)
#         2) feature value
#         3) ordered output file of distances (space-delimited csv)
#

from __future__ import print_function

import getopt
import sys
import os
import numpy as np
import pandas as pd
import subprocess
from collections import OrderedDict

def usage():
    print("Usage:", os.path.basename(sys.argv[0]), "[-d(ebug)] dataset_file feature_value output_dataset_file", file=sys.stderr)

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
    if not argv[arg_index_start + 2]:
        usage()
        sys.exit(2)
    dataset_file = argv[arg_index_start]
    feature_val = int(argv[arg_index_start + 1])
    out_file = argv[arg_index_start + 2]
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "dataset_file:", dataset_file, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_val:", feature_val, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "out_file:", out_file, file=sys.stderr)

    # read the dataset
    df = pd.read_csv(dataset_file, sep=' ', index_col=False, dtype={'id':'str','val':'int'})
    if df.empty:
        if DEBUG == "TRUE":
            print("*** DEBUG:", os.path.basename(sys.argv[0]), "df is empty", file=sys.stderr)
        return []
    df.fillna(0, inplace = True)
    max_val = df['val'].max()
    if feature_val > max_val:
        max_val = feature_val
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df:\n", df, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df dtypes:\n", df.dtypes, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "max_val:", max_val, file=sys.stderr)

    # convert dataset to distances
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "finding distances ...", file=sys.stderr)
    df['val'] = (df['val'] - feature_val).abs()
    df = df.rename(columns={'val': 'dist'})
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df:\n", df, file=sys.stderr)

    # scale values to between 0 and 1
    df['dist'] = df['dist'] / max_val
    df = df.sort_values(by=['dist'])
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df:\n", df, file=sys.stderr)
    df.to_csv(out_file, sep=' ', index=False)

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
