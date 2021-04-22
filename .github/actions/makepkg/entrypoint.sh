#!/bin/bash

set -eu

sed -i '/^CFLAGS=/ s/-march=x86-64 -mtune=generic/-march='${INPUT_ARCH}'/' /etc/makepkg.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

chown -R builder "$PWD"

for d in */; do
    if [[ -f "$d/PKGBUILD" && "$d" != "linux-zen/" ]]; then
        pushd "$d"
        echo "Running makepkg with $PWD/PKGBUILD"
        sudo -u builder makepkg -fsCc --noconfirm
        popd
    fi
done
