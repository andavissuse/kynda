#!/bin/sh

#
# This script builds feature datasets from data bundles. 
#
# Inputs: kynda-<project-name>.conf file 
#
# Output: datasets in <project-name>/datasets directory 
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
if [ ! "$1" ]; then
        usage >&2
        exit 1
else
        projName="$1"
fi

# Source the configuration file
confFile="./$projName/$projName.conf"
if [ ! -r "$confFile" ]; then
	echo "$0: Project configuration file $confFile does not exist, exiting..." >&2
	exit 1
fi
source $confFile

# Build the datasets
tmpDir=`mktemp -d`
datasetsDir="./${projName}/datasets"
mkdir $datasetsDir
for bundle in `find $DATA_DIR -mindepth 1 -maxdepth 1`; do
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
		tmpVar="FEATURE${featureNum}_TYPE"
		eval featureType=\$$tmpVar
		[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
		tmpVar="FEATURE${featureNum}_EXECUTABLE"
		eval featureExecutable=\$$tmpVar
		[ $DEBUG ] && echo "*** DEBUG: $0: featureExecutable: $featureExecutable" >&2
		if [ "$featureType" = "single" ]; then
			featureVal=`$featureExecutable $bundle`
			echo "$bundleId $featureVal" >> $datasetsDir/$featureName.csv
		else
			$featureExecutable $bundle > $tmpDir/featureVals.tmp
			[ $DEBUG ] && python3 ./common/dataset_onehot.py -d ${datasetsDir}/${featureName}.csv $bundleId $tmpDir/featureVals.tmp ||
			python3 ./common/dataset_onehot.py ${datasetsDir}/${featureName}.csv $bundleId $tmpDir/featureVals.tmp
		fi
		featureNum=$((featureNum + 1))
	done
done
rm -rf $tmpDir

exit 0
			


