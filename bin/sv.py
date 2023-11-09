#
# This script analyzes a dataset to find the nearest neighbors to the given
# feature value(s).  
#
# Inputs: 1) dataset file (space-delimited csv)
#         2) feature file (space-delimited csv)
#
# Output: pandas dataframe (bundle name, score) of nearest neighbors
#

from __future__ import print_function

import getopt
import sys
import numpy as np
import pandas as pd
import subprocess
from sklearn.neighbors import NearestNeighbors
from collections import OrderedDict

def usage():
    print("Usage: knn.py [-d(ebug)] dataset_file feature_file", file=sys.stderr)

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
    dataset_file = argv[arg_index_start]
    feature_file = argv[arg_index_start + 1]
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: dataset_file:", dataset_file, file=sys.stderr)
        print("*** DEBUG: knn.py: feature_file:", feature_file, file=sys.stderr)

    # read the dataset
    df_dataset = pd.read_csv(dataset_file, sep=" ", dtype={'id':'str'})
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: df_dataset:\n", df_dataset, file=sys.stderr)
        print("*** DEBUG: knn.py: df_dataset dtypes:\n", df_dataset.dtypes, file=sys.stderr)
    if df_dataset.empty:
        if DEBUG == "TRUE":
            print("*** DEBUG: knn.py: df_dataset is empty", file=sys.stderr)
        return []
    df_dataset.fillna(0, inplace = True)
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: df_dataset:\n", df_dataset, file=sys.stderr)

    # create the feature vector (and add columns for unknowns to df_dataset dataframe)
    feature_binvals = [0] * (len(df_dataset.columns) - 2)
    feature_vals = subprocess.getoutput("cat %s" % feature_file).split()
    num_feature_vals = len(feature_vals)
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: feature_vals:", feature_vals, file=sys.stderr)
    for feature_val in feature_vals:
        if DEBUG == "TRUE":
            print("*** DEBUG: knn.py: feature_val:", feature_val, file=sys.stderr)
        if feature_val in df_dataset.columns.values:
            matching_col_num = df_dataset.columns.get_loc(feature_val)
            if DEBUG == "TRUE":
                print("*** DEBUG: knn.py: matching_col_num:", matching_col_num, file=sys.stderr)
            feature_binvals[matching_col_num - 1] = 1
        else:
            if DEBUG == "TRUE":
                print("*** DEBUG: knn.py: no matching column for:", feature_val, file=sys.stderr)
            feature_binvals.append(1)
            df_dataset.insert((len(df.columns) - 1), feature_val, 0)
    feature_vector = np.array(feature_binvals)
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: feature_vector:", feature_vector, file=sys.stderr)
        print("*** DEBUG: knn.py: feature_vector size:", feature_vector.shape, file=sys.stderr)

    # initialize nearest neighbors
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: initializing nearest neighbors...", file=sys.stderr)
    neigh = NearestNeighbors(metric="jaccard")
    df_dataset_cols = len(df_dataset.columns)
    df_dataset_rows = len(df_dataset)
    Inputs_df_dataset = df_dataset.iloc[:, 1:df_dataset_cols - 1]
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: Inputs_df_dataset:\n", Inputs_df_dataset, file=sys.stderr)
        print("*** DEBUG: knn.py: Inputs_df_dataset dtypes:\n", Inputs_df_dataset.dtypes, file=sys.stderr)
    neigh.fit(Inputs_df_dataset)

    # find nearest neighbors
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: finding matches ...")
    nns = neigh.radius_neighbors(feature_vector.reshape(1, -1), return_distance=True, sort_results=True)
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: nns:\n", nns, file=sys.stderr)
    nn_dists = np.asarray(nns[0][0])
    nn_inds = np.asarray(nns[1][0])
    num_nns = len(nn_inds)
    list_nns = []
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: nn_dists:", nn_dists, file=sys.stderr)
        print("*** DEBUG: knn.py: nn_inds:", nn_inds, file=sys.stderr)
        print("*** DEBUG: knn.py: num_nns:", num_nns, file=sys.stderr)
    for i in range(num_nns):
        ind = nn_inds[i]
        bundle_name = df_dataset.at[nn_inds[i], 'id']
        dist = nn_dists[i]
#        list_nns_entry = [bundle_name, (1 - dist)]
        list_nns_entry = [bundle_name, dist]
        list_nns.append(list_nns_entry)
    if DEBUG == "TRUE":
        print("*** DEBUG: knn.py: list_nns:", list_nns, file=sys.stderr)
    
#    df_dataset_nns = pd.DataFrame(list_nns, columns = ['Id', 'Score'])
    df_dataset_nns = pd.DataFrame(list_nns, colums = ['Id', 'Distance'])
    return(df_dataset_nns)

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
