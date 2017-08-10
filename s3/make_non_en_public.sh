#!/bin/bash

RAW_DIR="/fs/vali0/www/data.statmt.org/ngrams/raw"
LANGS=$(ls ${RAW_DIR}/*.xz | awk 'BEGIN {FS="/"} {print $(NF)}' | cut -d '.' -f 1 | uniq)

for lang in $LANGS; do
    s3cmd setacl --acl-public -r "s3://web-language-models/ngrams/${lang}/"
done
