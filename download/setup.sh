#!/bin/bash

set -e
set -o pipefail


YEAR=$(echo $1 | awk ' BEGIN { FS = "_" } { print $1 }')
WEEK=$(echo $1 | awk ' BEGIN { FS = "_" } { print $2 }')

# Make directory for specified crawl
mkdir -p ${1}/wet
cd ${1}/wet

# Download path file
wget https://commoncrawl.s3.amazonaws.com/crawl-data/CC-MAIN-${YEAR}-${WEEK}/wet.paths.gz

# Convert to HTTPS URLs
gzip -cd wet.paths.gz | sed 's/^/https:\/\/commoncrawl.s3.amazonaws.com\//' > wet.paths.http

# Make subdirectories
for f in `gzip -cd wet.paths.gz | cut -d '/' -f 4 | sort | uniq`; do mkdir -p $f; done;
