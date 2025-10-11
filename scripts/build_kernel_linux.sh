#!/bin/bash

set -eo pipefail

branch="master"
branch_socfpga="socfpga-6.12.33-lts"

targets="${1}"
[[ -z "$targets" ]] && targets=($(yq '.images.kernel[]' config/image.yaml))

(
  for item in "${targets[@]}"; do
    target=$(echo "$item" | cut -d':' -f1)
    config=$(echo "$item" | cut -d':' -f2)
    archs=($(echo "$item" | cut -d':' -f3 | tr ',' ' '))

    output="linux-${target}-${arch}"

    echo "config: $config"

    export ARCH="$arch"
    export KDEB_CHANGELOG_DIST=noble   # silence that “unstable / lsb-release” nit
    export LOCALVERSION_AUTO=false
    export LOCALVERSION="-${target}"

    for arch in "${archs[@]}"; do
      if [[ "$arch" == "arm" ]]; then
        export CROSS_COMPILE="${arch}-linux-gnueabihf-"
      elif [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
        export CROSS_COMPILE="${arch}-linux-gnueabi-"
      elif [[ "$arch" == "riscv32" || "$arch" == "riscv64" ]]; then
        export CROSS_COMPILE="${arch}-linux-gnu-"
      else
        export CROSS_COMPILE="${arch}-linux-gnu-"
      fi

      cd "$LINUX_ROOT"
      make mrproper || true

      if [[ "$config" == "socfpga*" ]]; then
        git checkout -b "${branch_socfpga}"
        git fetch origin "${branch_socfpga}"
        git reset --hard FETCH_HEAD
      else
        git checkout "${branch}"
        git fetch origin "${branch}"
        git reset --hard FETCH_HEAD
      fi

      if [[ "$config" == "defconfig" ]]; then
        make defconfig
      elif $(stat "${WORKSPACE}/build/image/config/*${config}"); then
        cp -f "${WORKSPACE}/build/image/config/*${config}" .config
        make olddefconfig
      else
        make "$config"
      fi

      make -j $(nproc) zImage dtbs bindeb-pkg

      cp -f arch/arm/boot/zImage "${WORKSPACE}/build/${output}"
      cp -f arch/arm/boot/dts/*.dtb "${WORKSPACE}/build/${output}.dtb"
      cp -f ../*.deb "${WORKSPACE}/build/"

      cd -
    done
  done
)
