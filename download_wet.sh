#!/bin/bash

set -e
set -o pipefail

# Directory in which dependencies are located.
LIBDIR=${SCRIPTDIR}/lib

FILENAME=$(echo $1 | awk ' BEGIN { FS = "/" } { print $(NF-2) "/" $(NF)}')

if [ ! -f ${FILENAME}.done ]; then
  curl -s $1 | gzip -cd | \
  ${LIBDIR}/read_wet.py | \
  ${LIBDIR}/langsplit --printchunks 2> /dev/null | \
  xz -9 -e -T 2 > ${FILENAME}.langsplit.xz
  touch ${FILENAME}.done
fi
