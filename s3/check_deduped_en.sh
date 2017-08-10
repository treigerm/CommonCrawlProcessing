#!/bin/bash

set -e
set -o pipefail

for i in $(seq -f "%02g" 0 99); do
    SOURCEFILE="s3://web-language-models/ngrams/deduped/en/en.${i}.deduped.xz"
    TARGETFILE="s3://web-language-models/ngrams/en/deduped/en.${i}.deduped.xz"
    SOURCESIZE=$(s3cmd ls ${SOURCEFILE} | cut -d ' ' -f 3)
    TARGETSIZE=$(s3cmd ls ${TARGETFILE} | cut -d ' ' -f 3)
    if [[ ! ${SOURCESIZE} -eq ${TARGETSIZE} ]]; then
        echo "Mismatch on file ${SOURCEFILE}"
    fi
done
