# syntax=docker/dockerfile:1.7.0

# SPDX-License-Identifier: GPL-3.0
# Copyright (c) 2025 Schubert Anselme <schubert@anselm.es>

ARG BASE_IMAGE=ubuntu:24.04
# checkov:skip=CKV_DOCKER_7
FROM ${BASE_IMAGE}

# MARK: - Packages

ENV DEBIAN_FRONTEND=noninteractive

# checkov:skip=CKV2_DOCKER_1
RUN <<EOF
#!/bin/bash
apt-get update -yq
apt-get install -y --no-install-recommends \
  apparmor \
  ca-certificates \
  curl \
  dbus \
  git \
  gnupg2 \
  lvm2 \
  openssl \
  parted \
  ssh \
  sudo \
  systemd \
  udev \
  unzip \
  vim \
  wget \
  zsh
EOF

# MARK: - Content

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service

# MARK: - Configuration

RUN <<EOF
#!/bin/bash
echo EDITOR='"vim"' >>/etc/environment

echo export GPG_TTY='"$(tty)"' >/etc/profile.d/gpg.sh

echo >> /etc/skel/.profile
echo source /etc/profile >> /etc/skel/.profile

cp -f /etc/skel/.profile /etc/skel/.zprofile

# Environment Configuration
systemctl enable journal-to-tty.service

# User Configuration
cp -f /etc/skel/.profile /home/ubuntu/.profile
chsh -s "$(command -v zsh)" "ubuntu"
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu
groups=(docker libvirt plugdev sudo)
for g in "${groups[@]}"; do
  usermod -aG "${g}" "ubuntu"
done

# Clean Up
rm -rf /var/lib/apt/lists/*
EOF

# MARK: - User

USER ubuntu

RUN <<EOF
#!/bin/bash
cp -f /etc/skel/.profile /home/ubuntu/.profile
cp -f /etc/skel/.zprofile /home/ubuntu/.zprofile
curl -fsSLo /tmp/ohmyzsh-install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
bash /tmp/ohmyzsh-install.sh --unattended
rm -f /tmp/ohmyzsh-install.sh
EOF

# MARK: - Runtime

HEALTHCHECK NONE

WORKDIR /home/ubuntu
CMD ["/bin/zsh", "-l"]
