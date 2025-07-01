# syntax=docker/dockerfile:1.7.0

# SPDX-License-Identifier: GPL-3.0
# Copyright (c) 2025 Schubert Anselme <schubert@anselm.es>

ARG BASE_IMAGE=ubuntu:24.04
# checkov:skip=CKV_DOCKER_7
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service

# checkov:skip=CKV2_DOCKER_1
RUN <<EOF
#!/bin/bash
echo EDITOR='"vim"' >>/etc/environment
echo export GPG_TTY='"$(tty)"' >/etc/profile.d/gpg.sh

apt-get update -yq
apt-get install -y --no-install-recommends \
  apparmor \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  lvm2 \
  parted \
  ssh \
  sudo \
  unzip \
  vim \
  wget \
  zsh

chsh -s "$(command -v zsh)" "ubuntu"

echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu

groups=(docker libvirt plugdev sudo)
for g in "${groups[@]}"; do
  usermod -aG "${g}" "ubuntu"
done

systemctl enable journal-to-tty.service

rm -rf /var/lib/apt/lists/*
EOF

USER ubuntu

RUN <<EOF
#!/bin/bash
curl -fsSLo /tmp/ohmyzsh-install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
bash /tmp/ohmyzsh-install.sh --unattended
rm -f /tmp/ohmyzsh-install.sh
EOF

HEALTHCHECK NONE

WORKDIR /home/ubuntu
CMD ["/bin/zsh"]
