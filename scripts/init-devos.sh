#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -euxo pipefail

: "${ARCH:=$(dpkg --print-architecture)}"

: "${CARGO_HOME:=/usr/local/rust/cargo}"
: "${GOPATH:=/usr/local/go}"
: "${KREW_ROOT:=/usr/local/krew}"
: "${RUSTUP_HOME:=/usr/local/rust/rustup}"

: "${BUF_VERSION:=1.36.0}"
: "${CFSSL_VERSION:=1.6.5}"
: "${CILIUM_VERSION:=0.16.18}"
: "${CLOUDFLARED_VERSION:=2024.9.1}"
: "${CLUSTERCTL_VERSION:=1.8.3}"
: "${COSIGN_VERSION:=2.4.0}"
: "${GH_VERSION:=2.57.0}"
: "${GO_VERSION:=1.23.2}"
: "${JQ_VERSION:=1.7.1}"
: "${K0SCTL_VERSION:=0.19.0}"
: "${KIND_VERSION:=0.24.0}"
: "${KUBECTL_VERSION:=v1.31.1}"
: "${NODE_VERSION:=20.18.0}"
: "${OP_VERSION:=2.30.0}"
: "${SBCTL_VERSION:=0.15.4}"
: "${SOPS_VERSION:=3.9.0}"
: "${TRIVY_VERSION:=0.55.2}"
: "${VAULT_VERSION:=1.17.6}"
: "${YQ_VERSION:=4.44.3}"

ARGS=${@}
DIR="$(dirname $(realpath $(dirname "${0}")))"

apt-get update -yq
apt-get install --no-install-recommends -y \
  ansible \
  genisoimage \
  git \
  git-lfs \
  libvirt-clients \
  python3-openstackclient \
  python3-pip \
  sudo \
  unzip \
  vim \
  virtinst \
  zip

mkdir -p \
  "${CARGO_HOME}" \
  "${GOPATH}" \
  "${KREW_ROOT}" \
  "${RUSTUP_HOME}"

# install docker
if [[ ${ARGS} == *"--docker"* && -z $(command -v docker) ]]; then
  "${DIR}/scripts/install-docker.sh"
fi

# install rust
if [[ ${ARGS} == *"--rust"* && -z $(command -v rustc) ]]; then
  curl -fsSLo /tmp/rustup-init.sh https://sh.rustup.rs
  RUSTUP_HOME="${RUSTUP_HOME}" CARGO_HOME="${CARGO_HOME}" sh /tmp/rustup-init.sh -y
fi

# install go
if [[ ${ARGS} == *"--go"* && -z $(command -v go) ]]; then
  curl -fsSLo /tmp/go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz"
  tar -xvf /tmp/go.tar.gz -C /usr/local/ >/dev/null
fi

# install node
if [[ ${ARGS} == *"--go"* && -z $(command -v node) ]]; then
  curl -fsSLo /tmp/node.tar.gz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.gz"
  tar -xvf /tmp/node.tar.gz -C /usr/local/ >/dev/null
fi

# install yq
if [[ -z $(command -v yq) ]]; then
  curl -fsSLo /tmp/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}"
  install /tmp/yq /usr/local/bin/
fi

# install jq
if [[ -z $(command -v jq) ]]; then
  curl -fsSLo /tmp/jq "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64"
  install /tmp/jq /usr/local/bin/
fi

# install buf
if [[ -z $(command -v buf) ]]; then
  curl -fsSLo /tmp/buf "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-$(uname -s)-$(uname -m)"
  install /tmp/buf /usr/local/bin/
fi

# install cfssl
if [[ -z $(command -v cfssl) ]]; then
  curl -fsSLo /tmp/cfssl "https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_linux_${ARCH}"
  install /tmp/cfssl /usr/local/bin/
fi

# install cilium cli
if [[ -z $(command -v cilium) ]]; then
  curl -fsSLo /tmp/cilium.tar.gz "https://github.com/cilium/cilium-cli/releases/download/v${CILIUM_VERSION}/cilium-linux-${ARCH}.tar.gz"
  tar -xvf /tmp/cilium.tar.gz -C /tmp/ >/dev/null
  install /tmp/cilium /usr/local/bin/
fi

# install cloudflared
if [[ ${ARGS} == *"--cloudflared"* && -z $(command -v cloudflared) ]]; then
  curl -fsSLo /tmp/cloudflared "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${ARCH}"
  install /tmp/cloudflared /usr/local/bin/
fi

# install clusterctl
if [[ -z $(command -v clusterctl) ]]; then
  curl -fsSLo /tmp/clusterctl "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-${ARCH}"
  install /tmp/clusterctl /usr/local/bin/
fi

# install cosign
if [[ -z $(command -v cosign) ]]; then
  curl -fsSLo /tmp/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${ARCH}"
  install /tmp/cosign /usr/local/bin/
fi

# install github cli
if [[ -z $(command -v gh) ]]; then
  curl -fsSLo /tmp/gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz"
  tar -xvf /tmp/gh.tar.gz -C /tmp/ >/dev/null
  install "/tmp/gh_${GH_VERSION}_linux_${ARCH}/bin/gh" /usr/local/bin/
fi

# install k0sctl
if [[ -z $(command -v k0sctl) ]]; then
  curl -fsSLo /tmp/k0sctl "https://github.com/k0sproject/k0sctl/releases/download/v${K0SCTL_VERSION}/k0sctl-linux-${ARCH}"
  install /tmp/k0sctl /usr/local/bin/
fi

# install kind
if [[ -z $(command -v kind) ]]; then
  curl -fsSLo /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-${ARCH}"
  install /tmp/kind /usr/local/bin/
fi

# install kubectl
if [[ -z $(command -v kubectl) ]]; then
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
  install /tmp/kubectl /usr/local/bin/
fi

# install 1password cli
if [[ -z $(command -v op) ]]; then
  curl -fsSLo /tmp/op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${ARCH}_v${OP_VERSION}.zip"
  unzip -d /tmp/op /tmp/op.zip
  install /tmp/op/op /usr/local/bin/
  groupadd -f onepassword-cli
  chgrp onepassword-cli /usr/local/bin/op
  chmod g+s /usr/local/bin/op
fi

# install sbctl
if [[ -z $(command -v sbctl) ]]; then
  curl -fsSLo /tmp/sbctl.tar.gz "https://github.com/Foxboron/sbctl/releases/download/${SBCTL_VERSION}/sbctl-${SBCTL_VERSION}-linux-${ARCH}.tar.gz"
  tar -xvf /tmp/sbctl.tar.gz -C /tmp/ >/dev/null
  install /tmp/sbctl/sbctl /usr/local/bin/
fi

# install sops
if [[ -z $(command -v sops) ]]; then
  curl -fsSLo /tmp/sops "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCH}"
  install /tmp/sops /usr/local/bin/
fi

# install trivy
if [[ -z $(command -v trivy) ]]; then
  curl -fsSLo /tmp/trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz"
  tar -xvf /tmp/trivy.tar.gz -C /tmp/ >/dev/null
  install /tmp/trivy /usr/local/bin/
fi

# install vault
if [[ -z $(command -v vault) ]]; then
  curl -fsSLo /tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${ARCH}.zip"
  unzip -d /tmp/vault /tmp/vault.zip
  install /tmp/vault/vault /usr/local/bin/
fi

# install flux
if [[ -z $(command -v flux) ]]; then
  curl -fsSLo /tmp/flux-install.sh https://fluxcd.io/install.sh
  bash /tmp/flux-install.sh
fi

# install helm
if [[ -z $(command -v helm) ]]; then
  curl -fsSLo /tmp/get-helm-3.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  bash /tmp/get-helm-3.sh
fi

# install krew
if [[ -z $(command -v krew) ]]; then
  curl -fsSLo /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${ARCH}.tar.gz"
  tar -xvf /tmp/krew.tar.gz -C /tmp/ >/dev/null
  KREW_ROOT="${KREW_ROOT}" /tmp/krew-linux_"${ARCH}" install krew
fi

# install trunk.io
if [[ -z $(command -v trunk) ]]; then
  curl -fsSLo /tmp/trunk.sh https://get.trunk.io
  chmod 755 /tmp/trunk.sh
  /tmp/trunk.sh
  chmod 755 "$(command -v trunk)"
fi

# enable windows manager
if [[ ${ARGS} == *"--wm"* ]]; then
  apt-get install --no-install-recommends -y \
    icewm \
    x11vnc \
    xauth \
    xinit \
    xterm \
    xvfb
  cp -f config/systemd/x11vnc.service /lib/systemd/system/x11vnc.service
  systemctl enable x11vnc.service
  echo "exec icewm" >~/.xinitrc && chmod +x ~/.xinitrc
fi

# post
plugins=(
  "ca-cert"
  "cert-manager"
  "ctx"
  "gopass"
  "hns"
  "images"
  "konfig"
  "minio"
  "node-shell"
  "ns"
  "oidc-login"
  "open-svc"
  "openebs"
  "operator"
  "outdated"
  "rabbitmq"
  "rook-ceph"
  "starboard"
  "view-secret"
  "view-serviceaccount-kubeconfig"
  "view-utilization"
)
for p in "${plugins[@]}"; do
  KREW_ROOT="${KREW_ROOT}" /usr/local/krew/bin/kubectl-krew install "${p}"
done

chmod -R 777 \
  "${CARGO_HOME}" \
  "${GOPATH}" \
  "${KREW_ROOT}" \
  "${RUSTUP_HOME}"

# cleanup
rm -rf /tmp/*
