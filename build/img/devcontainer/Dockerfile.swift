# syntax=docker/dockerfile:1.7.0

# SPDX-License-Identifier: GPL-3.0
# Copyright (c) 2025 Schubert Anselme <schubert@anselm.es>

ARG BASE_IMAGE=ghcr.io/labsonline/devcontainer:24.04
# checkov:skip=CKV_DOCKER_7
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ARG SWIFTLY_HOME_DIR=/usr/local/swiftly
ARG SWIFT_BRANCH=swift-6.2-branch # FIXME: we need to install the main snapshot for swift 6.2 (required for java-interop)

ARG SDK_VERSION=swift-6.2-DEVELOPMENT-SNAPSHOT-2025-06-27-a  # FIXME: we need to install the main snapshot for swift 6.2 (required for java-interop)
ARG STATIC_SDK_CHECKSUM=a8568f8a1ac04aeec1d7610d9a42c4b8e8698ee6bd988117ff44392b9d0fad0f
ARG WASM_SDK_CHECKSUM=967c0d853bb37c02682f8d19ba5a29534aa37b1d6204e92f2a555ef3a65458f0

USER root

# checkov:skip=CKV2_DOCKER_1
RUN <<EOF
#!/bin/bash
mkdir -p $SWIFTLY_HOME_DIR/bin $SWIFTLY_HOME_DIR/toolchains
chmod -R 777 $SWIFTLY_HOME_DIR

echo export SWIFTLY_HOME_DIR="$SWIFTLY_HOME_DIR" >/etc/profile.d/swift.sh
echo export SWIFTLY_BIN_DIR="$SWIFTLY_HOME_DIR/bin" >>/etc/profile.d/swift.sh
echo export SWIFTLY_TOOLCHAINS_DIR="$SWIFTLY_HOME_DIR/toolchains" >>/etc/profile.d/swift.sh
echo export PATH="\"\${SWIFTLY_BIN_DIR}\${PATH:+:\${PATH}}\"" >>/etc/profile.d/swift.sh

source /etc/profile.d/swift.sh

apt-get update -yq
# FIXME: we need jdk24+ for java-interop
apt-get install -y --no-install-recommends \
  binutils \
  build-essential \
  cmake \
  default-jdk \
  git \
  gnupg2 \
  libc6-dev \
  libcurl4-openssl-dev \
  libedit2 \
  libgcc-13-dev \
  libncurses-dev \
  libpython3-dev \
  libsqlite3-0 \
  libstdc++-13-dev \
  libxml2-dev \
  libz3-dev \
  ninja-build \
  pkg-config \
  tzdata \
  unzip \
  zlib1g-dev

# Download swiftly
curl -O https://download.swift.org/swiftly/linux/swiftly-1.0.1-$(uname -m).tar.gz

# Verify download
curl https://www.swift.org/keys/all-keys.asc | gpg --import -
curl -O https://download.swift.org/swiftly/linux/swiftly-1.0.1-$(uname -m).tar.gz.sig
gpg --verify swiftly-1.0.1-$(uname -m).tar.gz.sig swiftly-1.0.1-$(uname -m).tar.gz || {
  echo "Signature verification failed"
  exit 1
}

# Extract archive
tar -zxf swiftly-1.0.1-$(uname -m).tar.gz

# Install
install -m 755 ./swiftly /usr/local/bin/swiftly
swiftly init -y && hash -r
swiftly self-update

# FIXME: we need to install the main snapshot for swift 6.2 (required for java-interop)
swiftly install main-snapshot # swift 6.2
EOF

USER ubuntu

RUN <<EOF
. /etc/profile.d/swift.sh

# Static SDK
swift sdk install --checksum $STATIC_SDK_CHECKSUM https://download.swift.org/$SWIFT_BRANCH/static-sdk/$SDK_VERSION/${SDK_VERSION}_static-linux-0.0.1.artifactbundle.tar.gz || {
  echo "Static SDK installation failed"
  exit 1
}

# WASM SDK
swift sdk install --checksum $WASM_SDK_CHECKSUM https://download.swift.org/$SWIFT_BRANCH/wasm-sdk/$SDK_VERSION/${SDK_VERSION}_wasm.artifactbundle.tar.gz || {
  echo "WASM SDK installation failed"
  exit 1
}
EOF

USER root

# Clean Up
RUN <<EOF
rm -f *.txt
rm -f swiftly-1.0.1-$(uname -m).tar.gz
rm -f swiftly-1.0.1-$(uname -m).tar.gz.sig
rm -rf /var/lib/apt/lists/*
EOF

HEALTHCHECK NONE

USER ubuntu
CMD ["/bin/bash"]
