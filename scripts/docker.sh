#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

set -e

: "${CRI_DOCKERD_VERSION_MAJ:="0.3.1"}"
: "${CRI_DOCKERD_VERSION_MIN:="3-0"}"

sudo mkdir -m 0755 -p /etc/docker
sudo mkdir -m 0755 -p /etc/apt/keyrings

# Remove docker, if already installed
if [[ -n "$(type -p $docker)" ]]; then
  sudo apt remove -y \
    containerd \
    docker \
    docker-engine \
    docker.io \
    runc
fi

# Add repositories
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Install packages
sudo apt update -y
sudo apt install -y \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin

# Download & install cri-dockerd
curl -fsSLo /tmp/cri-dockerd.deb "https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_DOCKERD_VERSION_MAJ}/cri-dockerd_${CRI_DOCKERD_VERSION_MAJ}.${CRI_DOCKERD_VERSION_MIN}.ubuntu-focal_amd64.deb"
sudo apt install -y /tmp/cri-dockerd.deb

# Configure docker daemon
docker_resolv="/etc/resolv.conf"
docker_dns_list="$(awk '/^nameserver/ { printf "%s%s",sep,"\"" $NF "\""; sep=", "} END{print ""}' "${docker_resolv}")"

sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "live-restore": true,
  "dns": [${docker_dns_list}],
  "experimental": true,
  "cgroup-parent": "docker.slice"
}
EOF

sudo systemctl enable containerd.service
sudo systemctl enable docker.service
sudo systemctl enable cri-docker.service
