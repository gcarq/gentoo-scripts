#!/bin/bash -e
# Simple Kernel update script for Gentoo Linux
# Michael Egger <egger.m@protonmail.com>
# See LICENSE for copyright information

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

LINUX_SRC='/usr/src/linux'

if [[ ! -d "${LINUX_SRC}" || ! -f "${LINUX_SRC}/Makefile" ]]; then
    echo "Could not find a Makefile in the kernel source directory."
    echo "Please ensure that /usr/src/linux points to a complete set of Linux sources"
    exit 1
fi

pushd "${LINUX_SRC}" > /dev/null 2>&1

# Use current config if .config does not exist
if [[ ! -f "${LINUX_SRC}/.config" ]]; then
    echo "kernel config not found. Using /proc/config.gz"
    zcat /proc/config.gz > "${LINUX_SRC}/.config"
fi

# Update current config utilising a provided .config as base
# Also invoke menuconfig to configure kernel further
make oldconfig menuconfig

# Build kernel with nproc-1 threads
make -j$(($(nproc)-1))

# Install modules and kernel
make modules_install install

# Backup kernel config
mkdir -p /etc/kernels
cp -v .config "/etc/kernels/kernel-config-$(uname -m)-$(make kernelversion)"

# Generate initramfs
dracut --hostonly --force '' "$(make kernelversion)"

# Generate grub config
grub-mkconfig -o /boot/grub/grub.cfg

if [[ -f /usr/bin/chkboot ]]; then
    echo "Running chkboot ..."
    /usr/bin/chkboot
fi

popd > /dev/null 2>&1

# Rebuild modules against new kernel
emerge --ask @module-rebuild
