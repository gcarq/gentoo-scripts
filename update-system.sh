#!/bin/bash -e
# Package rebuild and update script for Gentoo Linux
# Michael Egger <egger.m@protonmail.com>
# See LICENSE for copyright information

if [[ "$EUID" -ne 0 ]]; then
    printf 'Please run as root\n'
    exit 1
fi

trap 'exit 130' INT

usage() {
    cat 1>&2 <<EOF
USAGE:
    update-system [FLAGS]

FLAGS:
    -s, --sync              Refresh repositories prior to emerge
    -h, --help              Prints help information

All arguments passed after '--' are forwarded to emerge.
EOF
}

while test $# -gt 0; do
    case "$1" in
        -s | --sync ) emaint sync -a; shift;;
        -h | --help ) usage; exit 0;;
        -- ) shift; break;;
        * ) printf 'Invalid argument: %s\n\n' "$1"; usage; exit 1;;
    esac
done

printf 'Invoking emerge ...\n'
emerge --ask \
       --autounmask-continue=y \
       --changed-use \
       --deep \
       --keep-going \
       --newuse \
       --update \
       --with-bdeps=y \
       @world "$@"

printf 'Checking for unused dependencies ...\n'
emerge --ask --quiet --depclean

printf 'Removing obsolete entries in /etc/portage/package.* ...\n'
portpeek -krf
