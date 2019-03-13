#!/bin/bash -e
# Simple Kernel update script for Gentoo Linux
# Michael Egger <michael.egger@tsn.at>
# See LICENSE.md for copyright information

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

pushd /usr/src/linux > /dev/null 2>&1

# Use current config if .config does not exist
if [[ ! -f /usr/src/linux/.config ]]; then
    echo ".config not found. Using /proc/config.gz"
    zcat /proc/config.gz > /usr/src/linux/.config
fi

# Update current config utilising a provided .config as base
# Also invoke menuconfig to configure kernel further
make oldconfig menuconfig

# Build kernel with nproc-1 threads
make -j$(($(nproc)-1))

# Install modules and kernel
make modules_install install

# Generate initramfs
dracut --hostonly --force '' "$(make kernelversion)"

# Generate grub config
grub-mkconfig -o /boot/grub/grub.cfg

popd > /dev/null 2>&1
