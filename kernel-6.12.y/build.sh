#!/bin/bash

set -xe

# set config
if [ -f liontron-d3588_defconfig ]; then
  cp -a liontron-d3588_defconfig ./arch/arm64/configs/liontron-d3588_defconfig
fi

if [ -f rk3588-liontron-d3588.dts ]; then
  cp -a rk3588-liontron-d3588.dts ./arch/arm64/boot/dts/rockchip/rk3588-liontron-d3588.dts
fi

make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  liontron-d3588_defconfig

# check kver
KVER=$(make LOCALVERSION=-kdev kernelrelease)
KVER="${KVER/kdev*/kdev}"
if [[ "$KVER" != *kdev ]]; then
  echo "ERROR: KVER does not end with 'kdev'"
  exit 1
fi
echo "KVER: ${KVER}"

# build kernel
make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  -j$(nproc)

# build modules
make ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  KBUILD_BUILD_USER="builder" \
  KBUILD_BUILD_HOST="kdevbuilder" \
  LOCALVERSION=-kdev \
  modules -j$(nproc)

# isntall modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
  INSTALL_MOD_PATH=$(pwd)/kos \
  LOCALVERSION=-kdev \
  modules_install

echo "All done!"
