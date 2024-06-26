#!/bin/sh

#
# This script searches feature datasets to find data instances that meet specific per-feature
# search parameters (=, <, >, ~).   
#
# Inputs: project-configuration-dir
# 	  data-instance
# 	   
# Output: data instances (one per line) that meet search parameters
#

# functions
function usage() {
	echo "Usage: `basename $0` [-h (usage)] [-d(ebug)] project-configuration-dir data-instance"
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
	echo "$0: Data instance $2 does not exist or is not readable, exiting ..."
	exit 1
else
	confFile="$1"
	inst="$2"
fi

# Source the configuration file
source $confFile
datasetsDir="${PROJECT_DIR}/datasets"

# Build the featureName, featureType, and featureExecutable arrays
echo "Getting total number of features from config file ..."
featureNum=1
numSingleValuedFeatures=0
numMultiValuedFeatures=0
featureNameArray=""
featureTypeArray=""
while true; do
	tmpVar="FEATURE${featureNum}_NAME"
	eval featureName=\$$tmpVar
	if [ -z "$featureName" ]; then
		break
	fi
	featureNameArray="$featureNameArray $featureName"
	[ $DEBUG ] && echo "*** DEBUG: $0: featureNameArray: $featureNameArray" >&2
	tmpVar="FEATURE${featureNum}_TYPE"
	eval featureType=\$$tmpVar
	featureTypeArray="$featureTypeArray $featureType"
	[ $DEBUG ] && echo "*** DEBUG: $0: featureTypeArray: $featureTypeArray" >&2
	if echo $featureType | grep -q "mv"; then
		numMultiValuedFeatures=$((numMultiValuedFeatures + 1))
	else
		numSingleValuedFeatures=$((numSingleValuedFeatures + 1))
	fi	
        tmpVar="FEATURE${featureNum}_EXECUTABLE"
        eval featureExecutable=\$$tmpVar
        featureExecutableArray="$featureExecutableArray $featureExecutable"
        [ $DEBUG ] && echo "*** DEBUG: $0: featureExecutableArray: $featureExecutableArray" >&2
	featureNum=$((featureNum + 1))
done

# Set default search parameter and weight
defSP="="
defWeight=$((100 / numMultiValuedFeatures))
[ $DEBUG ] && echo "*** DEBUG: $0: defSP: $defSP, defWeight: $defWeight" >&2
echo "Number of single-valued features: $numSingleValuedFeatures."
echo "Number of multi-valued (weightable) features: $numMultiValuedFeatures."

# Let user override default search parameters and weights
echo "The following section can be used to override default search parameters and weights."
echo "Default search parameter for single-valued features: \"=\"."
echo "Default weight for each multi-valued feature: $defWeight%."
echo "Weight for each multi-valued feature may be changed,"
echo "but sum of weights for all multi-valued features must equal 100%."
featureNum=1
featureParameterArray=""
for featureName in $featureNameArray; do
	featureType=`echo $featureTypeArray | cut -d' ' -f${featureNum}`
	[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName" >&2
	[ $DEBUG ] && echo "*** DEBUG: $0: featureType: $featureType" >&2
	case $featureType in
		nsv)
			echo -n "$featureName search parameter (=/!=/</>/<=/>=/~)? "
			read featureSP
			if [ -z "$featureSP" ]; then
				featureSP="$defSP"
			fi
			featureParameter="$featureSP"
			;;
		tsv)
			echo -n "$featureName search parameter (=/!=)? "
			read featureSP
			if [ -z "$featureSP" ]; then
				featureSP="$defSP"
			fi
			featureParameter="$featureSP"
			;;
		*mv)
			echo -n "$featureName weight (0-100)? "
			read featureWeight
			if [ -z "$featureWeight" ]; then
				featureWeight="$defWeight"
			fi
			featureParameter="$featureWeight"
			;;
		*)
			;;
	esac
	featureParameterArray="$featureParameterArray $featureParameter"
	[ $DEBUG ] && echo "*** DEBUG: $0: featureParameterArray: $featureParameterArray" >&2
	featureNum=$((featureNum + 1))
done

# Find similar data instances 
echo "Finding similar data instances..."
featureNum=1
for featureName in $featureNameArray; do
	featureType=`echo $featureTypeArray | cut -d' ' -f${featureNum}`
	featureParameter=`echo $featureParameterArray | cut -d' ' -f${featureNum}`
	featureExecutable=`echo $featureExecutableArray | cut -d' ' -f${featureNum}`
	featureDataset="${datasetsDir}/${featureName}.csv"
	[ $DEBUG ] && echo "*** DEBUG: $0: featureName: $featureName, featureType: $featureType, featureParameter: $featureParameter, featureExecutable: $featureExecutable, featureDataset: $featureDataset" >&2
	echo "Extracting $featureName data from $inst..."
	featureVal=`$featureExecutable $inst`
	[ $DEBUG ] && echo "*** DEBUG: $0: featureVal: $featureVal" >&2
	case $featureType in
		nsv)
			case $featureParameter in
				'=')
					operator="-eq"
					;;
				'!=')
					operator="-ne"
					;;
				'<')
					operator="-lt"
					;;
				'>')
					operator="-gt"
					;;
				'<=')
					operator="-le"
					;;
				'>=')
					operator="-ge"
					;;
				*)
					echo "Unsupported operator."
					;;
			esac
			[ $DEBUG ] && echo "*** DEBUG: $0: operator: $operator" >&2
			echo "Searching based on feature $featureName..."
			featureMatchList=""
			while IFS= read -r line; do
				[ $DEBUG ] && echo "*** DEBUG: $0: line: $line" >&2
				dataVal=`echo $line | cut -d' ' -f2`
				[ $DEBUG ] && echo "*** DEBUG: $0: dataVal: $dataVal" >&2
				if [ "$dataVal" $operator "$featureVal" ]; then
					matchId=`echo $line | cut -d' ' -f1`
					featureMatchList="$featureMatchList $matchId"
				fi
			done < $featureDataset
			[ $DEBUG ] && echo "*** DEBUG: $0: featureMatchList: $featureMatchList" >&2
			;;
		tsv)
			operator="$featureParameter"
			[ $DEBUG ] && echo "*** DEBUG: $0: operator: $operator" >&2
			echo "Searching based on feature $featureName..."
			featureMatchList=""
			while IFS= read -r line; do
				[ $DEBUG ] && echo "*** DEBUG: $0: line: $line" >&2
				dataVal=`echo $line | cut -d' ' -f2`
				[ $DEBUG ] && echo "*** DEBUG: $0: dataVal: $dataVal" >&2
				if [ "$dataVal" $operator "$featureVal" ]; then
					matchId=`echo $line | cut -d' ' -f1`
					featureMatchList="$featureMatchList $matchId"
				fi
			done < $featureDataset
			[ $DEBUG ] && echo "*** DEBUG: $0: featureMatchList: $featureMatchList" >&2
			;;
		nmv)
			;;
		tmv)
			;;
		*)
			;;
	esac
	featureNum=$((featureNum + 1))
done

# Combine results based on weights
echo "Combining results based based on search parameters and feature weights ..."
echo "Overall similar data instances to $inst: <tbd>"

exit 0
