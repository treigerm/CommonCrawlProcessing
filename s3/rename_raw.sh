#!/bin/bash

LANGUAGES="$1"
DELETIONS="$2"
DELETION_ERRORS="$3"
RENAMINGS="$4"
RENAMING_ERRORS="$5"

# TODO: Dry test run.
# TODO: Test move and delete commands.

for LANG in $(cat $LANGUAGES); do
    S3_RAW_BUCKET="s3://web-language-models/ngrams/${LANG}/raw"

    S3_2014_1="${S3_RAW_BUCKET}/${LANG}.2014_1.00.raw.xz"
    s3cmd info "${S3_2014_1}" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        #s3cmd del "${S3_2014_1}"
        if [[ $? -eq 0 ]]; then
            echo "${S3_2014_1}" >> ${DELETIONS}
        else
            echo "${S3_2014_1}" >> ${DELETION_ERRORS}
        fi
    else
        echo "${S3_2014_1}" >> ${DELETION_ERRORS}
    fi

    for ID in 2012 2013_1 2013_2; do
        S3_NAME="${S3_RAW_BUCKET}/${LANG}.${ID}.00.raw.xz"
        S3_NEW_NAME="${S3_RAW_BUCKET}/${LANG}.${ID}.raw.xz"
        s3cmd ls "${S3_NAME}" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            #s3cmd mv "${S3_NAME}" "${S3_NEW_NAME}"
            if [[ $? -eq 0 ]]; then
                echo "${S3_NAME} ${S3_NEW_NAME}" >> ${RENAMINGS}
            else
                echo "${S3_NAME}" >> ${RENAMING_ERRORS}
            fi
        else
            echo "${S3_NAME}" >> ${RENAMING_ERRORS}
        fi
    done
done
