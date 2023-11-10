#!/bin/sh

#
# This script reads a onehot-encoded dataset and outputs the number of hits for each category.
#
# Inputs: onehot-encoded dataset (space-delimited csv)
# 	   
# Output: sorted list (descending) of categories and number of hits
#

# functions
function usage() {
	echo "Usage: `basename $0` [-h (usage)] [-d(ebug)] onehot-encoded-dataset"
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
elif [ ! -r "$1" ]; then
	echo "$0: Dataset $1 does not exist or is not readable, exiting ..."
	exit 1
else
	dataset="$1"
fi
tmpDir=`mktemp -d`

# Main
header=`head -1 $dataset`
position=2
while true; do
	rpmName=`echo $header | cut -d' ' -f${position}`
	if [ -z "$rpmName" ]; then
		break
	fi
	[ $DEBUG ] && echo "*** $DEBUG: $0: rpmName: $rpmName" >&2
	count=`awk -v colnum=${position} -F " " 'NR!=1{Total=Total+$colnum} END{print Total}' ${dataset}`
	[ $DEBUG ] && echo "*** $DEBUG: $0: count: $count" >&2
	echo "$rpmName $count" >> ${tmpDir}/rpmCounts.tmp
	position=$(( position + 1 ))
done
sort -k2 -n -r ${tmpDir}/rpmCounts.tmp
rm -rf $tmpDir

exit 0
