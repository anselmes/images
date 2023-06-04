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

set -ex

: "${KUBE_VERSION:="1.26.0"}"
: "${KREW_ROOT:="/opt/krew"}"
: "${OS:="$(uname | tr '[:upper:]' '[:lower:]')"}"
: "${ARCH:="$(dpkg --print-architecture)"}"
: "${KREW:="krew-${OS}_${ARCH}"}"

KUBE_PLUGINS=(
ca-cert
cert-manager
ctx
deprecations
df-pv
direct-csi
gopass
hns
images
konfig
kyverno
minio
node-shell
ns
oidc-login
open-svc
openebs
operator
outdated
rabbitmq
rook-ceph
starboard
view-secret
view-serviceaccount-kubeconfig
view-utilization
)

# Add repositories
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Install packages
sudo apt update -y
sudo apt install -y \
  kubelet="${KUBE_VERSION}-00" \
  kubeadm="${KUBE_VERSION}-00" \
  kubectl="${KUBE_VERSION}-00"
sudo apt-mark hold kubelet kubeadm kubectl

# Install kind
curl -fsSLo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
sudo chmod +x /usr/local/bin/kind

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" \
| bash -s -- /usr/local/bin

# Install helm
curl -fsSLo /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 755 /tmp/get_helm.sh && sudo /tmp/get_helm.sh

# FIXME: Install krew
sudo tee /etc/profile.d/kubectl-krew.sh <<'EOF'
export KREW_ROOT="/opt/krew"
export PATH="${KREW_ROOT}/bin${PATH:+:${PATH}}"
EOF
source /etc/profile.d/kubectl-krew.sh
curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" | tar xz \
  && mv "${KREW}" /usr/local/bin/kubectl-krew

# Add kubectl & helm plugins
kubectl krew update
for PLUGIN in "${KUBE_PLUGINS[@]}"; do
  kubectl krew install "${PLUGIN}" || true
done

helm plugin install https://github.com/chartmuseum/helm-push
