#!/bin/bash

# Exit on error
set -e
set -o pipefail

# Default values.
PARALLELJOBS=8
CONFIGFILE=/home/tim/commoncrawl/.config

# Locations of executables.
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
DEDUPED_BIN=/home/tim/commoncrawl/dedupe.sh

load_config() {
    # Load variables from config file and export the ones which are needed in other
    # scripts.
    source "${1}"
    # TODO: Rename options.
    MONOLINGUAL_IN="$monolingual_in"
    MONOLINGUAL_OUT="$monolingual_out"
    DEDUPED_OUT="$deduped_out"
    LANGUAGES="$languagesfile"
    DEDUPED_DIR="$deduped_dir"
    export DEDUPED_DIR
}

print_help() {
    local APP="process_wet.sh"
    cat <<EOF
Usage :
$APP [options]

-h, --help             display help
-W, --wet-dir          directory with downloaded WET data
-M, --monolingual-dir  directory to output data split according to language
-D, --deduped-dir      directory for output from deduper
-l,--languagesfile     file which specifies which languages to run the deduper on
--sshloginfile         ssh file for GNU parallel
EOF
}

parse_args() {
    if [[ $# -eq 0 ]]; then
        print_help
        exit 1
    fi

    # Parse arguments. Taken from
    # https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash.
    local SHORT=hW:M:D:l:j:c:
    local LONG=help,wet-dir:,monolingual-dir:,deduped-dir:,languagesfile:,sshloginfile:,jobs:,config:

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    local PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -h|--help)
                print_help
                exit 0
                ;;
            -W|--wet-dir)
                MONOLINGUAL_IN="$2"
                shift 2
                ;;
            -M|--monolingual-dir)
                MONOLINGUAL_OUT="$2"
                shift 2
                ;;
            -D|--deduped-dir)
                DEDUPED_OUT="$2"
                shift 2
                ;;
            -l|--languagesfile)
                LANGUAGES="$2"
                shift 2
                ;;
            -c|--config)
                CONFIGFILE="$2"
                shift 2
                ;;
            -j|--jobs)
                PARALLELJOBS="$2"
                shift 2
                ;;
            --sshloginfile)
                SSHLOGINFILE="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unexpected error"
                exit 1
                ;;
        esac
    done

    # TODO: Check wether all necessary command options are provided.
    # TODO: Do list of possible commands.

    if [[ ${SSHLOGINFILE} ]]; then
        PARALLEL_OPTIONS="--nice 19 --progress --sshloginfile ${SSHLOGINFILE} -j ${PARALLELJOBS}"
    else
        PARALLEL_OPTIONS="--nice 19 --progress -j ${PARALLELJOBS}"
    fi
}

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
    cat "${LANGUAGES}" | \
        parallel ${PARALLEL_OPTIONS} ${DEDUPED_BIN} ${MONO_FILES} ${DEDUPED_OUT} {}
}

# TODO: Figure out how to not overwrite variables when loading config.
load_config "${CONFIGFILE}"
parse_args $@
extract_monolingual
dedupe
