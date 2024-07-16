#!/bin/sh

#
# This script extracts incident modus operandi (MO) from a criminal incident data instance.
#
# Inputs: 1) criminal incident data instance (provided as csv-separated file)
#
# Output: List of MOs
#

# functions
function usage() {
        echo "Usage: `basename $0` [-d(ebug)] instance-file"
        exit $1
}

function exitError() {
        echo "$1"
        [ ! -z "$tmpDir" ] && rm -rf $tmpDir
        exit 1
}

# arguments
if [ "$1" = "--help" ]; then
        usage 0
fi
while getopts 'hd' OPTION; do
        case $OPTION in
                h)
                        usage 0
                        ;;
                d)
                        DEBUG=1
			;;
        esac
done
shift $((OPTIND - 1))
if [ ! "$1" ]; then
        usage 1
elif [ ! -r "$1" ]; then
	echo "Instance file $instFile does not exist or is not readable, exiting..."
	exit 1
else
        instFile="$1"
fi
binDir=`dirname $0`
[ $DEBUG ] && echo "*** DEBUG: $0: binDir: $binDir" >&2
[ $DEBUG ] && echo "*** DEBUG: $0: instFile: $instFile" >&2

# get data in relevant fields
fieldNums="10"
[ $DEBUG ] && echo "*** DEBUG: $0: getting modus operandi (MOs)..." >&2
for fieldNum in $fieldNums; do
	[ $DEBUG ] && echo "*** DEBUG: $0: fieldNum: $fieldNum" >&2
	fieldVal=`python3 "$binDir"/csv_field.py $instFile $fieldNum`
	[ $DEBUG ] && echo "*** DEBUG: $0: fieldVal: $fieldVal" >&2
	for mo in $fieldVal; do
		echo $mo
	done
done
exit 0
