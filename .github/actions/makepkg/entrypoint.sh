#!/bin/bash

set -eu

sed -i '/^CFLAGS=/ s/-march=x86-64 -mtune=generic/-march='${INPUT_ARCH}'/' /etc/makepkg.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

chown -R builder .
mkdir pkgs

for d in */; do
    if [[ -f "$d/PKGBUILD" && "$d" != "linux-zen/" && "$d" != "evince/" ]]; then
        pushd "$d"
        echo "Running makepkg with $PWD/PKGBUILD"
        sudo -H -u builder makepkg -fsrCc --noconfirm
        mv *.pkg.tar.zst ../pkgs/
        rm -rf *
        popd
    fi
done
