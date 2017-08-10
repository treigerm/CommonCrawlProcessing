#!/bin/bash

set -e
set -o pipefail

RAW_DIR="$1"
TMP_DIR="$2"

PREPROCESS_DIR="/fs/zisa0/tim/dev/preprocess/bin"
RAW_FILES="${RAW_DIR}/*.raw.xz"

TMP_PREFIX="en.tmp"
SHARD_COUNT=100

# Create named pipes
for i in $(seq 0 $((SHARD_COUNT-1))); do
    mkfifo "${TMP_DIR}/${TMP_PREFIX}${i}"
done

# Clean raw files and shard them into pipes
/fs/zisa0/tim/bin/xz -T10 -cd ${RAW_FILES} | \
    ${PREPROCESS_DIR}/commoncrawl_clean | \
    ${PREPROCESS_DIR}/shard_fifo ${TMP_DIR}/${TMP_PREFIX} ${SHARD_COUNT}
