#!/bin/bash

# TODO: Rename langsplit into langdetect and split into langsplit.

set -e
set -o pipefail

BATCH_PATH="$1"
BATCH_ID=$(basename "${BATCH_PATH}" | awk 'BEGIN {FS="."} {print $(NF-1) "." $(NF)}')

# Directory in which dependencies are located.
LIBDIR=${SCRIPTDIR}/lib

DONEFILE="${BATCH_PATH}/download.done"

if [[ ! -f ${DONEFILE} ]]; then
  cat "${BATCH_PATH}/wet.paths.${BATCH_ID}" | xargs curl -s | gzip -cd | \
  ${LIBDIR}/read_wet.py | \
  ${LIBDIR}/langsplit --printchunks 2> /dev/null | \
  ${LIBDIR}/split_languages.py --outdir "${BATCH_PATH}"
  touch ${DONEFILE}
fi
