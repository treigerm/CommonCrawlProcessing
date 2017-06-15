#!/bin/bash

# TODO: Rename file to precc.sh
# TODO: Add create_raw option to script.

# Exit on error
set -e
set -o pipefail

DEBUG=1

# Default values.
CONFIGFILE=$HOME/commoncrawl/.config

# Locations of executables.
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOWNLOAD_BIN=${SCRIPTDIR}/download_wet.sh
MONOLINGUAL_BIN=${SCRIPTDIR}/collect_monolingual.sh
UNSAFE_DEDUPE_BIN=${SCRIPTDIR}/unsafe_dedupe.sh


main() {
    source ${SCRIPTDIR}/util.sh
    parse_args "$@"
    load_config "${CONFIGFILE}"

    if [[ $SETUP -eq 1 ]]; then
        setup
    fi

    if [[ $DOWNLOAD -eq 1 ]]; then
        download
    fi

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
    if [[ -z ${CRAWL_URL+x} ]]; then CRAWL_URL="$crawl_url"; fi
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
$APP [options] (setup|download|extract_monolingual|dedupe)...

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

setup() {
    # Make directories for specified crawl.
    # TODO: Check wether directory names are provided.
    mkdir -p "${WET_DIR}"
    mkdir -p "${MONOLINGUAL_DIR}"
    mkdir -p "${DEDUPED_DIR}"
    cd "${WET_DIR}"

    # Download path file.
    wget -nc "${CRAWL_URL}"

    # Convert to HTTPS URLs.
    if [[ $DEBUG -eq 0 ]]; then
        gzip -cd wet.paths.gz | sed 's/^/https:\/\/commoncrawl.s3.amazonaws.com\//' > wet.paths.http
    else
        gzip -cd wet.paths.gz | sed 's/^/https:\/\/commoncrawl.s3.amazonaws.com\//' > paths.tmp
        head -2 "paths.tmp" > wet.paths.http
        rm "paths.tmp"
    fi

    # Make subdirectories.
    for f in $(cat wet.paths.http | cut -d '/' -f 7 | sort | uniq); do
        mkdir -p $f
    done
}

count_downloads() {
    TOTAL=0
    DOWNLOADED=0
    for path in $(cat "${WET_DIR}/wet.paths.http"); do
        TOTAL=$((TOTAL+1))
        # TODO: Explain awk expression.
        FILENAME=$(echo $path | awk 'BEGIN { FS = "/" } { print $(NF-2) "/" $(NF)}')
        if [ -f ${FILENAME}.done ]; then
            DOWNLOADED=$((DOWNLOADED+1))
        fi
    done
    DIFFERENCE=$((TOTAL-DOWNLOADED))
    if [[ "$DIFFERENCE" -ne 0 ]]; then
        echo "There are ${DIFFERENCE} files missing/incomplete"
    fi
}

download() {
    # TODO: Modify parallel options.

    cat "${WET_DIR}/wet.paths.http" | parallel ${PARALLEL_OPTIONS} ${DOWNLOAD_BIN}

    echo "Counting downloaded files.."
    while [[ $(count_downloads) ]]; do
        echo "Restarting downloads since there are missing files"
        cat "${WET_DIR}/wet.paths.http" | parallel ${PARALLEL_OPTIONS} ${DOWNLOAD_BIN}
        echo "Counting downloaded files.."
    done
    echo "All files downloaded"
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
        parallel ${PARALLEL_OPTIONS} ${UNSAFE_DEDUPE_BIN} ${MONO_FILES} ${DEDUPED_DIR} {}
}

main "$@"
