#!/bin/bash

set -exo pipefail

PLATFORMS="linux/amd64,linux/arm64,linux/riscv64"

docker buildx build \
  --context ${PWD} \
  --file ${2:-Dockerfile} \
  --platform ${PLATFORMS} \
  --tag ${1}
