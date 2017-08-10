#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

DEDUPED="$1"
NEW_DEDUPED="$2"
OFFSET_FILE="$3"
CRAWL_ID="$4"

# NOTE: Offset file format (one file for each language). Offset shows where each crawl ends.
#       Each crawl begins at the offset from the previous line.
# {Crawl_ID} {offset1}
# {Crawl_ID} {offset2}

# Concat old deduped and new deduped.
cat "${NEW_DEDUPED}" >> "${DEDUPED}"

# Write new size to offset file.
NEW_SIZE=$(stat --printf="%s" "${DEDUPED}")
echo "${CRAWL_ID} ${NEW_SIZE}" >> "${OFFSET_FILE}"
