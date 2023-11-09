#!/bin/sh

#
# This script searches feature datasets to find data bundles that meet specific per-feature
# search parameters (=, <, >, ~).   
#
# Inputs: project configuration file
# 	  data bundle
# 	   
# Output: data bundles (one per line) that meet search parameters
#

# functions
function usage() {
	echo "Usage: `basename $0` [-h (usage)] [-d(ebug)] project-configuration-file data-bundle"
        exit $1
}

# arguments
while getopts 'hd' OPTION; do
        case $OPTION in
                h)
                        usage
                        exit 0
                        ;;
                d)
                        DEBUG=1
                        ;;
        esac
done
shift $((OPTIND - 1))
if [ ! "$2" ]; then
        usage >&2
        exit 1
elif [ ! -r "$1" ]; then
	echo "$0: Project configuration file $1 does not exist or is not readable, exiting ..."
	exit 1
elif [ ! -r "$2" ]; then
	echo "$0: Data bundle $2 does not exist or is not readable, exiting ..."
	exit 1
else
	confFile="$1"
	bundle="$2"
fi

# Source the configuration file
source $confFile
datasetsDir="${PROJECT_DIR}/datasets"
tmpDir=`mktemp -d`
[ $DEBUG ] && echo "*** DEBUG: $0: tmpDir: $tmpDir" >&2

# Pre-process the data bundle
if [ ! -z "$PRE_EXECUTABLE" ]; then
	bundle=`$PRE_EXECUTABLE $bundle $tmpDir`
fi

# Build the featureName, featureType, and featureExecutable arrays
featureNum=1
numFeatures=0
featureNameArray=""
featureTypeArray=""
while true; do
	tmpVar="FEATURE${featureNum}_NAME"
	eval featureName=\$$tmpVar
	if [ -z "$featureName" ]; then
		break
	fi
	featureNameArray="$featureNameArray $featureName"
	tmpVar="FEATURE${featureNum}_TYPE"
	eval featureType=\$$tmpVar
	featureTypeArray="$featureTypeArray $featureType"
        tmpVar="FEATURE${featureNum}_EXECUTABLE"
        eval featureExecutable=\$$tmpVar
        featureExecutableArray="$featureExecutableArray $featureExecutable"
	numFeatures=$featureNum
	featureNum=$((featureNum + 1))
done
[ $DEBUG ] && echo "*** DEBUG: $0: featureNameArray: $featureNameArray" >&2
[ $DEBUG ] && echo "*** DEBUG: $0: featureTypeArray: $featureTypeArray" >&2
[ $DEBUG ] && echo "*** DEBUG: $0: featureExecutableArray: $featureExecutableArray" >&2

# Set default weight
defWeight=$((100 / numFeatures))
[ $DEBUG ] && echo "*** DEBUG: $0: defWeight: $defWeight" >&2

# Set search parameters and weights
echo "Number of features: $numFeatures"
echo "Default per-feature weight: $defWeight%"
echo "Weights may be changed, but sum of all weights must equal 100%."
featureNum=1
featureParameterArray=""
for featureName in $featureNameArray; do
	featureType=`echo $featureTypeArray | cut -d' ' -f${featureNum}`
	[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
	[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
	echo -n "$featureName weight (must be between 0 and 100%; default is $defWeight%)? "
	read featureWeight
	if [ -z "$featureWeight" ]; then
		featureWeight="$defWeight"
	fi
	featureWeightArray="$featureWeightArray $featureWeight"
	featureNum=$((featureNum + 1))
done
[ $DEBUG ] && echo "*** DEBUG: $0: featureWeightArray: $featureWeightArray" >&2

# Find similar data bundles
featureNum=1
for featureName in $featureNameArray; do
	echo "Searching based on $featureName ..."
	featureType=`echo $featureTypeArray | cut -d' ' -f${featureNum}`
	featureExecutable=`echo $featureExecutableArray | cut -d' ' -f${featureNum}`
	featureDataset="${datasetsDir}/${featureName}.csv"
	[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName, featureType: $featureType, featureExecutable: $featureExecutable, featureDataset: $featureDataset" >&2
	featureMatchList=""
	outFile="${tmpDir}/${featureName}-dist.csv"
	if [ "$featureType" = "ordinal" ]; then
		featureVal=`$featureExecutable $bundle`
		[ $DEBUG ] && featureMatchList=`python3 ./ordinal.py -d $featureDataset $featureVal $outFile`
		[ ! $DEBUG ] && featureMatchList=`python3 ./ordinal.py $featureDataset $featureVal $outFile`
	else	
		featureValFile="${tmpDir}/${featureName}.tmp"
		$featureExecutable $bundle > $featureValFile
		[ $DEBUG ] && featureMatchList=`python3 ./categorical.py -d $featureDataset $featureValFile $outFile`
		[ ! $DEBUG ] && featureMatchList=`python3 ./categorical.py $featureDataset $featureValFile $outFile`
	fi
	featureNum=$((featureNum + 1))
done

# Combine results - Build a new array with elements (id, length).  Smallest length is best match.
# This is where we worry about weights?
echo "Combining results ..."

echo "Overall similar data bundles to $bundle: <tbd>"

exit 0
