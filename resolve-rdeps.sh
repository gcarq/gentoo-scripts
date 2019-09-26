#!/bin/bash -e
# Resolves runtime dependency packagenames for a given file on Gentoo Linux
# Michael Egger <michael.egger@tsn.at>
# See LICENSE for copyright information

if [ $# -eq 0 ]; then
    echo "No path supplied"
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "${1} is not a file"
    exit 1
fi

for i in $(ldd "${1}" | awk '{if ($4 && $3 ~ /^\//) print $3}'); do
    qfile "${i}" | cut -d":" -f1
done | sort -u
