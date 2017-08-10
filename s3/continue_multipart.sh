#!/bin/bash

set -e
set -o pipefail

s3cmd multipart s3://web-language-models/ngrams/raw_en/ | \
    grep -o "en.[^/]*.xz" | \
    parallel --nice 19 --progress -j 8 s3cmd put --continue-put {} s3://web-language-models/ngrams/en/raw/{}
