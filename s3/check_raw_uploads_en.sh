#!/bin/bash

FILE=$(echo "$1" | awk ' BEGIN { FS = "/" } { print $(NF) }')
OUTFILE="$2"

MD5SUM=$(md5sum "$1" | awk 'BEGIN { FS = " " } {print $1}')
echo "${MD5SUM} ${FILE}" >> "${OUTFILE}"
