#!/bin/bash

set -e

FILE="$1"
LANG=$(basename $FILE | cut -d . -f 1)

/home/tim/bin/s3cmd/s3cmd del "s3://web-language-models/ngrams/${LANG}/deduped/${LANG}.deduped.xz"
/home/tim/bin/s3cmd/s3cmd put --multipart-chunk-size-mb=1000 "${FILE}" "s3://web-language-models/ngrams/${LANG}/deduped/"
