# SPDX-License-Identifier: GPL-3.0

ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV X11VNC_SKIP_DISPLAY=""

RUN apt-get update -y && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  cron \
  curl \
  dbus \
  file \
  iproute2 \
  libvirt-daemon \
  libvirt-daemon-system \
  openssl \
  software-properties-common \
  ssh \
  systemd && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service
COPY build/img/devcontainer/devcontainer /etc/sudoers.d/devcontainer
# todo: checksum downloaded binaries
COPY scripts/*.sh /tmp/scripts/

RUN chmod +x /tmp/scripts/*.sh && \
  /tmp/scripts/init-devos.sh && \
  systemctl enable journal-to-tty.service && \
  useradd -m devcontainer

CMD ["/sbin/init"]
USER devcontainer
HEALTHCHECK NONE
