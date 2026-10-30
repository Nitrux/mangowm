#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2026 Nitrux Latinoamericana S.C.

set -euo pipefail

PACKAGE_VERSION="${PACKAGE_VERSION:-0.18.4-1}"
TARGET_ARCH="${TARGET_ARCH:-$(dpkg --print-architecture)}"
UPSTREAM_VERSION="0.18.4"

mkdir -p build/source build/package-root/DEBIAN

git clone --depth 1 --branch "$UPSTREAM_VERSION" \
    https://github.com/mangowm/mango.git build/source/mango

meson setup build/meson build/source/mango \
    --prefix=/usr \
    --buildtype=release
ninja -C build/meson
DESTDIR="$PWD/build/package-root" meson install -C build/meson
install -D -m644 build/source/mango/LICENSE \
    build/package-root/usr/share/doc/mangowm/copyright

SHARED_DEPENDENCIES=$(dpkg-shlibdeps -O build/package-root/usr/bin/mango \
    | sed -n 's/^shlibs:Depends=//p')

cat > build/package-root/DEBIAN/control <<EOF_CONTROL
Package: mangowm
Version: ${PACKAGE_VERSION}
Section: x11
Priority: optional
Architecture: ${TARGET_ARCH}
Maintainer: Nitrux Latinoamericana S.C. <hello@nxos.org>
Depends: ${SHARED_DEPENDENCIES}
Homepage: https://github.com/mangowm/mango
Description: Wayland compositor based on dwl
 Mango is a dynamic tiling Wayland compositor.
EOF_CONTROL

mkdir -p build

dpkg-deb --root-owner-group --build \
    build/package-root \
    "build/mangowm_${PACKAGE_VERSION}_${TARGET_ARCH}.deb"
