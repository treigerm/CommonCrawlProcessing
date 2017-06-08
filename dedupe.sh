#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

BINDIR=/fs/zisa0/commoncrawl

INFILES="$1"
OUTDIR="$2"
LANGUAGE="$3"

# There are two possible candidates for the name of the already existing deduped file.
DEDUPEDFILE_1="/fs/vali0/www/data.statmt.org/ngrams/deduped/${LANGUAGE}.deduped.xz"
DEDUPEDFILE_2="/fs/vali0/www/data.statmt.org/ngrams/deduped/${LANGUAGE}.xz"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${DEDUPEDFILE_1} ]]; then
    xzcat "${INFILES}" | ${BINDIR}/commoncrawl_dedupe "${DEDUPEDFILE_1}" | xz -c -9 > "${OUTFILE}"
elif [[ -f ${DEDUPEDFILE_2} ]]; then
    xzcat "${INFILES}" | ${BINDIR}/commoncrawl_dedupe "${DEDUPEDFILE_2}" | xz -c -9 > "${OUTFILE}"
else
    xzcat "${INFILES}" | ${BINDIR}/commoncrawl_dedupe /dev/null | xz -c -9 > "${OUTFILE}"
fi

touch "${DONEFILE}"

