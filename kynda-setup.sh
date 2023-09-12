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
        exit $1
}

# Get the project name and set up directory structure
echo "What is the project name (no spaces)?"
read projName
mkdir -p ./${projName}
mkdir -p ./${projName}/bin
confFile="./${projName}/${projName}.conf"

# Create the conf file
echo "Where are the $projName data bundles located (full path to a directory)?"
read dataDir
echo "DATA_DIR=$dataDir" >> $confFile
echo "What is the executable that will return the per-bundle identifier?"
read idExecutable
echo "ID_EXECUTABLE=${idExecutable}" >> $confFile
cp $idExecutable $projName/bin/

featureNum=1
while true; do
    echo "Feature to be compared?"
    read featureName
    featureType="single"
    echo "Is feature multi-valued (y/n)?"
    read multivalued
    if [ "$multivalued" = "y" ]; then
	    featureType="multi"
    fi
    echo "Executable to extract feature value(s)?"
    read featureExecutable
    if [ "$featureType" = "single" ]; then
	echo "Is feature ordered (y/n)?"
	read ordered
	if [ "$ordered" = "y" ]; then
            "Executable to provide ordering?"
	    read orderExecutable
	fi
    fi
    echo "FEATURE${featureNum}_NAME=$featureName" >> $confFile
    echo "FEATURE${featureNum}_TYPE=${featureType}" >> $confFile
    echo "FEATURE${featureNum}_EXECUTABLE=${featureExecutable}" >> $confFile
    cp $featureExecutable $projName/bin/
    if [ "$ordered" = y ]; then
    	echo "FEATURE${featureNum}_ORDER_EXECUTABLE=${orderExecutable}" >> $confFile
	cp $orderExecutable $projName/bin/
    fi
    echo "Add another feature (y/n)?"
    read response
    if [ "$response" = "n" ]; then
        break
    fi
    featureNum=$((featureNum + 1))
done
