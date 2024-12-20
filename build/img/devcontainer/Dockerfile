# SPDX-License-Identifier: GPL-3.0

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV X11VNC_SKIP_DISPLAY=""

RUN apt-get update -y && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  cron \
  curl \
  dbus \
  dmidecode \
  dnsmasq \
  file \
  frr \
  iproute2 \
  libvirt-clients \
  libvirt-daemon \
  libvirt-daemon-system \
  openssl \
  pdns-server \
  software-properties-common \
  squashfs-tools \
  ssh \
  systemd \
  udev \
  wireguard \
  wireguard-tools && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service
COPY build/img/devcontainer/devcontainer /etc/sudoers.d/devcontainer
COPY scripts/*.sh /tmp/scripts/

# todo: checksum downloaded binaries
RUN chmod +x /tmp/scripts/*.sh && \
  /tmp/scripts/init-devos.sh && \
  systemctl enable journal-to-tty.service && \
  useradd -m devcontainer

CMD ["/sbin/init"]
USER devcontainer
HEALTHCHECK NONE
