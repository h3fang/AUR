#!/bin/bash

set -eu

sudo sed -i '/^CFLAGS=/ s/-march=x86-64 -mtune=generic/-march='${INPUT_ARCH}'/' /etc/makepkg.conf
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

sudo chown -R builder "$PWD"

for d in */; do
    if [[ -f "$d/PKGBUILD" && "$d" != "linux-zen/" ]]; then
        pushd "$d"
        echo "Running makepkg with $PWD/PKGBUILD"
        makepkg -fsCc --noconfirm
        popd
    fi
done
