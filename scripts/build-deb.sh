#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2026 Nitrux Latinoamericana S.C.

set -euo pipefail

PACKAGE_VERSION="${PACKAGE_VERSION:?PACKAGE_VERSION must be supplied by the workflow input}"
TARGET_ARCH="${TARGET_ARCH:-$(dpkg --print-architecture)}"
UPSTREAM_VERSION="${PACKAGE_VERSION%%-*}"

mkdir -p build/source build/package-root/DEBIAN build/debian

git clone --depth 1 --branch "$UPSTREAM_VERSION" \
    https://github.com/mangowm/mango.git build/source/mango

MESON_ARGS=(--prefix=/usr --buildtype=release)
if [ "$(dpkg-architecture -qDEB_BUILD_ARCH)" = "amd64" ]; then
    MESON_ARGS+=( -Dc_args=-march=x86-64-v3 -Dc_link_args=-march=x86-64-v3 )
fi

meson setup build/meson build/source/mango "${MESON_ARGS[@]}"
ninja -C build/meson
DESTDIR="$PWD/build/package-root" meson install -C build/meson
install -D -m644 build/source/mango/LICENSE \
    build/package-root/usr/share/doc/mangowm/copyright

cat > build/debian/control <<'EOF_CONTROL'
Source: mangowm
Section: x11
Priority: optional
Maintainer: Nitrux Latinoamericana S.C. <hello@nxos.org>

Package: mangowm
Architecture: any
Depends: ${shlibs:Depends}
Description: Wayland compositor based on dwl
 Mango is a dynamic tiling Wayland compositor.
EOF_CONTROL

SHARED_DEPENDENCIES=$(cd build && dpkg-shlibdeps -O \
    package-root/usr/bin/mango \
    package-root/usr/bin/mmsg \
    package-root/usr/bin/mangonag \
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
