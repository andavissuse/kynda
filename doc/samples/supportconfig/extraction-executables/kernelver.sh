#!/bin/sh

#
# This script extracts the kernel version from a supportconfig data bundle (stored as
# a directory).  See https://www.suse.com/support/kb/doc/?id=000019214 for information on
# supportconfig data bundles.
#
# Inputs: 1) supportconfig directory
#
# Output: Kernel version
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

# get kernel (uname output) from basic-environment.txt file
basicEnvFile="$scDir/basic-environment.txt"
if [ ! -f $basicEnvFile ]; then
	[ $DEBUG ] && echo "*** DEBUG: $0: $basicEnvFile does not exist, exiting..." >&2
        exit 1
fi
unameSectionLine=`cat $basicEnvFile | grep -n "^# /bin/uname -a$" | cut -d":" -f1`
	[ $DEBUG ] && echo "*** DEBUG: $0: unameSectionLine: $unameSectionLine" >&2
kernel=`sed "$((${unameSectionLine}+1))q;d" $basicEnvFile |
		cut -d" " -f3`
kernelVer="${kernel%-*}"
if ! echo "$kernelVer" | grep -q "^[0-9]"; then
	[ $DEBUG ] && echo "*** DEBUG: $0: kernelVer is not numeric, exiting..." >&2
	exit 1
fi
echo "$kernelVer"
exit 0 
