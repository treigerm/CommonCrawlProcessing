#!/bin/bash

# Exit on error
set -e
set -o pipefail

# TODO: Make parameter.
PARALLELJOBS=8

# Locations of executables.
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
DEDUPED_BIN=/home/tim/commoncrawl/deduped.sh

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


# Create monolingual data.
ls hide=wet.* "${MONOLINGUAL_IN}" | \
    parallel --nice 19 --progress --sshloginfile "${SSHLOGINFILE}" -j "${PARALLELJOBS}" \
             ${MONOLINGUAL_BIN} "${MONOLINGUAL_IN}"/{} "${MONOLINGUAL_OUT}"/{}

# Create deduped files.
cat "${LANGUAGESFILE}" | \
    parallel --nice 19 -- progress --sshloginfile "${SSHLOGINFILE}" -j "${PARALLELJOBS}" \
             ${DEDUPED_BIN} "${MONOLINGUAL_OUT}"/*/text.{}.gz "${DEDUPED_OUT}" {}
