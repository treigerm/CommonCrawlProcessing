#!/bin/bash

FILE=$(basename $1 | sed 's/2013_2/2013_48/g' | sed 's/2013_1/2013_20/g')
LANGUAGE=$(echo ${FILE} | cut -d . -f 1)

BUCKET="s3://web-language-models/ngrams/${LANGUAGE}/raw/${FILE}"

/fs/zisa0/tim/dev/s3cmd/s3cmd put -q --continue-put --multipart-chunk-size-mb=1000 $1 ${BUCKET}
