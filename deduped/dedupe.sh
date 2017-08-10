#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

# Parallel command:
# cat language.codes | parallel ./dedupe.sh ${infile} ${outdir} {} ${previous_deduped}

DEDUPE_BIN=/fs/zisa0/tim/dev/preprocess/bin/commoncrawl_dedupe

INFILE="$1"
OUTDIR="$2"
LANGUAGE="$3"
PREVIOUS_DEDUPED="$4"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${DEDUPEDFILE} ]]; then
    xz -cd "${INFILE}" | ${DEDUPE_BIN} "${PREVIOUS_DEDUPED}" | xz -c > "${OUTFILE}"
else
    xz -cd "${INFILE}" | ${DEDUPE_BIN} /dev/null | xz -c > "${OUTFILE}"
fi

touch "${DONEFILE}"

