FROM ubuntu:22.04

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

COPY ./kube/01-docker.sh /opt/docker.sh
COPY ./kube/02-kubernetes.sh /opt/kubernetes.sh

RUN apt update -y \
  && apt install -y --no-install-recommends \
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
  python-heatclient \
  python-openstackclient \
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

RUN /opt/docker.sh \
  && /opt/kubernetes.sh

# Housekeeping
RUN apt clean -y \
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
