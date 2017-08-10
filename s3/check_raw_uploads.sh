#!/bin/bash

set -e
set -o pipefail

FILE=$(echo $1 | awk ' BEGIN { FS = "/" } { print $(NF) }')

BUCKET="s3://web-language-models/ngrams/en/raw/${FILE}"

MD5SUM1=$(echo $(/home/tim/bin/s3cmd/s3cmd ls --list-md5 ${BUCKET}) | awk 'BEGIN { FS = " " } {print $(NF-1)}')
MD5SUM2=$(md5sum $1 | awk 'BEGIN { FS = " " } {print $1}')
if [ ${MD5SUM1} != ${MD5SUM2} ]; then
    echo "$1"
fi
