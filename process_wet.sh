#!/bin/bash

# Exit on error
set -e
set -o pipefail

# TODO: Argument list:
# Input for monolingual
# Output for monolingual
# sshloginfile
# Output for deduped

# TODO: Make parameter.
PARALLELJOBS=8
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
# Directory of already existing deduplicated files.
DEDUPED_FILES="/fs/vali0/www/data.statmt.org/ngrams/deduped"
# Executable for creating the deduped files.
# TODO: Adjust it such that it takes in the required parameters.
DEDUPED_BIN=/home/tim/dev/process/deduped.sh

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

    # TODO: Adjust one character options.
    # TODO: Add explanations of characters.
    case $key in
        -e|--monolingual-in)
            MONOLINGUAL_IN="$2"
            shift # past argument
            ;;
        -s|--monolingual-out)
            MONOLINGUAL_OUT="$2"
            shift # past argument
            ;;
        -l|--deduped-out)
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
