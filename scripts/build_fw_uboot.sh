#!/bin/bash

set -eo pipefail

branch="master"
branch_socfpga="socfpga_v2025.04"

targets="${1}"
[[ -z "$targets" ]] && targets=($(yq '.images.bootloader[]' config/image.yaml))

(
  for item in "${targets[@]}"; do
    target=$(echo "$item" | cut -d':' -f1)
    arch=$(echo "$item" | cut -d':' -f2)
    config=$(echo "$item" | cut -d':' -f3)

    output="uboot-${target}-${arch}"

    echo "config: $config"

    if [[ "$arch" == "arm" ]]; then
      export CROSS_COMPILE="${arch}-linux-gnueabi-"
    elif [[ "$arch" == "riscv32" || "$arch" == "riscv64" ]]; then
      export CROSS_COMPILE="${arch}-linux-gnu-"
      export OPENSBI="${WORKSPACE}/build/opensbi-generic-riscv.bin"
    else
      export CROSS_COMPILE="${arch}-linux-gnu-"
    fi

    cd "$UBOOT_ROOT"

    rm -rf spl
    make clean

    if [[ "$config" == "socfpga*" ]]; then
      git checkout -b "${branch_socfpga}"
      git fetch origin "${branch_socfpga}"
      git reset --hard FETCH_HEAD
    else
      git checkout "${branch}"
      git fetch origin "${branch}"
      git reset --hard FETCH_HEAD
    fi

    make "$config"
    make -j $(nproc)

    if $(stat u-boot-with-spl.sfp >/dev/null 2>&1); then
      cp -f u-boot-with-spl.sfp "${WORKSPACE}/build/${output}.sfp"
    elif $(stat spl/u-boot-spl.bin >/dev/null 2>&1); then
      cp -f spl/u-boot-spl.bin "${WORKSPACE}/build/${output}.bin"
      cp -f u-boot.itb "${WORKSPACE}/build/${output}.itb"
    else
      cp -f u-boot.bin "${WORKSPACE}/build/${output}.bin"
    fi

    cd -
  done
)
