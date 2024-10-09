#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -euxo pipefail

OLD_PKGS=(
  "docker.io"
  "docker-doc"
  "docker-compose"
  "podman-docker"
  "containerd runc"
)

PKGS=(
  "containerd.io"
  "docker-buildx-plugin"
  "docker-ce-cli"
  "docker-ce"
  "docker-compose-plugin"
)

for pkg in "${OLD_PKGS[@]}"; do
  apt-get remove -y "${pkg}" || true
done

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# add docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

# install packages
apt-get update -y
apt-get install -y "${PKGS[@]}"
