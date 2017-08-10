#!/bin/bash

set -e
set -o pipefail

total=0
downloaded=0
echo "$total"; echo -en "\e[1A"
for path in `cat $1`; do
    echo -e "\e[0K\r $total"; echo -en "\e[1A"
    total=$((total+1))
    FILENAME=$(echo $path | awk ' BEGIN { FS = "/" } { print $(NF-2) "/" $(NF)}')
    if [ -f ${FILENAME}.done ]; then
        downloaded=$((downloaded+1))
    fi
done

echo "$downloaded/$total"
echo "Downloaded/Total"
