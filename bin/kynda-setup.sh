#!/bin/sh

#
# This script sets up a kynda framework for a desired type of data instance. 
#
# Inputs: None
#
# Output: kynda-<instance-name>.conf file
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
else
	mkdir -p $projDir
fi
echo -n "Project configuration file to be created (default: ${projDir}/${projName}.conf)? "
read confFile
if [ -z "$confFile" ]; then
	confFile="${projDir}/${projName}.conf"
fi
if [ -f "$confFile" ]; then
	echo -n "Configuration file $confFile already exists.  Erase (y/n)? "
	read resp
	if [ "$resp" = "y" ]; then
		rm -rf $confFile
	else
		"Exiting..."
		exit 1
	fi
fi

# Create the conf file
echo "PROJECT_NAME=$projName" >> $confFile
echo "PROJECT_DIR=$projDir" >> $confFile
echo -n "Full path to directory or csv containing $projName data entries? "
read dataLoc
echo "DATA_LOC=$dataLoc" >> $confFile
echo -n "Executable to pre-process data entries (optional)? "
read preExecutable
echo "PRE_EXECUTABLE=${preExecutable}" >> $confFile 
echo -n "Executable to return the data entry identifier? "
read idExecutable
echo "ID_EXECUTABLE=${idExecutable}" >> $confFile

featureNum=1
while true; do
    echo -n "Name of feature to be compared? "
    read featureName
    echo -n "Description of feature? "
    read featureDesc
    echo -n "Type of feature (ordinal/categorical)? "
    read featureType
    echo -n "Executable to extract feature value(s)? "
    read featureExecutable
    echo "FEATURE${featureNum}_NAME=$featureName" >> $confFile
    echo "FEATURE${featureNum}_DESC=$featureDesc" >> $confFile
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
