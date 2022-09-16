#!/bin/bash

set -eu

if [ -d "/github" ]; then
    sudo chown -R builder /github/workspace /github/home
fi

sudo sed -i '/^CFLAGS=/ s/-march=x86-64 -mtune=generic/-march='"${INPUT_ARCH}"'/' /etc/makepkg.conf
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

mkdir -p pkgs

cd "${INPUT_PKG}"
echo "Running makepkg with $PWD/PKGBUILD"
makepkg -fs --noconfirm
mv -- *.pkg.tar.zst ../pkgs/
