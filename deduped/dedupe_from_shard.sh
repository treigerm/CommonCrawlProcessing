#!/bin/bash

set -e
set -o pipefail

# Parallel command:
# seq 0 99 | parallel ./dedupe_from_shard.sh {} ${shard_dir} ${previous_deduped_dir} ${out_dir}

DEDUPE_BIN=/fs/zisa0/tim/dev/preprocess/bin/commoncrawl_dedupe

# Non-zero padded id.
ID="$1"
SHARD_DIR="$2"
PREVIOUS_DEDUPED_DIR="$3"
OUT_DIR="$4"

# The sharded from https://github.com/kpu/preprocess uses non-zero padded ids for the shard. But the
# deduped files uses zero padded ids.
PADDED_ID=$(printf "%02d" ${ID})
INPUT_FILE="${SHARD_DIR}/en.tmp${ID}.gz"
OUTPUT_FILE="${OUT_DIR}/en.${PADDED_ID}.deduped.xz"
DONEFILE="${OUTPUT_FILE}.done"

PREVIOUS_DEDUPED_FILE="${PREVIOUS_DEDUPED_DIR}/en.${PADDED_ID}.deduped.xz"

if [[ -f "${DONEFILE}" ]]; then
    exit 0
fi


gzip -cd "${INPUT_FILE}" | ${DEDUPE_BIN} "${PREVIOUS_DEDUPED_FILE}" | xz > "${OUTPUT_FILE}"

touch "${DONEFILE}"
