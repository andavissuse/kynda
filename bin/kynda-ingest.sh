#!/bin/sh

#
# This script builds feature datasets from data entries. 
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
sleep 1000
echo "Creating datasets ..."
mkdir -p $datasetsDir
# Option 1: data instances are provided in a directory
if [ -d "$DATA_LOC" ]; then
	for entry in `find $DATA_LOC -mindepth 1 -maxdepth 1`; do
		if [ ! -z "$PRE_EXECUTABLE" ]; then
			entry=`$PRE_EXECUTABLE $entry $tmpDir`
		fi
		[ $DEBUG ] && echo "*** DEBUG: $0: entry: $entry" >&2
		entryId=`$ID_EXECUTABLE $entry`
		[ $DEBUG ] && echo "*** DEBUG: $0: entryId: $entryId" >&2
		featureNum=1
		while true; do
			tmpVar="FEATURE${featureNum}_NAME"
			eval featureName=\$$tmpVar
			if [ -z "$featureName" ]; then
				break
			fi
			[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
			echo "Adding $featureName data from $entry to $featureName dataset ..."
			tmpVar="FEATURE${featureNum}_TYPE"
			eval featureType=\$$tmpVar
			[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
			tmpVar="FEATURE${featureNum}_EXECUTABLE"
			eval featureExecutable=\$$tmpVar
			[ $DEBUG ] && echo "*** DEBUG: $0: featureExecutable: $featureExecutable" >&2
			if [ "$featureType" = "ordinal" ]; then
				if [ ! -f $datasetsDir/$featureName.csv ]; then
					echo "id val" > $datasetsDir/$featureName.csv
				fi
				# encoding:  just create a file with ids and values
				featureVal=`$featureExecutable $entry`
				[ $DEBUG ] && echo "*** DEBUG: $0: featureVal: $featureVal" >&2
				echo "$entryId $featureVal" >> $datasetsDir/$featureName.csv
			else
				# encoding:  one-hot
				$featureExecutable $entry > $tmpDir/featureVals.tmp
				[ $DEBUG ] && python3 ./add_onehot.py -d ${datasetsDir}/${featureName}.csv $entryId $tmpDir/featureVals.tmp ||
				python3 ./add_onehot.py ${datasetsDir}/${featureName}.csv $entryId $tmpDir/featureVals.tmp
			fi
			featureNum=$((featureNum + 1))
		done
		rm -rf $entry
	done
fi
# Option 2: data instances are provided as rows in a file
if [ -f "$DATA_LOC" ]; then
	sed '1d' $DATA_LOC | while IFS= read -r entry; do
		[ $DEBUG ] && echo "*** DEBUG: $0: entry: $entry" >&2
		entryFile="${tmpDir}/entry.tmp"
		echo $entry >$entryFile
		entryId=`$ID_EXECUTABLE $entryFile`
		[ $DEBUG ] && echo "*** DEBUG: $0: entryId: $entryId" >&2
		featureNum=1
		while true; do
			tmpVar="FEATURE${featureNum}_NAME"
			eval featureName=\$$tmpVar
			if [ -z "$featureName" ]; then
				break
			fi
			[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
			dataset="${datasetsDir}/${featureName}.csv"
			[ $DEBUG ] && echo "*** DEBUG: $0: dataset: $dataset" >&2
			tmpVar="FEATURE${featureNum}_TYPE"
			eval featureType=\$$tmpVar
			[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
			tmpVar="FEATURE${featureNum}_EXECUTABLE"
			eval featureExecutable=\$$tmpVar
			[ $DEBUG ] && echo "*** DEBUG: $0: featureExecutable: $featureExecutable" >&2
			if [ "$featureType" = "ordinal" ]; then
                               if [ ! -f $datasetsDir/$featureName.csv ]; then
                                        echo "id val" > $datasetsDir/$featureName.csv
                                fi
				# encoding:  just create a file with ids and values
				featureVal=`$featureExecutable $entryFile`
				[ $DEBUG ] && echo "*** DEBUG: $0: featureVal: $featureVal" >&2
				echo "$entryId $featureVal" >> $dataset
			else
				# encoding:  one-hot
				$featureExecutable $entryFile > $tmpDir/featureVals.tmp
				[ $DEBUG ] && python3 ./add_onehot.py -d $dataset $entryId $tmpDir/featureVals.tmp ||
				python3 ./add_onehot.py $dataset $entryId $tmpDir/featureVals.tmp
			fi
			featureNum=$((featureNum + 1))
		done
		rm -rf $entryFile
	done
fi
rm -rf $tmpDir

exit 0
