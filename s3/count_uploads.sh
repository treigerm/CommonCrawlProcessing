#!/bin/bash

TOTAL=0
UPLOADED=0
echo -n "${TOTAL}"
for filepath in /fs/vali0/www/data.statmt.org/ngrams/raw/*.xz; do
    TOTAL=$((TOTAL+1))
    echo -en "\e[1A"; echo -e "\e[0K\r ${TOTAL}"
    FILE=$(echo $filepath | awk ' BEGIN { FS = "/" } { print $(NF) }')
    LANGUAGE=$(echo ${FILE} | awk ' BEGIN { FS = "." } { print $1 }')
    YEAR=$(echo ${FILE} | awk ' BEGIN {FS = "." } { print $2 }')
    VERSION="00"

    NEW_FILENAME=$(echo ${FILE} | sed  "s/[0-9_]\{1,\}/${YEAR}.${VERSION}/")
    BUCKET="s3://web-language-models/ngrams/${LANGUAGE}/raw/${NEW_FILENAME}"

    # Increase counter if file already exists.
    if [[ ! -z $(/home/tim/bin/s3cmd/s3cmd ls ${BUCKET}) ]]; then
        UPLOADED=$((UPLOADED+1))
    fi
done

echo -en "\e[1A"; echo -e "\e[0K\r ${UPLOADED}/${TOTAL}"
