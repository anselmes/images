# syntax=docker/dockerfile:1.7.0

# SPDX-License-Identifier: GPL-3.0
# Copyright (c) 2025 Schubert Anselme <schubert@anselm.es>

ARG BASE_IMAGE=ghcr.io/labsonline/devcontainer/toolchain:24.04
# checkov:skip=CKV_DOCKER_7
FROM ${BASE_IMAGE}

# MARK: - Pre

USER root

ARG GO11MODULE=on
ARG GOPATH=/usr/local/go

RUN <<EOF
#!/bin/bash
mkdir -p $GOPATH
chmod 777 $GOPATH

echo export GO11MODULE="\"$GO11MODULE\"" >/etc/profile.d/go.sh
echo export GOPATH="\"$GOPATH\"" >>/etc/profile.d/go.sh
echo export PATH="\"\${GOPATH}/bin\${PATH:+:\${PATH}}\"" >>/etc/profile.d/go.sh
EOF

# MARK: - Packages

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
#!/bin/bash
. /etc/profile.d/go.sh

apt-get update -yq
apt-get install -y --no-install-recommends golang-go
EOF

# buf
ARG BUF_VERSION=1.55.1

RUN <<EOF
#!/bin/bash
# Download and verify the checksum file for the release
curl -OL https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/sha256.txt
curl -OL https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/sha256.txt.minisig
minisign -Vm sha256.txt -P RWQ/i9xseZwBVE7pEniCNjlNOeeyp4BQgdZDLQcAohxEAH5Uj5DEKjv6 || {
  echo "Signature verification failed"
  exit 1
}

# Download the file(s) you want to verify, for example the tarball
curl -OL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-$(uname -s)-$(uname -m).tar.gz"

# Verify the file checksums
cat sha256.txt | shasum -a 256 -c --ignore-missing || {
  echo "Checksum verification failed"
  exit 1
}

# Install buf
tar -xzf "buf-$(uname -s)-$(uname -m).tar.gz"
install -m 755 buf/bin/* /usr/local/bin/
cp -a buf/etc/* /etc/
cp -a buf/share/* /usr/local/share/
chmod +x /usr/local/bin/buf
EOF

# MARK: - Post

# Clean Up
RUN <<EOF
#!/bin/bash
rm -f "buf-$(uname -s)-$(uname -m).tar.gz"
rm -f sha256.txt sha256.txt.minisig
rm -rf buf/
rm -rf /var/lib/apt/lists/*
EOF

# MARK: - User

USER ubuntu

# MARK: - Runtime

HEALTHCHECK NONE

WORKDIR /home/ubuntu
CMD ["/bin/zsh", "-l"]
