<<<<<<< HEAD
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

ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE}
=======
FROM ubuntu:22.04
>>>>>>> 013aac0 (Update container image (#32))

ARG COSIGN_VERSION=2.0.0
ARG CRICTL_VERSION=1.26.0
ARG NOTARY_VERSION=0.6.1
ARG SOPS_VERSION=3.7.3
ARG VAULT_VERSION=1.13.1
ARG YQ_VERSION=4.6.0

LABEL org.opencontainers.image.authors="Schubert Anselme <schubert@anselm.es>"
LABEL org.opencontainers.image.url="https://github.com/sanselme/images"
LABEL org.opencontainers.image.documentation="https://github.com/sanselme/images"
LABEL org.opencontainers.image.source="https://github.com/sanselme/images"
LABEL org.opencontainers.image.vendor="Schubert Anselme"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV DEBIAN_FRONTEND=noninteractive

<<<<<<< HEAD
COPY scripts/docker.sh /opt/docker.sh
COPY scripts/kubernetes.sh /opt/kubernetes.sh

RUN apt-get update -qq \
  && apt-get install -y \
=======
COPY ./kube/01-docker.sh /opt/docker.sh
COPY ./kube/02-kubernetes.sh /opt/kubernetes.sh

RUN apt update -y \
  && apt install -y --no-install-recommends \
>>>>>>> 013aac0 (Update container image (#32))
  bridge-utils \
  ca-certificates \
  ceph-common \
  curl \
  dbus \
  dnsutils \
  git \
  gnupg \
  iproute2 \
  iptables \
  jq \
  kmod \
  libsystemd0 \
  locales \
  make \
  nmap \
  patch \
<<<<<<< HEAD
  python3-openstackclient \
=======
  python-heatclient \
  python-openstackclient \
>>>>>>> 013aac0 (Update container image (#32))
  python3-pip \
  rbd-nbd \
  socat \
  software-properties-common \
  sudo \
  systemd \
  systemd-sysv \
  udev \
  unzip \
  util-linux \
  vim \
  zip \
  # Prevents journald from reading kernel messages from /dev/kmsg
  && echo "ReadKMsg=no" >> /etc/systemd/journald.conf \
  # Don't start any optional services except for the few we need.
  # (specifically, don't start avahi-daemon, isc-dhcp-server, or libvirtd)
  && find /etc/systemd/system \
  /lib/systemd/system \
  -path '*.wants/*' \
  -not -name '*journald*' \
  -not -name '*systemd-tmpfiles*' \
  -not -name '*systemd-user-sessions*' \
  -exec rm \{} \; \
  && systemctl set-default multi-user.target

# TODO: Verify checksums
# FIXME: notary is not available for arm64
RUN curl -fsSL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(dpkg --print-architecture).tar.gz \
  | tar xz && mv yq_linux_$(dpkg --print-architecture) /usr/local/bin/yq \
  && curl -fsSL https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-$(dpkg --print-architecture).tar.gz \
  | tar xz && mv crictl /usr/local/bin/crictl \
  && curl -s https://fluxcd.io/install.sh | bash \
  && curl -fsSLo /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.$(dpkg --print-architecture) \
  && chmod +x /usr/local/bin/sops \
  && curl -fsSLo /usr/local/bin/cosign https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-$(dpkg --print-architecture) \
  && chmod +x /usr/local/bin/cosign \
  && curl -fsSLo /usr/local/bin/notary https://github.com/notaryproject/notary/releases/download/v${NOTARY_VERSION}/notary-Linux-$(dpkg --print-architecture) || true \
  && chmod +x /usr/local/bin/notary || true \
  && curl -fsSLO https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_$(dpkg --print-architecture).zip \
  && unzip vault_${VAULT_VERSION}_linux_$(dpkg --print-architecture).zip \
  && mv vault /usr/local/bin/vault \
  && rm -f vault_${VAULT_VERSION}_linux_$(dpkg --print-architecture).zip

<<<<<<< HEAD
# Housekeeping
RUN apt-get clean -y \
=======
RUN /opt/docker.sh \
  && /opt/kubernetes.sh

# Housekeeping
RUN apt clean -y \
>>>>>>> 013aac0 (Update container image (#32))
  && rm -rf \
  /var/cache/debconf/* \
  /var/lib/apt/lists/* \
  /var/log/* \
  /tmp/*     \
  /var/tmp/* \
  /usr/share/doc/* \
  /usr/share/man/* \
  /usr/share/local/*

# quiet sudo for the admin user
RUN umask 0337; echo 'Defaults:admin !pam_session, !syslog' > /etc/sudoers.d/99-admin-no-log

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

EXPOSE 80 443 6443

# Initalize systemd
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=console 3>&1"]
