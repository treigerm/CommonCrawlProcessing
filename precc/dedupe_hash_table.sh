#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

LIBDIR=${SCRIPTDIR}/lib

INFILES="$1"
OUTDIR="$2"
LANGUAGE="$3"
SRC_HASH_TABLE="$4"
OUT_HASH_TABLE="$5"
PREVIOUS_DEDUPED_DIR="$6"

DEDUPEDFILE="${PREVIOUS_DEDUPED_DIR}/${LANGUAGE}.deduped.xz"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${DEDUPEDFILE} ]]; then
    xz -cd ${INFILES} | ${LIBDIR}/commoncrawl_dedupe_save_table "${DEDUPEDFILE}" "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
else
    xz -cd ${INFILES} | ${LIBDIR}/commoncrawl_dedupe_save_table /dev/null "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
fi

touch "${DONEFILE}"

