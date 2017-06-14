#!/bin/bash

# Exit on error
set -e
set -o pipefail

# Default values.
PARALLELJOBS=8
CONFIGFILE=$HOME/commoncrawl/.config

# Locations of executables.
# TODO: Put executables into the script directory.
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONOLINGUAL_BIN=/fs/freyja0/commoncrawl/collect_monolingual.sh
DEDUPED_BIN=/home/tim/commoncrawl/dedupe.sh

main() {
    source "${SCRIPTDIR}/util.sh"
    parse_args $@
    load_config "${CONFIGFILE}"

    if [[ $EXTRACT_MONOLINGUAL -eq 1 ]]; then
        extract_monolingual
    fi
    if [[ $DEDUPE -eq 1 ]]; then
        dedupe
    fi
}

load_config() {
    # Load variables from config file and export the ones which are needed in other
    # scripts. Only use the value from the config file if the variable hasn't been
    # set before.
    source "${1}"
    if [[ -z ${WET_DIR+x} ]]; then WET_DIR="$wet_dir"; fi
    if [[ -z ${MONOLINGUAL_DIR+x} ]]; then MONOLINGUAL_DIR="$monolingual_dir"; fi
    if [[ -z ${DEDUPED_DIR+x} ]]; then DEDUPED_DIR="$deduped_dir"; fi
    if [[ -z ${LANGUAGES+x} ]]; then LANGUAGES="$languagesfile"; fi
    if [[ -z ${PREVIOUS_DEDUPED_DIR+x} ]]; then PREVIOUS_DEDUPED_DIR="$previous_deduped_dir"; fi
    export PREVIOUS_DEDUPED_DIR
}

print_help() {
    local APP="process_wet.sh"
    cat <<EOF
Usage:
$APP [options] (extract_monolingual|dedupe)...

-h, --help             display help
-W, --wet-dir          directory with downloaded WET data
-M, --monolingual-dir  directory to output data split according to language
-D, --deduped-dir      directory for output from deduper
-l, --languagesfile    file which specifies which languages to run the deduper on
-c, --config           custom configeration file
-j, --jobs             number of simultaneous jobs to run for GNU parallel
--sshloginfile         ssh file for GNU parallel
EOF
}

check_monolingual_opts() {
    if [[ -z "${WET_DIR}" ]] || [[ -z "${MONOLINGUAL_DIR}" ]]; then
        echo "To extract monolingual data the --wet-dir and --monolingual-dir options must be set." >&2
        exit 1
    fi
}

extract_monolingual() {
    check_monolingual_opts

    echo ""
    echo "Extracting monolingual data.."
    ls --hide=wet.* "${WET_DIR}" | \
        parallel ${PARALLEL_OPTIONS} ${MONOLINGUAL_BIN} "${WET_DIR}"/{} "${MONOLINGUAL_DIR}"/{}
}

check_dedupe_opts() {
    if [[ -z "${MONOLINGUAL_DIR}" ]] || [[ -z "${DEDUPED_DIR}" ]] || [[ -z "${LANGUAGES}" ]]; then
        echo "To run the deduper the --monolingual-dir, --deduped-dir and --languagesfile options must be set." >&2
        exit 1
    fi
}

dedupe() {
    # TODO: Implement sharding capability.
    # NOTE: Maybe implement that in deduper.
    # NOTE: Pseudo code for sharder:
    # Get all monolingual out and pipe it into sharder
    # use parallel to shard different files on different machines

    check_dedupe_opts

    # Description of the location of all files. We need to escape the asterix
    # because otherwise we already do file expansion when calling dedupe.sh.
    local MONO_FILES="${MONOLINGUAL_DIR}/\*/text.{}.gz"

    echo ""
    echo "Creating deduped files.."
    cat "${LANGUAGES}" | \
        parallel ${PARALLEL_OPTIONS} ${DEDUPED_BIN} ${MONO_FILES} ${DEDUPED_DIR} {}
}

main $@
