#!/bin/sh

#
# This script extracts a supportconfig name from a supportconfig data bundle (stored as
# a directory).  See https://www.suse.com/support/kb/doc/?id=000019214 for information on
# supportconfig data bundles.
#
# Inputs: 1) supportconfig directory
#
# Output: supportconfig name
#

# functions
function usage() {
        echo "Usage: `basename $0` [-d(ebug)] supportconfig-directory"
        exit $1
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
elif [ ! -d "$1" ]; then
        echo "Supportconfig directory $1 does not exist."
        exit 1
  else
        scDir="$1"
fi

# get supportconfig name from supportconfig.txt file
scFile="$scDir/supportconfig.txt"
if [ ! -f $scFile ]; then
        [ $DEBUG ] && echo "*** DEBUG: $0: $scFile does not exist, exiting..." >&2
        exit 1
fi
scName=`basename $(grep "Data Directory:" $scFile | cut -d: -f2)` 
echo $scName
