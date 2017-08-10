#!/bin/bash

set -e
set -o pipefail

SOURCEFILE=$1
DESTINATION=$2
INDEX=$3
PADDEDINDEX=$(printf %02d $((INDEX - 1)))
NEWFILE=${DESTINATION}/en.${PADDEDINDEX}.raw.xz
DONEFILE=${NEWFILE}.done
if [[ -f ${DONEFILE} ]]; then
    exit 0
fi

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

unsafe_gunzip "${SOURCEFILE}" | xz -c > "${NEWFILE}"

touch "${DONEFILE}"
