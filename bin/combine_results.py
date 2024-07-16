#
# This script combines nearest-neighbor results based on per-feature weights
# then outputs the top 10 nearest neighbors along with their distances.
#
# Inputs: 1) directory containing per-feature *.dist and *.weight files
#
# Output: List of top 10 nearest neighbors along with their distances
#

import getopt
import sys
import os
import pandas as pd

def usage():
    print("Usage: " + sys.argv[0] + " [-d] directory_containing_dist_and_weight_files")

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
    if not argv[arg_index_start]:
        usage()
        sys.exit(2)
    if os.path.isdir(argv[arg_index_start]):
        input_dir = argv[arg_index_start]
    else:
        print("Directory does not exist: ", argv[arg_index_start])
        usage()
        sys.exit(2)
    if DEBUG == "TRUE":
        print("*** DEBUG: " + sys.argv[0] + ": input_dir:", input_dir, file=sys.stderr)

    df_total = pd.DataFrame(columns = ['id', 'score'])
    for input_file in os.listdir(input_dir):
        if DEBUG == "TRUE":
            print("*** DEBUG: " + sys.argv[0] + ": input_file:", input_file, file=sys.stderr)
        if input_file.endswith(".dist"):
            feature_name = os.path.splitext(input_file)[0]
            dist_file = input_dir + "/" + input_file
            weight_file = input_dir + "/" + feature_name + ".weight"
            if DEBUG == "TRUE":
                print("*** DEBUG: " + sys.argv[0] + ": feature_name:", feature_name, file=sys.stderr)
                print("*** DEBUG: " + sys.argv[0] + ": dist_file:", dist_file, file=sys.stderr)
                print("*** DEBUG: " + sys.argv[0] + ": weight_file:", weight_file, file=sys.stderr)
            if not os.path.isfile(weight_file):
                print("Weight file does not exist: ", weight_file)
                usage()
                sys.exit(2)
            with open(weight_file) as weight_file_fd:
                weightPct = int(weight_file_fd.readline())
                weight = weightPct/100
            if DEBUG == "TRUE":
                print("*** DEBUG: " + sys.argv[0] + ": weight:", weight, file=sys.stderr)
            df = pd.read_csv(dist_file, sep=' ', dtype={'id':'str','dist':'float'})
            if DEBUG == "TRUE":
                print("*** DEBUG: " + sys.argv[0] + ": df:", df, file=sys.stderr)
            df = df.rename({'dist': 'score'}, axis=1)
            df['score'] = df['score'].apply(lambda x: (1 - x) * weight)
            if DEBUG == "TRUE":
                print("*** DEBUG: " + sys.argv[0] + ": df:", df, file=sys.stderr)
            if df_total.empty:
                df_total = df
            else:
                if DEBUG == "TRUE":
                    print("*** DEBUG: " + sys.argv[0] + ": df_total:", df_total, file=sys.stderr)
                    print("*** DEBUG: " + sys.argv[0] + ": df:", df, file=sys.stderr)
                new_df_total = pd.concat([df_total, df]).groupby(['id']).sum().reset_index()
                df_total = new_df_total

            if DEBUG == "TRUE":
                print("*** DEBUG: " + sys.argv[0] + ": df_total:", df_total, file=sys.stderr)

    df_total = df_total.sort_values(by=['score'], ascending=False)
    if DEBUG == "TRUE":
        print("*** DEBUG: " + sys.argv[0] + ": df_total:", df_total, file=sys.stderr)
    df_result = df_total.head(10)
    df_result = df_result.to_string(index=False)
    return df_result

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
