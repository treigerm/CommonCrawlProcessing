#!/bin/bash

# Exit as soon as any command fails.
set -e
set -o pipefail

# TODO: Remove later.
SCRIPTDIR=/fs/zisa0/tim/precc
LIBDIR=${SCRIPTDIR}/lib

INFILES="$1"
OUTDIR="$2"
LANGUAGE="$3"
SRC_HASH_TABLE="$4"
OUT_HASH_TABLE="$5"

FILE_EXTENSION=$(echo ${INFILES} | awk 'BEGIN {FS="."} {print $(NF)}')
if [[ ${FILE_EXTENSION} == "xz" ]]; then
    COMPRESS_BIN=$(which xz)
elif [[ ${FILE_EXTENSION} == "gz" ]]; then
    COMPRESS_BIN=$(which gzip)
else
    echo "Unkown file format. Files need to be in either .xz or .gz format."
    exit 1
fi

unsafe_unzip() {
    # unsafe_unzip makes it possible to open several compressed files which are corrupted.
    # In our case many compressed files fail with a an "Unexpected end of file" error.
    set +e
    set +o pipefail
    for file in "$@"; do
        ${COMPRESS_BIN} -cd "$file" 2> /dev/null
        echo
    done
    set -o pipefail
    set -e
}

# Possible candidate for a previously deduped file.
#PREVIOUS_DEDUPED_DIR="/fs/zisa0/commoncrawl/deduped"
#DEDUPEDFILE="/fs/zisa0/commoncrawl/test_deduped/cs.tmp.xz"
DEDUPEDFILE="${PREVIOUS_DEDUPED_DIR}/${LANGUAGE}.deduped.xz"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${DEDUPEDFILE} ]]; then
    unsafe_unzip ${INFILES} | ${LIBDIR}/commoncrawl_dedupe_from_file "${DEDUPEDFILE}" "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
else
    unsafe_unzip ${INFILES} | ${LIBDIR}/commoncrawl_dedupe_from_file /dev/null "${SRC_HASH_TABLE}" "${OUT_HASH_TABLE}" | \
        /fs/zisa0/tim/bin/xz -T 6 -c > "${OUTFILE}"
fi

touch "${DONEFILE}"

