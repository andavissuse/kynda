import getopt
import sys
import os
import streamlit as st
import tempfile
import subprocess

import get_conf_values
import compare_scalar
import compare_vector
import combine_results

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
    project_dir = get_conf_values.main([conf_file, "project_dir"])
    datasets_dir = project_dir[0] + "/datasets"
    feature_name_list = get_conf_values.main([conf_file, "feature_name"])
    feature_desc_list = get_conf_values.main([conf_file, "feature_desc"])
    feature_type_list = get_conf_values.main([conf_file, "feature_type"])
    feature_exec_list = get_conf_values.main([conf_file, "feature_executable"])
    num_features = len(feature_name_list)

    # Set up the web page and form
    st.title('Criminal Incident Comparison')
    form = st.form("my_form")
    form.header("Data instance (single-line csv file):")
    uploaded_file = form.file_uploader(label="")

    form.header('Feature weights (must add up to 100%):')
    feature_weight_list = []
    for feature_num in range(num_features):
        form.text("Feature " + str(feature_num + 1) + ": " + feature_desc_list[feature_num])
        feature_weight_list.append(form.number_input("Feature " + str(feature_num + 1) + " Weight:", value=20))

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
        st.text(top_matches)

#        temp_dir.cleanup()
        
if __name__ == "__main__":
    ret_val = main(sys.argv[1:])
    print(ret_val)
