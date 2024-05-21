#!/bin/sh

#
# This script extracts keywords from error messages in a supportconfig data bundle (stored as
# a directory).  See https://www.suse.com/support/kb/doc/?id=000019214 for information on
# supportconfig data bundles.
#
# Inputs: 1) supportconfig directory
#
# Output: list of unique keywords (one per line)
#

# functions
function usage() {
        echo "Usage: `basename $0` [-d(ebug)] supportconfig-directory"
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
elif [ ! -d "$1" ]; then
        echo "Supportconfig directory $1 does not exist."
        exit 1
else
        scDir="$1"
fi

msgFile="$scDir/messages.txt"
if [ ! -f $msgFile ]; then
	[ $DEBUG ] && echo "*** DEBUG: $0: $msgFile does not exist, exiting..." >&2
	exit 1	
fi

tmpDir=`mktemp -d`
# get error lines
[ $DEBUG ] && echo "*** DEBUG: $0: getting error lines..." >&2
grep -i error "$msgFile" > "$tmpDir"/msgs.tmp

# get all words that are 4 characters or more
[ $DEBUG ] && echo "*** DEBUG: $0: getting words with 4 or more characters..." >$2
grep -o " [a-zA-Z]\{4,\} " "$tmpDir"/msgs.tmp | grep -o "\S*[g-z]\S*" | tr '[:upper:]' '[:lower:]' | sort -u > "$tmpDir"/words.tmp
# ignore prepositions and other common words
[ $DEBUG ] && echo "*** DEBUG: $0: removing prepositions and other common words..." >&2
grep -v -E "above|about|again|already|also|another|around|because|before|belong|between|cannot|could|does|doing|during|error|from|must|should|such|their|these|this|until|warn|warning|when|which|while|will|with|your" "$tmpDir"/words.tmp > "$tmpDir"/kwds.tmp
if [ ! -f $tmpDir/kwds.tmp ]; then
	rm -rf $tmpDir
	exit 1
fi
cat $tmpDir/kwds.tmp
rm -rf $tmpDir
exit 0
