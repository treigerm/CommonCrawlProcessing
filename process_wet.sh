#!/bin/bash

# Exit on error
set -e
set -o pipefail

# TODO: Make parameter.
PARALLELJOBS=8

# Locations of executables.
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
DEDUPED_BIN=/home/tim/commoncrawl/dedupe.sh

# Parse arguments. Taken from
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash.
# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 1 ]]; do
    key="$1"

    # TODO: Add explanations of characters.
    case $key in
        -min|--monolingual-in)
            MONOLINGUAL_IN="$2"
            shift # past argument
            ;;
        -mout|--monolingual-out)
            MONOLINGUAL_OUT="$2"
            shift # past argument
            ;;
        -dout|--deduped-out)
            DEDUPED_OUT="$2"
            shift # past argument
            ;;
        -l|--languagesfile)
            LANGUAGESFILE="$2"
            shift # past argument
            ;;
        --sshloginfile)
            SSHLOGINFILE="$2"
            ;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done

#echo $MONOLINGUAL_IN
#echo $MONOLINGUAL_OUT
#echo $DEDUPED_OUT
#echo $LANGUAGESFILE
#echo $SSHLOGINFILE
#exit 0

if [[ ${SSHLOGINFILE} ]]; then
    PARALLEL_OPTIONS="--nice 19 --progress --sshloginfile ${SSHLOGINFILE} -j ${PARALLELJOBS}"
else
    PARALLEL_OPTIONS="--nice 19 --progress -j ${PARALLELJOBS}"
fi

COMMAND="
ls --hide=wet.* ${MONOLINGUAL_IN} | \
    parallel ${PARALLEL_OPTIONS} ${MONOLINGUAL_BIN} ${MONOLINGUAL_IN}/{} ${MONOLINGUAL_OUT}/{}
"

# Create monolingual data.
echo "Extracting monolingual data.."
ls --hide=wet.* "${MONOLINGUAL_IN}" | \
    parallel ${PARALLEL_OPTIONS} ${MONOLINGUAL_BIN} "${MONOLINGUAL_IN}"/{} "${MONOLINGUAL_OUT}"/{}

# TODO: Implement sharding capability.
# NOTE: Pseudo code for sharder:
# Get all monolingual out and pipe it into sharder
# use parallel to shard different files on different machines

# Description of the location of all files.
MONO_FILES="${MONOLINGUAL_OUT}/\*/text.{}.gz"

# Create deduped files.
echo ""
echo "Creating deduped files.."
cat "${LANGUAGESFILE}" | \
    parallel ${PARALLEL_OPTIONS} ${DEDUPED_BIN} ${MONO_FILES} ${DEDUPED_OUT} {}
