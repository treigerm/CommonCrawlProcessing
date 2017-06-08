#!/bin/bash

# Exit on error
set -e
set -o pipefail

# Load variables from config file and export the ones which are needed in other
# scripts.
CONFIG_FILE=/home/tim/commoncrawl/.config
source "${CONFIG_FILE}"
export DEDUPED_DIR

# Default values.
PARALLELJOBS=8

# Locations of executables.
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
DEDUPED_BIN=/home/tim/commoncrawl/dedupe.sh

print_help() {
    local APP="process_wet.sh"
    cat <<EOF
Usage :
$APP [options]

-h, --help                display help
-min, --monolingual-in    directory with downloaded WET data
-mout, --monolingual-out  directory to output data split according to language
-dout, --dedupe-out       directory for output from deduper
-l,--languagesfile        file which specifies which languages to run the deduper on
--sshloginfile            ssh file for GNU parallel
EOF
}

# Parse arguments. Taken from
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash.
# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
while [[ $# -gt 0 ]]; do
    key="$1"

    # TODO: Add explanations of parameters.
    case $key in
        -h|--help)
            print_help
            exit 0
            ;;
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
        -j|--jobs)
            PARALLELJOBS="$2"
            shift # past argument
        --sshloginfile)
            SSHLOGINFILE="$2"
            shift # past argument
            ;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done

# TODO: Check wether all necessary command options are provided.

if [[ ${SSHLOGINFILE} ]]; then
    PARALLEL_OPTIONS="--nice 19 --progress --sshloginfile ${SSHLOGINFILE} -j ${PARALLELJOBS}"
else
    PARALLEL_OPTIONS="--nice 19 --progress -j ${PARALLELJOBS}"
fi

extract_monolingual() {
    echo ""
    echo "Extracting monolingual data.."
    ls --hide=wet.* "${MONOLINGUAL_IN}" | \
        parallel ${PARALLEL_OPTIONS} ${MONOLINGUAL_BIN} "${MONOLINGUAL_IN}"/{} "${MONOLINGUAL_OUT}"/{}
}

dedupe() {
    # TODO: Implement sharding capability.
    # NOTE: Maybe implement that in deduper.
    # NOTE: Pseudo code for sharder:
    # Get all monolingual out and pipe it into sharder
    # use parallel to shard different files on different machines

    # Description of the location of all files. We need to escape the asterix
    # because otherwise we already do file expansion when calling dedupe.sh.
    local MONO_FILES="${MONOLINGUAL_OUT}/\*/text.{}.gz"

    echo ""
    echo "Creating deduped files.."
    cat "${LANGUAGESFILE}" | \
        parallel ${PARALLEL_OPTIONS} ${DEDUPED_BIN} ${MONO_FILES} ${DEDUPED_OUT} {}
}

extract_monolingual
dedupe
