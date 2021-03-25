#!/bin/bash

set -eu

sed -i '/^CFLAGS=/ s/.*/CFLAGS="-march='${INPUT_ARCH}' -O2 -pipe -fno-plt"/' /etc/makepkg.conf
sed -i '/^CXXFLAGS=/ s/.*/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
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
