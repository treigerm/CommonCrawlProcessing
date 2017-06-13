#!/bin/bash

# Exit as soon as any command fails.
set -e

BINDIR=/fs/zisa0/commoncrawl

INFILES="$1"
OUTDIR="$2"
LANGUAGE="$3"

# Directory of already existing deduplicated files.
#DEDUPED_DIR="/fs/vali0/www/data.statmt.org/ngrams/deduped"

unsafe_gunzip() {
    # unsafe_gunzip makes it possible to open several .gz files which are corrupted.
    # In our case many .gz files fail with a an "Unexpected end of file" error.
    set +e
    for file in "$@"; do
        gzip -cd "$file" 2> /dev/null
        echo
    done
    set -e
}

# There are two possible candidates for the name of the already existing deduped file.
DEDUPEDFILE_1="${DEDUPED_DIR}/${LANGUAGE}.deduped.xz"
DEDUPEDFILE_2="${DEDUPED_DIR}/${LANGUAGE}.xz"

OUTFILE="${OUTDIR}/${LANGUAGE}.deduped.xz"
DONEFILE="${OUTFILE}.done"

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

if [[ -f ${DEDUPEDFILE_1} ]]; then
    unsafe_gunzip ${INFILES} | ${BINDIR}/commoncrawl_dedupe "${DEDUPEDFILE_1}" | xz -c > "${OUTFILE}"
elif [[ -f ${DEDUPEDFILE_2} ]]; then
    unsafe_gunzip ${INFILES} | ${BINDIR}/commoncrawl_dedupe "${DEDUPEDFILE_2}" | xz -c > "${OUTFILE}"
else
    unsafe_gunzip ${INFILES} | ${BINDIR}/commoncrawl_dedupe /dev/null | xz -c > "${OUTFILE}"
fi

touch "${DONEFILE}"

