#!/bin/bash

set -e
set -o pipefail

WET_DIR="$1"
RAW_DIR="$2"
LANG="$3"
CRAWL_ID="$4"

RAW_FILE="${RAW_DIR}/${LANG}.${CRAWL_ID}.raw.xz"
DONEFILE="${RAW_FILE}.done"
if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ ! -f ${RAW_FILE} ]]; then
    touch ${RAW_FILE}
fi

for BATCH in $(find "${WET_DIR}" -maxdepth 1 -name "batch.*" -type d | sort); do
    if [[ ! -f "${BATCH}/download.done" ]]; then
        # Exit if the download for this batch hasn't finished.
        exit 1
    fi

    BATCH_DONEFILE="${BATCH}/${LANG}.raw.done"
    if [[ ! -f ${BATCH_DONEFILE} ]]; then
        cat "${BATCH}/text.${LANG}.xz" >> ${RAW_FILE}
        touch ${BATCH_DONEFILE}
    fi
done

touch ${DONEFILE}
