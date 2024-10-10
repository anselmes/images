#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -eo pipefail

: "${ARCH:=$(dpkg --print-architecture)}"
: "${HELM_VERSION:=3.7.0}"

# install helm
curl -fsSLo /tmp/helm.tgz https://get.helm.sh/helm-v3.7.0-linux-arm64.tar.gz
tar -xzf /tmp/helm.tgz
install /tmp/linux-amd64/helm /usr/local/bin/helm
helm version
