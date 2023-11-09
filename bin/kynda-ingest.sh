#!/bin/sh

#
# This script builds feature datasets from data bundles. 
#
# Inputs:
# 	kynda project configuration file (created by kynda-setup.sh)
#
# Output: datasets in <project-directory>/datasets directory 
#

# functions
function usage() {
	echo "Usage: `basename $0` [-h (usage)] [-d(ebug)] project-configuration-file"
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
if [ ! "$1" ]; then
        usage >&2
        exit 1
elif [ ! -r "$1" ]; then
	echo "$0: Project configuration file $1 does not exist, exiting ..." >&2
	exit 1
else
	confFile="$1"
fi

# Source the configuration file and set variables
source $confFile
datasetsDir="${PROJECT_DIR}/datasets"
tmpDir=`mktemp -d`

# Build the datasets
echo "Creating datasets ..."
mkdir $datasetsDir
for bundle in `find $DATA_DIR -mindepth 1 -maxdepth 1`; do
	if [ ! -z "$PRE_EXECUTABLE" ]; then
	       bundle=`$PRE_EXECUTABLE $bundle $tmpDir`
	fi
	[ $DEBUG ] && echo "*** DEBUG: $0: bundle: $bundle" >&2
	bundleId=`$ID_EXECUTABLE $bundle`
	[ $DEBUG ] && echo "*** DEBUG: $0: bundleId: $bundleId" >&2
	featureNum=1
	while true; do
		tmpVar="FEATURE${featureNum}_NAME"
		eval featureName=\$$tmpVar
		if [ -z "$featureName" ]; then
			break
		fi
		[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
		echo "Adding $featureName data from $bundle to $featureName dataset ..."
		tmpVar="FEATURE${featureNum}_TYPE"
		eval featureType=\$$tmpVar
		[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
		tmpVar="FEATURE${featureNum}_EXECUTABLE"
		eval featureExecutable=\$$tmpVar
		[ $DEBUG ] && echo "*** DEBUG: $0: featureExecutable: $featureExecutable" >&2
		if [ "$featureType" = "ordinal" ]; then
			# encoding:  just create a file with ids and values
			featureVal=`$featureExecutable $bundle`
			[ $DEBUG ] && echo "*** DEBUG: $0: featureVal: $featureVal" >&2
			echo "$bundleId $featureVal" >> $datasetsDir/$featureName.csv
		else
			# encoding:  one-hot
			$featureExecutable $bundle > $tmpDir/featureVals.tmp
			[ $DEBUG ] && python3 ./dataset_onehot.py -d ${datasetsDir}/${featureName}.csv $bundleId $tmpDir/featureVals.tmp ||
			python3 ./dataset_onehot.py ${datasetsDir}/${featureName}.csv $bundleId $tmpDir/featureVals.tmp
		fi
		featureNum=$((featureNum + 1))
	done
	rm -rf $bundle
done
rm -rf $tmpDir

exit 0
