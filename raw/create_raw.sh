#!/bin/bash

set -e
set -o pipefail

# Parallel command:
# cat langugage.codes | parallel --nice 19 --progress --sshloginfile file \
#   create_raw.sh $crawl_dir $out_dir {}

INDIR=$1
OUTDIR=$2
LANGCODE=$3

OUTFILE=${OUTDIR}/${LANGCODE}.raw.xz
DONEFILE=${OUTFILE}.done

unsafe_gunzip() {
    # unsafe_gunzip makes it possible to open several .gz files which are corrupted.
    # In our case many .gz files fail with a an "Unexpected end of file" error.
    set +e
    set +o pipefail
    for file in "$@"; do
        gzip -cd "$file" 2> /dev/null
        echo
    done
    set -o pipefail
    set -e
}

if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

unsafe_gunzip ${INDIR}/*/text.${LANGCODE}.gz | xz -c > "${OUTFILE}"

touch "${DONEFILE}"
