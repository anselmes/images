# SPDX-License-Identifier: GPL-3.0

ARG BUILD_DATE
ARG VYOS_VERSION
ARG BASE_IMAGE=debian:bookworm-slim

FROM ${BASE_IMAGE}

ENV ARCH=${TARGETPLATFORM}
ENV DEBIAN_FRONTEND=noninteractive
ENV JQ_VERSION=1.7.1

WORKDIR /tmp

RUN apt-get update -yq && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  curl \
  dbus \
  fuse-overlayfs \
  git \
  gnupg \
  init \
  pipx \
  systemd \
  yq && \
  mkdir -p /opt/vyatta/etc /tmp/architectures_triage /tmp/hooks && \
  git clone --single-branch --depth=1 https://github.com/vyos/vyos-build.git && \
  curl -fsSLo /tmp/jq "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64" && \
  install /tmp/jq /usr/local/bin/

RUN cp -f \
  vyos-build/data/defaults.toml \
  vyos-build/data/live-build-config/archives/* \
  vyos-build/docker-vyos/*.sh \
  /tmp/ && \
  cp -f vyos-build/data/architectures/* /tmp/architectures_triage/ && \
  cp -f vyos-build/data/live-build-config/hooks/live/* /tmp/hooks/ && \
  cp -f vyos-build/tools/container/config.boot.default /opt/vyatta/etc/ && \
  chmod +x /tmp/*.sh

RUN mv /tmp/architectures_triage/$(dpkg --print-architecture).toml /tmp/ && \
  rm -rf /tmp/architectures_triage && \
  /tmp/vyos_install_stage_01.sh && \
  /tmp/vyos_install_stage_02.sh && \
  /tmp/vyos_install_stage_03.sh && \
  rm -rf /tmp/* && \
  useradd -m vyos

WORKDIR /home/vyos
ENV container=docker
STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
USER vyos
HEALTHCHECK NONE
