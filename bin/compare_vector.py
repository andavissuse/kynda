#
# This script reads a vector dataset, uses nearest-neighbor to find the distances from each
# entry to a given vector, then outputs a new csv file that lists each entry with its
# distance to the vector.  Output file is sorted based on distance (ascending).

# This script reads a dataset, finds the 20 nearest neighbors to a given feature vector,
# then outputs a new dataset that lists the 20 entries along with their distances from
# the feature vector.
#
# Inputs: 1) dataset file (space-delimited csv)
#         2) feature file (space-delimited csv)
#         3) output dataset file (space-delimited csv)
#
# Output: Dataset (space-deliminted *.csv file) containing instance names and distances
# from the feature vector.
#

from __future__ import print_function

import getopt
import sys
import os
import numpy as np
import pandas as pd
import subprocess
from sklearn.neighbors import NearestNeighbors
from collections import OrderedDict

def usage():
    print("Usage:", os.path.basename(sys.argv[0]), "[-d(ebug)] dataset_file feature_file output_file", file=sys.stderr)

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
    feature_file = argv[arg_index_start + 1]
    out_file = argv[arg_index_start + 2]
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "dataset_file:", dataset_file, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_file:", feature_file, file=sys.stderr)

    # read the dataset
    df_dataset = pd.read_csv(dataset_file, sep=" ", dtype={'id':'str'})
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df_dataset:\n", df_dataset, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df_dataset dtypes:\n", df_dataset.dtypes, file=sys.stderr)
    if df_dataset.empty:
        if DEBUG == "TRUE":
            print("*** DEBUG:", os.path.basename(sys.argv[0]), "df_dataset is empty", file=sys.stderr)
        return []
    df_dataset.fillna(0, inplace = True)
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "df_dataset:\n", df_dataset, file=sys.stderr)

    # create the feature vector (and add columns for unknowns to df_dataset dataframe)
    feature_binvals = [0] * (len(df_dataset.columns) - 1)
    feature_vals = subprocess.getoutput("cat %s" % feature_file).split()
    num_feature_vals = len(feature_vals)
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_binvals:", feature_binvals, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_vals:", feature_vals, file=sys.stderr)
    for feature_val in feature_vals:
        if DEBUG == "TRUE":
            print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_val:", feature_val, file=sys.stderr)
        if feature_val in df_dataset.columns.values:
            matching_col_num = df_dataset.columns.get_loc(feature_val)
            if DEBUG == "TRUE":
                print("*** DEBUG:", os.path.basename(sys.argv[0]), "matching_col_num:", matching_col_num, file=sys.stderr)
            feature_binvals[matching_col_num - 1] = 1
        else:
            if DEBUG == "TRUE":
                print("*** DEBUG:", os.path.basename, "no matching column for:", feature_val, file=sys.stderr)
            feature_binvals.append(1)
            df_dataset.insert((len(df_dataset.columns) - 1), feature_val, 0)
    feature_vector = np.array(feature_binvals)
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_vector:", feature_vector, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "feature_vector size:", feature_vector.shape, file=sys.stderr)

    # initialize nearest neighbors
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "initializing nearest neighbors...", file=sys.stderr)
    neigh = NearestNeighbors(metric="jaccard")
    df_dataset_cols = len(df_dataset.columns)
    df_dataset_rows = len(df_dataset)
    Inputs_df_dataset = df_dataset.iloc[:, 1:df_dataset_cols]
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "Inputs_df_dataset:\n", Inputs_df_dataset, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "Inputs_df_dataset dtypes:\n", Inputs_df_dataset.dtypes, file=sys.stderr)
    neigh.fit(Inputs_df_dataset)

    # find nearest neighbors
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "finding matches ...")
    nns = neigh.radius_neighbors(feature_vector.reshape(1, -1), return_distance=True, sort_results=True)
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "nns:\n", nns, file=sys.stderr)
    nn_dists = np.asarray(nns[0][0])
    nn_inds = np.asarray(nns[1][0])
    num_nns = len(nn_inds)
    list_nns = []
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "nn_dists:", nn_dists, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "nn_inds:", nn_inds, file=sys.stderr)
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "num_nns:", num_nns, file=sys.stderr)
    for i in range(num_nns):
        ind = nn_inds[i]
        inst_name = df_dataset.at[nn_inds[i], 'id']
        dist = nn_dists[i]
#        list_nns_entry = [inst_name, (1 - dist)]
        list_nns_entry = [inst_name, dist]
        list_nns.append(list_nns_entry)
    if DEBUG == "TRUE":
        print("*** DEBUG:", os.path.basename(sys.argv[0]), "list_nns:", list_nns, file=sys.stderr)
    
    df_dataset_nns = pd.DataFrame(list_nns, columns = ['id', 'dist'])
    df_dataset_nns.to_csv(out_file, sep=' ', index=False)

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
