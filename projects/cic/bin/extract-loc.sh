#!/bin/sh

#
# This script extracts the location field from a criminal incident data instance.
#
# Inputs: 1) criminal incident data instance (provided as csv-separated file)
#
# Output: List of locations
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

# get value(s) in location field
[ $DEBUG ] && echo "*** DEBUG: $0: instFile: $instFile" >&2
[ $DEBUG ] && echo "*** DEBUG: $0: getting location value(s)..." >&2
tod=`cat $instFile | cut -d ',' -f16` 
echo $tod

exit 0
