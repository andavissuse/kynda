#!/bin/sh

#
# This script sets up a kynda framework for a desired type of data bundle. 
#
# Inputs: None
#
# Output: kynda-<bundle-name>.conf file
#

# functions
function usage() {
        echo "Usage: `basename $0` [-d(ebug)]"
}

# Get the project name and set up directory structure
echo -n "Project name (no spaces)? "
read projName
echo -n "Full path to project directory (will be created if needed)? "
read projDir
if [ -z "$projDir" ]; then
	echo "No project directory specified, exiting ..."
	exit 1
fi
echo -n "Project configuration file (default: ${projDir}/${projName}.conf)? "
read confFile
if [ -z "$confFile" ]; then
	confFile="${projDir}/${projName}.conf"
fi

# Create the conf file
echo "PROJECT_NAME=$projName" >> $confFile
echo "PROJECT_DIR=$projDir" >> $confFile
echo -n "Full path to directory containing $projName data bundles? "
read dataDir
echo "DATA_DIR=$dataDir" >> $confFile
echo -n "Executable to pre-process data bundle (optional)? "
read preExecutable
echo "PRE_EXECUTABLE=${preExecutable}" >> $confFile 
echo -n "Executable to return the per-bundle identifier? "
read idExecutable
echo "ID_EXECUTABLE=${idExecutable}" >> $confFile

featureNum=1
while true; do
    echo -n "Name of feature to be compared? "
    read featureName
    echo -n "Type of feature (ordinal/categorical)? "
    read featureType
    echo -n "Executable to extract feature value(s)? "
    read featureExecutable
    echo "FEATURE${featureNum}_NAME=$featureName" >> $confFile
    echo "FEATURE${featureNum}_TYPE=${featureType}" >> $confFile
    echo "FEATURE${featureNum}_EXECUTABLE=${featureExecutable}" >> $confFile
    echo -n "Add another feature (y/n)? "
    read response
    if [ "$response" = "n" ]; then
        break
    fi
    featureNum=$((featureNum + 1))
done

echo "$projName configuration file is $confFile.  Use this configuration file when invoking"
echo "kynda-ingest.sh and kynda.sh."
