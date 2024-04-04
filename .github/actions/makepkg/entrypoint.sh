#!/bin/bash

set -eu

sudo sed -i '/^CFLAGS=/ s/-march=x86-64 -mtune=generic/-march='"${INPUT_ARCH}"'/' /etc/makepkg.conf
sudo sed -i '/^options=(/ s/\bdebug\b/!debug/' /etc/makepkg.conf
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

sudo chown -R builder /github/workspace /github/home
mkdir -p pkgs

cd "${INPUT_PKG}"
echo "Running makepkg with $PWD/PKGBUILD"
makepkg -fs --noconfirm
mv -- *.pkg.tar.zst ../pkgs/
