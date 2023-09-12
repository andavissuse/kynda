# kynda
## Overview
kynda is a software framework to create projects for comparing data bundles based on desired features and weights.  The whole idea of kynda is not to find "answers", but to find similarities based on user-supplied feature weights.  The name "kynda" comes from the idea that we are trying to find things that are "kinda" similar.

## Approach
Using the kynda framework involves 3 stages:  SETUP, INGESTION, and ANALYSIS.  The setup stage defines the project (including where to find existing data bundles, features to be compared, etc.)  The ingestion stage accesses the existing data bundles, extracts feature data, and builds datasets.  The analysis stage uses the
datasets to compare a new data bundle to the existing data bundles to find similar bundles.

## Stage 1: Setup
Prerequisites:
* Collection of data bundles (should be in a directory; format does not matter)
* List of feature(s) that you want to use for comparison
* For each feature, a script or other executable that returns the feature value(s) (1 per line) from a data bundle.
  
Steps:
* Run the kynda-setup.sh script.  This will:
  * ask for a project name and create a .\/\<project-name\> directory
  * ask where the data bundles are located
  * ask what features you want to use for comparison
  * for each feature, ask for:
    * path to an executable that will extract and return the feature value(s).  The script may invoke other binaries; the key point is that the script must return a list of feature value(s) (one value per line).  See the doc directory for executable details and templates.

Result:
* .\/\<project-name\>\/\<project-name\>.conf file
* feature extraction executables in the .\/\<project-name\>\/bin directory
  
## Stage 2 - Ingestion
Steps:
* Run "kynda-ingest.sh \<project-name\>".  This will:
  * read the .\/\<project-name\>\/\<project-name\>.conf file
  * use the specified extraction scripts to pull feature data from the existing data bundles
  * create datasets of the features
    
Result:
* datasets in the .\/\<project-name\>/datasets directory.

## Stage 3 - Analysis
Prerequisites:
* For each feature, an executable that compares feature value(s) to existing values in the feature-specific dataset.
* A new data bundle to compare to existing data bundles.

Steps:
* Run "kynda.sh \<project-name\> \<new-data-bundle\>".  This will:
  * extract the features from the new data bundle
  * for each feature, ask for:
    * path to the executable that will do the feature-based comparison.  See the doc directory for executable details and templates.
    * ask for different importance levels (weights) for each feature
  * use the comparison executables along with the specified weights to find similar data bundles

Result:
* List of data bundles that are similar to the new data bundle
