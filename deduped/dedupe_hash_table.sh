#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

# Parallel command:
# cat language.codes | parallel ./dedupe_hash_table.sh ${infile} ${outdir} {} ${src_hash_table} ${out_hash_table} ${previous_deduped}

DEDUPE_BIN=/fs/zisa/tim/dev/preprocess/bin/commoncrawl_dedupe_save_table

INFILE="$1"
OUTDIR="$2"
LANGUAGE="$3"
SRC_HASH_TABLE="$4"
OUT_HASH_TABLE="$5"
PREVIOUS_DEDUPED="$6"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${PREVIOUS_DEDUPED} ]]; then
    xz -cd ${INFILE} | ${DEDUPE_BIN} "${PREVIOUS_DEDUPED}" "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
else
    xz -cd ${INFILE} | ${DEDUPE_BIN} /dev/null "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
fi

touch "${DONEFILE}"

