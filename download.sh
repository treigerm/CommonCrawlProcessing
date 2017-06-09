#!/bin/bash

set -e
set -o pipefail

setup() {
    local URL="$1"

    # Make directory for specified crawl
    mkdir -p ${1}/wet
    cd ${1}/wet

    # Download path file
    wget "${URL}"

    # Convert to HTTPS URLs
    gzip -cd wet.paths.gz | sed 's/^/https:\/\/commoncrawl.s3.amazonaws.com\//' > wet.paths.http

    # Make subdirectories
    for f in $(gzip -cd wet.paths.gz | cut -d '/' -f 4 | sort | uniq); do
        mkdir -p $f
    done
}

count_downloads() {
    # TODO: What is the input?
    total=0
    downloaded=0
    for path in $(cat $1); do
        total=$((total+1))
        FILENAME=$(echo $path | awk ' BEGIN { FS = "/" } { print $(NF-2) "/" $(NF)}')
        if [ -f ${FILENAME}.done ]; then
            downloaded=$((downloaded+1))
        fi
    done
    # TODO: Echo when not everything is downloaded.
}
