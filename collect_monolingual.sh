#!/usr/bin/env bash

# Exit as soon as any command fails
set -e
set -o pipefail

LIBDIR=${SCRIPTDIR}/lib

DATADIR=$1
OUTDIR=$2

mkdir -p "${OUTDIR}"

DONEFILE=${DATADIR}/lang_split.done

if [ ! -f ${DONEFILE} ]; then
    xzcat ${DATADIR}/*.langsplit.xz | ${LIBDIR}/collect_langs.py \
        -en >(pigz >${OUTDIR}/text.en.gz) \
        -ca >(pigz >${OUTDIR}/text.ca.gz) \
        -cs >(pigz >${OUTDIR}/text.cs.gz) \
        -de >(pigz >${OUTDIR}/text.de.gz) \
        -el >(pigz >${OUTDIR}/text.el.gz) \
        -es >(pigz >${OUTDIR}/text.es.gz) \
        -fr >(pigz >${OUTDIR}/text.fr.gz) \
        -is >(pigz >${OUTDIR}/text.is.gz) \
        -it >(pigz >${OUTDIR}/text.it.gz) \
        -nl >(pigz >${OUTDIR}/text.nl.gz) \
        -pl >(pigz >${OUTDIR}/text.pl.gz) \
        -pt >(pigz >${OUTDIR}/text.pt.gz) \
        -ro >(pigz >${OUTDIR}/text.ro.gz) \
        -ru >(pigz >${OUTDIR}/text.ru.gz) \
        -sk >(pigz >${OUTDIR}/text.sk.gz) \
        -sl >(pigz >${OUTDIR}/text.sl.gz) \
        -sv >(pigz >${OUTDIR}/text.sv.gz)
    touch ${DONEFILE}
fi
