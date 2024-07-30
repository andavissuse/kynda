# kynda Criminal Incident Comparison Project
## Overview
"Criminal Incident Comparison" (CIC) is a project that uses the kynda framework to find similar criminal incidents based on specified features and weights for comparison.  CIC uses the kynda framework to define features of interest, create per-feature datasets from the raw criminal incident data, and compare incidents based on the features and user-specified weights.

This instance of the CIC project contains:

* Raw data:

    * file (rawdata/100.csv) containing data from 100 LAPD criminal incidents

* extraction scripts for 5 features:

    * Time of day (tod) the criminal incident occurred
    * Streets associated with the location where the criminal incident occurred
    * Age of the victim
    * Offense code
    * Modus Operandi (MO) code

* configuration file cic.conf (created by kynda-setup.sh) 

* Datasets - separate dataset for each of the five features (created by kynda-ingest)

* sample data instances (rawdata/inst\*.csv) taken from the 100.csv raw data
