# kynda
## Overview
kynda is a software framework to create projects for comparing data instances based on desired features and weights.  The idea of kynda is not to find "answers", but to find similarities based on features and user-supplied weights for each feature.

## Approach
Using the kynda framework involves 3 stages:  SETUP, INGESTION, and ANALYSIS.  The setup stage defines the project (including where to find existing data instances, features to be compared, etc.)  The ingestion stage extracts feature data from existing data instances and builds datasets.  The analysis stage uses the datasets and user-specified weights to find existing data instances that are most similar to a new data instance. 

## Stage 1: Setup
Prerequisites:
* Existing data instances (may be in a directory or file; format is defined by implementation)
* (Optional) Script or other executable to pre-process each data instance (e.g., script to uncompress tarball)
* List of feature(s) to use for comparison
* For each feature:
  * script or other executable that extracts the feature value(s) from a data instance
  
Steps:
* Run "kynda-setup.sh" to create a project-specific configuration file.  kynda-setup.sh will ask for: 
  * project name
  * location of existing data instances
  * data entry pre-processing executable (optional)
  * features to be used for comparison
  * executables that extract the feature value(s) from data instances

Result:
* .\/\<project-name\>\/\<project-name\>.conf file
  
## Stage 2 - Ingestion
Steps:
* Run "kynda-ingest.sh <project-conf-file>" to build datasets.  kynda-ingest.sh will:
  * read the .\/\<project-name\>\/\<project-name\>.conf file
  * use the specified extraction scripts to pull feature data from the existing data instances
  * create datasets of the features
    
Result:
* datasets in the .\/\<project-name\>/datasets directory

## Stage 3 - Analysis
Prerequisites:
* New data instance to compare to existing data instances

Steps:
* Command line interface:
    * Run "kynda.sh \<project-conf-file\> \<new-data-instance\>" to compare the new data instance to existing data instances.  kynda.sh will:
        * extract the features from the new data instance
        * ask for per-feature weights to be used in comparison
        * compare the new data instance to existing data instances based on desired per-feature weights
* Web (streamlit) interface:
    * Run "streamlit run streamlit_ui.py -- \<project-conf-file\>
    * Enter the data instance to be compared and the weights to use for comparison
    * Click the submit button

Result:
* List of 10  data instances that are most similar to the new data instance

## More Info
Additional details and samples are available in the doc directory.
