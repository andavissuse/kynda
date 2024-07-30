import getopt
import sys
import os
import csv
import streamlit as st
import tempfile
import subprocess
import numpy as np
import pandas as pd

import get_conf_values
import compare_scalar
import compare_vector
import combine_results
import get_instance_by_id

def usage():
    print("Usage:", os.path.basename(sys.argv[0]), "[-d(ebug)] project_configuration_file", file=sys.stderr)

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

    if not argv[arg_index_start]:
        usage()
        sys.exit(2)
    conf_file = argv[arg_index_start]

    # Pull info from the conf file
    project_desc = get_conf_values.main([conf_file, "project_desc"])
    project_dir = get_conf_values.main([conf_file, "project_dir"])
    project_data = get_conf_values.main([conf_file, "data_loc"])
    datasets_dir = project_dir[0] + "/datasets"
    feature_name_list = get_conf_values.main([conf_file, "feature_name"])
    feature_desc_list = get_conf_values.main([conf_file, "feature_desc"])
    feature_type_list = get_conf_values.main([conf_file, "feature_type"])
    feature_exec_list = get_conf_values.main([conf_file, "feature_executable"])
    num_features = len(feature_name_list)

    # Set up the web page and form
    st.title(project_desc[0].strip('\"'))
    form = st.form("my_form")
    form.header("Data instance to compare against existing data:")
    uploaded_file = form.file_uploader(label="")

    form.header('Feature weights by percentage (must add up to 100%):')
    feature_weight_list = []
    for feature_num in range(num_features):
#        form.text("Feature " + str(feature_num + 1) + ": " + feature_desc_list[feature_num])
        feature_weight_list.append(form.number_input("Feature " + str(feature_num + 1) + " " + feature_desc_list[feature_num] + ":", value=20))

    submitted = form.form_submit_button("Submit")

    if submitted:
        temp_dir = tempfile.mkdtemp()

        # Get the uploaded data instance file
        if uploaded_file:
            data_inst_file = os.path.join(temp_dir, uploaded_file.name)
            with open(data_inst_file, "wb") as f:
                f.write(uploaded_file.getvalue())

        # Create the dist file for each feature
        feature_num = 1
        for feature_num in range(num_features):
            feature_name = feature_name_list[feature_num]
            feature_type = feature_type_list[feature_num]
            feature_exec = feature_exec_list[feature_num]
            feature_dataset = datasets_dir + "/" + feature_name + ".csv"
            dist_file = temp_dir + "/" + feature_name + ".dist"
            weight_file = temp_dir + "/" + feature_name + ".weight"
            with open(weight_file, 'w') as weight_file_fd:
                weight_file_fd.write(str(feature_weight_list[feature_num]))
            if feature_type == "ordinal":
                feature_val = subprocess.check_output([feature_exec, data_inst_file])
                compare_scalar.main([feature_dataset, feature_val, dist_file])
            if feature_type == "categorical":
                feature_val_file = temp_dir + "/" + feature_name + ".tmp"
                with open(feature_val_file, 'w') as feature_val_fd:
                    subprocess.run([feature_exec, data_inst_file], stdout=feature_val_fd)
                compare_vector.main([feature_dataset, feature_val_file, dist_file])

        # Combine based on weights
        top_matches = []
        top_matches = combine_results.main([temp_dir])

        full_header = []
        full_header = get_instance_by_id.main([project_data[0], "DR_NO"])

        df_inst = pd.DataFrame(columns=full_header)
        inst_csv_file = csv.reader(open(data_inst_file, "r"), delimiter=",")
        for row in inst_csv_file:
            inst_data = row
        df_inst.loc[len(df_inst)] = inst_data

        st.header("Instance Data:")
        st.table(df_inst)

        df_matches = pd.DataFrame(columns=full_header)
        matches_list = []
        matches_list = top_matches.split("\n")
        first_line = 1
        for match in matches_list:
            if first_line:
                first_line = 0
            else:
                match_id = match.split()[0]
                match_data = get_instance_by_id.main([project_data[0], match_id])
                df_matches.loc[len(df_matches)] = match_data

        st.header("Top 10 Matches Based on Weights:")
        st.table(df_matches)

if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
