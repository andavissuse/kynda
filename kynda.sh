#!/bin/sh

#
# This script searches datasets to similar data bundles. 
#
# Inputs: project-name
# 	  data-bundle
# 	   
# Output: List of simiar data-bundles based on user-specified weights 
#

# functions
function usage() {
	echo "Usage: `basename $0` [-h (usage)] [-d(ebug)] project-name"
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
elif [ ! -d "$1" ]; then
	echo "$0: Project directory $1 does not exist, exiting..."
	exit 1
elif [ ! -r "$2" ]; then
	echo "$0: Data bundle $2 does not exist or is not readable, exiting..."
	exit 1
else
	projName="$1"
	bundle="$2"
fi

# Source the configuration file
confFile="./$projName/$projName.conf"
if [ ! -r "$confFile" ]; then
	echo "$0: Project configuration file $confFile does not exist, exiting..." >&2
	exit 1
fi
source $confFile

# Get the weights
echo "Getting total number of features from config file..."
featureNum=1
while true; do
	tmpVar="FEATURE${featureNum}_NAME"
	eval featureName=\$$tmpVar
	if [ -z "$featureName" ]; then
		break
	fi
	featureNum=$((featureNum + 1))
done
totalFeatures=$((featureNum - 1))
[ $DEBUG ] && echo "*** DEBUG: $0: totalFeatures: $totalFeatures" >&2
if [ "$totalFeatures" = 0 ]; then
	echo "No features to process, exiting..." >&2
	exit 1
fi
defWeight=$((100 / totalFeatures))
[ $DEBUG ] && echo "*** DEBUG: $0: defWeight: $defWeight" >&2
echo "Number of features is $totalFeatures; default per-feature weight percentage is $defWeight%..."
echo -n "Change feature weights (y/n)? "
read response
if [ "$response" = "y" ]; then
	echo "Note that total weights for all features must equal 100%..." 
	featureNum=1
	while ((featureNum <= totalFeatures)); do
		tmpVar="FEATURE${featureNum}_NAME"
		eval featureName=\$$tmpVar
		[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
		echo -n "Default weight for $featureName is $defWeight%.  Change weight (y/n)? "
       		read response
		if [ "$response" = "y" ]; then
			echo -n "Enter new weight percentage for feature $featureName (must be between 0 and 100; default is $defWeight%): "
			read featureWeight
		fi
		totalWeights=$((totalWeights + featureWeight))
		[ $DEBUG ] && echo "*** DEBUG: $0: totalWeights: $totalWeights" >&2
		featureNum=$((featureNum + 1))
	done
fi

# Find similar data bundles
featureNum=1
for featureNum in $totalFeatures; do
	tmpVar="FEATURE${featureNum}_NAME"
	eval featureName=\$$tmpVar
	tmpVar="FEATURE${featureNum}_TYPE"
	eval featureType=\$$tmpVar
	echo "Finding similar data bundles based on feature $featureName..."
#	if [ "$featureType" = "single" ]; then
#	elif [ "$featureType" = "multi" ]; then 	
#	else
#		echo "Unsupported feature type, exiting..."
#		exit 1
#	fi
	featureNum=$((featureNum + 1))
done

# Combine results based on weights
echo "Combining results based based on feature weights..."
echo "Overall similar data bundles to $bundle: <tbd>"

exit 0
