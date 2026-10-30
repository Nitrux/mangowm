#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2026 Nitrux Latinoamericana S.C.

set -e

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi

$APT_COMMAND update -q
$APT_COMMAND install -y --no-install-recommends \
    build-essential \
    git \
    libdisplay-info-dev \
    libegl1-mesa-dev \
    libinput-bin \
    libinput-dev \
    libliftoff-dev \
    libpango1.0-dev \
    libpixman-1-dev \
    libpcre2-dev \
    libscenefx-0.5 \
    libscenefx-0.5-dev \
    libseat-dev \
    libwayland-dev \
    libwlroots-0.20-dev \
    libxkbcommon-dev \
    libgles2-mesa-dev \
    libcjson-dev \
    mesa-common-dev \
    hwdata \
    meson \
    ninja-build \
    pkg-config \
    wayland-protocols
