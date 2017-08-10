#!/bin/bash

set -e
set -o pipefail

# Non-zero padded id.
ID="$1"
SHARD_DIR="$2"
PREVIOUS_DEDUPED_DIR="$3"
OUT_DIR="$4"

PREPROCESS_DIR="/fs/zisa0/tim/dev/preprocess/bin"

PADDED_ID=$(printf "%02d" ${ID})
INPUT_FILE="${SHARD_DIR}/en.tmp${ID}"
OUTPUT_FILE="${OUT_DIR}/en.${PADDED_ID}.deduped.xz"
DONEFILE="${OUTPUT_FILE}.done"

PREVIOUS_DEDUPED_FILE="${PREVIOUS_DEDUPED_DIR}/en.${PADDED_ID}.deduped.xz"

if [[ -f "${DONEFILE}" ]]; then
    exit 0
fi


<"${INPUT_FILE}" ${PREPROCESS_DIR}/commoncrawl_dedupe ${PREVIOUS_DEDUPED_FILE} | xz > "${OUTPUT_FILE}"

rm "${INPUT_FILE}"

touch "${DONEFILE}"
