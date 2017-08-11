#!/bin/bash

# TODO: Rename langsplit into langdetect and split into langsplit.

# NOTE: We can potentially speed up the download by using "parallel --keep-order curl"
#       instead of "xargs curl".
# Prelimaniry experiments with a batch size of 50:
#
# Non-parallel
# real    133m46.524s
# user    340m41.548s
# sys     4m6.260s
#
# using "parallel --keep-order -j10 curl -s"
# real    139m9.633s
# user    343m37.816s
# sys     5m20.612s



set -e
set -o pipefail

BATCH_PATH="$1"
BATCH_ID=$(basename "${BATCH_PATH}" | awk 'BEGIN {FS="."} {print $(NF-1) "." $(NF)}')

# Directory in which dependencies are located.
LIBDIR=${SCRIPTDIR}/lib

DONEFILE="${BATCH_PATH}/download.done"

if [[ ! -f ${DONEFILE} ]]; then
    cat "${BATCH_PATH}/wet.paths.${BATCH_ID}" | \
    parallel --keep-order -j10 curl -s | \
    gzip -cd | \
    ${LIBDIR}/read_wet.py | \
    ${LIBDIR}/langsplit --printchunks 2> /dev/null | \
    ${LIBDIR}/split_languages.py --outdir "${BATCH_PATH}"
    touch ${DONEFILE}
fi
