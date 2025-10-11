#!/bin/bash

set -eo pipefail

(
  export CROSS_COMPILE=riscv64-linux-gnu-
  cd "$OPENSBI_ROOT"

  make clean
  make PLATFORM=generic

  cp -f build/platform/generic/firmware/fw_dynamic.bin "${WORKSPACE}/build/opensbi-generic-riscv.bin"
  cd -
)
