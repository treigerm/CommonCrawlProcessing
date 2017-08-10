#!/bin/bash

set -e
set -o pipefail

DOWNLOAD_DIR="$1"
CRAWL_URL="$2"
BATCH_SIZE="$3"

cd "${DOWNLOAD_DIR}"

# Download path file.
wget -nc "${CRAWL_URL}"

# Convert to HTTPS URLs.
gzip -cd wet.paths.gz | sed 's/^/https:\/\/commoncrawl.s3.amazonaws.com\//' > wet.paths.http


echo ""
echo "Creating batches.."
# "wet.paths.http" contains the urls which point to all the files for this specific crawl. We split
# up "wet.paths.http" into smaller batches each batch containing BATCH_SIZE crawls and create
# a subdirectory for each batch which will contain the processed data.
BATCH_NR=0
CURRENT_BATCH_SIZE=0
BATCH_ID=$(printf "batch.%05d" ${BATCH_NR})
CURRENT_BATCH_FILE="${DOWNLOAD_DIR}/${BATCH_ID}/wet.paths.${BATCH_ID}"
mkdir -p "${BATCH_ID}"
touch "${CURRENT_BATCH_FILE}"
for url in $(cat wet.paths.http); do
    if [[ ${CURRENT_BATCH_SIZE} -ge ${BATCH_SIZE} ]]; then
        CURRENT_BATCH_SIZE=0
        BATCH_NR=$((BATCH_NR+1))
        BATCH_ID=$(printf "batch.%05d" ${BATCH_NR})
        CURRENT_BATCH_FILE="${DOWNLOAD_DIR}/${BATCH_ID}/wet.paths.${BATCH_ID}"
        mkdir -p "${BATCH_ID}"
        touch "${CURRENT_BATCH_FILE}"
    fi

    echo $url >> "${CURRENT_BATCH_FILE}"
    CURRENT_BATCH_SIZE=$((CURRENT_BATCH_SIZE+1))
done
