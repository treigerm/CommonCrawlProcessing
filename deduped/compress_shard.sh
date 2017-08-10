#!/bin/bash

set -e
set -o pipefail

ID="$1"
SHARD_DIR="$2"
OUT_DIR="$3"

INPUT_FILE="${SHARD_DIR}/en.tmp${ID}"
OUTPUT_FILE="${OUT_DIR}/en.tmp${ID}.gz"
DONEFILE="${OUTPUT_FILE}.done"

if [[ -f "${DONEFILE}" ]]; then
    exit 0
fi

< "${INPUT_FILE}" gzip -c > "${OUTPUT_FILE}"

touch "${DONEFILE}"
