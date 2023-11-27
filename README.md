# kynda
## Overview
kynda is a software framework to create projects for comparing data bundles based on desired features and weights.  The whole idea of kynda is not to find "answers", but to find similarities based on features and user-supplied weights for each feature.

## Approach
Using the kynda framework involves 3 stages:  SETUP, INGESTION, and ANALYSIS.  The setup stage defines the project (including where to find existing data bundles, features to be compared, etc.)  The ingestion stage accesses the existing data bundles, extracts feature data, and builds datasets.  The analysis stage uses the datasets and user-specified weights to find existing data bundles that are most similar to the new data bundle. 

## Stage 1: Setup
Prerequisites:
* Collection of data bundles (should be in a directory; format does not matter)
* (Optional) Script or other executable to pre-process the data bundle (e.g., script to uncompress tarball)
* List of feature(s) to use for comparison
* For each feature:
  * script or other executable that extracts the feature value(s) from a data bundle.
  
Steps:
* Run "kynda-setup.sh" to create a project-specific configuration file.  kynda-setup.sh will ask for: 
  * project name
  * location of data bundles
  * data bundle pre-processing executable (optional)
  * features to be used for comparison
  * executables that extract the feature value(s) from data bundles

Result:
* .\/\<project-name\>\/\<project-name\>.conf file
  
## Stage 2 - Ingestion
Steps:
* Run "kynda-ingest.sh \<project-name\>" to build datasets.  Specifically, kynda-ingest.sh will:
  * read the .\/\<project-name\>\/\<project-name\>.conf file
  * use the specified extraction scripts to pull feature data from the existing data bundles
  * create datasets of the features
    
Result:
* datasets in the .\/\<project-name\>/datasets directory

## Stage 3 - Analysis
Prerequisites:
* New data bundle to compare to existing data bundles

Steps:
* Run "kynda.sh \<project-name\> \<new-data-bundle\>" to compare the new data bundle to existing data bundles.  Specifically, kynda.sh will:
  * extract the features from the new data bundle
  * ask for per-feature weights to be used in comparison
  * compare the new data bundle to existing data bundles based on desired per-feature weights

Result:
* List of data bundles that are similar to the new data bundle

## For more info, see details in the doc directory.
