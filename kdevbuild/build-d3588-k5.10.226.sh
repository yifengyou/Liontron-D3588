#!/bin/bash

set -euxo pipefail

WORKDIR=$(pwd)
export build_tag="D3588_k5.10.226_${set_release}_${set_desktop}"
export DEBIAN_FRONTEND=noninteractive

#==========================================================================#
#                        init build env                                    #
#==========================================================================#
apt-get update
apt-get install -y ca-certificates
apt-get install -y --no-install-recommends \
  acl aptly aria2 axel bc binfmt-support binutils-aarch64-linux-gnu bison \
  bsdextrautils btrfs-progs build-essential busybox ca-certificates ccache \
  clang coreutils cpio crossbuild-essential-arm64 cryptsetup curl \
  debian-archive-keyring debian-keyring debootstrap device-tree-compiler \
  dialog dirmngr distcc dosfstools dwarves e2fsprogs expect f2fs-tools \
  fakeroot fdisk file flex gawk gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi \
  gdisk git gnupg gzip htop imagemagick jq kmod lib32ncurses-dev \
  lib32stdc++6 libbison-dev libc6-dev-armhf-cross libc6-i386 libcrypto++-dev \
  libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev libfuse-dev \
  libgcc-12-dev-arm64-cross libgmp3-dev liblz4-tool libmpc-dev libncurses-dev \
  libncurses5 libncurses5-dev libncursesw5-dev libpython2.7-dev \
  libpython3-dev libssl-dev libusb-1.0-0-dev linux-base lld llvm locales \
  lsb-release lz4 lzma lzop make mtools ncurses-base ncurses-term \
  nfs-kernel-server ntpdate openssl p7zip p7zip-full parallel parted patch \
  patchutils pbzip2 pigz pixz pkg-config pv python2 python2-dev python3 \
  python3-dev python3-distutils python3-pip python3-setuptools \
  python-is-python3 qemu-user-static rar rdfind rename rsync sed \
  squashfs-tools swig tar tree u-boot-tools udev unzip util-linux uuid \
  uuid-dev uuid-runtime vim wget whiptail xfsprogs xsltproc xxd xz-utils \
  zip zlib1g-dev zstd binwalk ripgrep sudo
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 || true
mkdir -p ${WORKDIR}/rockdev
mkdir -p ${WORKDIR}/release

#==========================================================================#
#                        build uboot                                       #
#==========================================================================#
cd ${WORKDIR}/
git clone https://github.com/yifengyou/d3588-uboot.git d3588-uboot.git
ls -alh d3588-uboot.git
cd d3588-uboot.git
./d3588.sh
cp -a uboot.img ${WORKDIR}/rockdev/uboot.img
ls -alh ${WORKDIR}/rockdev/uboot.img
md5sum ${WORKDIR}/rockdev/uboot.img

#==========================================================================#
#                        build kernel                                      #
#==========================================================================#
cd ${WORKDIR}
git clone https://github.com/yifengyou/d3588-kernel.git d3588-kernel.git
ls -alh d3588-kernel.git
cd d3588-kernel.git
./d3588.sh
cp -a boot.img ${WORKDIR}/rockdev/boot.img
ls -alh ${WORKDIR}/rockdev/boot.img
md5sum ${WORKDIR}/rockdev/boot.img

#==========================================================================#
# Task: Build Root Filesystem (rootfs) using Armbian Build System          #
#                                                                          #
# The BRANCH variable selects the kernel version and support level:        #
#   - edge    : Latest mainline kernel (e.g., 6.10+) — bleeding-edge,      #
#               may include experimental features or instability.          #
#   - current : Stable mainline kernel (e.g., 6.6 LTS) — recommended for   #
#               general use; balances new features and reliability.        #
#   - legacy  : Vendor-provided kernel (e.g., Rockchip 5.10) — intended    #
#               for compatibility with proprietary drivers or older BSPs.  #
#                                                                          #
# Note: Only the rootfs is needed; kernel, U-Boot, and disk images are     #
#       not required for this stage.                                       #
#==========================================================================#
if [ -z "${set_desktop}" ] || [ -z "${set_release}" ]; then
  echo "skip rootfs build"
  echo "Build completed successfully!"
  exit 0
fi
mkdir -p ${WORKDIR}/rootfs
cd ${WORKDIR}/rootfs
if [ "${set_desktop}" == "mini" ]; then
  BUILD_DESKTOP="BUILD_DESKTOP=no"
else
  BUILD_DESKTOP=" \
      BUILD_DESKTOP=yes \
      DESKTOP_APPGROUPS_SELECTED=remote_desktop \
      DESKTOP_ENVIRONMENT=${set_desktop} \
      DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base"
fi
git clone -q --single-branch \
  --depth=1 \
  --branch=main \
  https://github.com/armbian/build.git armbian.git
ls -alh ${WORKDIR}/rootfs/armbian.git
cd ${WORKDIR}/rootfs/armbian.git
./compile.sh RELEASE=${set_release} \
  BOARD=nanopct6 \
  BRANCH=current \
  BUILD_MINIMAL=no \
  BUILD_ONLY=default \
  HOST=armbian \
  ${BUILD_DESKTOP} \
  EXPERT=yes \
  KERNEL_CONFIGURE=no \
  COMPRESS_OUTPUTIMAGE="sha,img,xz" \
  VENDOR="Armbian" \
  SHARE_LOG=yes
ls -alh ${WORKDIR}/rootfs/armbian.git/output/images/

# extract rootfs
chmod +x ${WORKDIR}/tools/extract-rootfs-from-armbian.sh
${WORKDIR}/tools/extract-rootfs-from-armbian.sh ${WORKDIR}/rootfs/armbian.git/output/images/
ls -alh ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img
md5sum ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img

# hack rootfs
mount ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img /mnt
cp -a ${WORKDIR}/tools/hack-rootfs.sh /mnt/
cp -a ${WORKDIR}/tools/armbian_first_run.txt /mnt/boot/
chmod +x /mnt/hack-rootfs.sh
chroot /mnt sh -c "/hack-rootfs.sh"
sync
umount /mnt
sync
mv ${WORKDIR}/rootfs/armbian.git/output/images/rootfs.img ${WORKDIR}/rockdev/rootfs.img
ls -alh ${WORKDIR}/rockdev

#==========================================================================#
# Script Name: Generate Rockchip Updatable Image                           #
# Description: This script is used to generate an updatable image package  #
#              for Rockchip devices, including uboot, boot, and rootfs     #
#              images. The generated images will be placed in the release  #
#              directory for further use or distribution.                  #
#                                                                          #
# Output Directories and Files:                                            #
#   - ${WORKDIR}/rockdev/uboot.img      : U-Boot bootloader image          #
#   - ${WORKDIR}/rockdev/boot.img       : Boot partition image             #
#   - ${WORKDIR}/rockdev/rootfs.img     : Root filesystem image            #
#   - ${WORKDIR}/release                : Directory containing the final   #
#                                         packaged update image            #
#                                                                          #
# Note: Ensure that all necessary source files are present in the          #
#       specified directories before running this script.                  #
#==========================================================================#

# rootfs.img   : ${WORKDIR}/rockdev/rootfs.img
# uboot.img    : ${WORKDIR}/rockdev/uboot.img
# boot.img     : ${WORKDIR}/rockdev/boot.img
# RKDevTool    : ${WORKDIR}/rockchip-tools.git/RKDevTool-v3.19-RK3588/
# afptool      : ${WORKDIR}/rockchip-tools.git/afptool
# rkImageMaker : ${WORKDIR}/rockchip-tools.git/rkImageMaker
# template     : ${WORKDIR}/update_img_tmp/
# output       : ${WORKDIR}/release/

cd ${WORKDIR}
git clone https://github.com/yifengyou/rockchip-tools.git rockchip-tools.git
ls -alh ${WORKDIR}/rockchip-tools.git
chmod +x ${WORKDIR}/rockchip-tools.git/afptool
chmod +x ${WORKDIR}/rockchip-tools.git/rkImageMaker

mkdir -p ${WORKDIR}/release
mkdir -p ${WORKDIR}/update_img_tmp
cp -a ${WORKDIR}/rockchip-tools.git/RKDevTool-v3.19-RK3588  \
  ${WORKDIR}/update_img_tmp/RKDevTool
mkdir -p ${WORKDIR}/update_img_tmp/RKDevTool/rockdev/image/

cp -a ${WORKDIR}/rockdev/uboot.img   ${WORKDIR}/update_img_tmp/RKDevTool/rockdev/image/
cp -a ${WORKDIR}/rockdev/boot.img    ${WORKDIR}/update_img_tmp/RKDevTool/rockdev/image/
cp -a ${WORKDIR}/rockdev/rootfs.img  ${WORKDIR}/update_img_tmp/RKDevTool/rockdev/image/

cd ${WORKDIR}/update_img_tmp/RKDevTool/rockdev/image/
${WORKDIR}/rockchip-tools.git/afptool -pack . temp.img
${WORKDIR}/rockchip-tools.git/rkImageMaker \
  -RK3588 MiniLoaderAll.bin \
  temp.img \
  update.img \
  -os_type:androidos
find . -type f ! -name "update.img" -exec rm -f {} \;

# generate update.img
cd ${WORKDIR}/update_img_tmp/
rar a ${WORKDIR}/release/${build_tag}_update.rar RKDevTool
cd ${WORKDIR}/release/
sha256sum ${build_tag}_update.rar

#==========================================================================#
# Script Purpose: Generate Rockchip Firmware Image with RKDevTool          #
#                                                                          #
# This script prepares the required partition images and packages them     #
# into a firmware update bundle compatible with Rockchip's RKDevTool.      #
#                                                                          #
# Input Images (must exist before execution):                              #
#   - ${WORKDIR}/rockdev/uboot.img   : U-Boot bootloader image             #
#   - ${WORKDIR}/rockdev/boot.img    : Kernel + DTB boot image             #
#   - ${WORKFS}/rockdev/rootfs.img   : Root filesystem image               #
#                                                                          #
# Output:                                                                  #
#   - ${WORKDIR}/release/            : Final RKDevTool-compatible firmware #
#                                      package (e.g., update.img)          #
#                                                                          #
# Note: Verify that all source images are correctly built and placed in    #
#       the ${WORKDIR}/rockdev/ directory prior to running this script.    #
#==========================================================================#

# rootfs.img   : ${WORKDIR}/rockdev/rootfs.img
# uboot.img    : ${WORKDIR}/rockdev/uboot.img
# boot.img     : ${WORKDIR}/rockdev/boot.img
# RKDevTool    : ${WORKDIR}/rockchip-tools.git/RKDevTool-v3.19-RK3588/
# afptool      : ${WORKDIR}/rockchip-tools.git/afptool
# rkImageMaker : ${WORKDIR}/rockchip-tools.git/rkImageMaker
# template     : ${WORKDIR}/update_img_tmp/
# output       : ${WORKDIR}/release/

mkdir -p ${WORKDIR}/release
mkdir -p ${WORKDIR}/rockdev_img_tmp
cp -a ${WORKDIR}/rockchip-tools.git/RKDevTool-v3.19-RK3588  \
  ${WORKDIR}/rockdev_img_tmp/RKDevTool
mkdir -p ${WORKDIR}/rockdev_img_tmp/RKDevTool/rockdev/image/

cp -a ${WORKDIR}/rockdev/uboot.img   ${WORKDIR}/rockdev_img_tmp/RKDevTool/rockdev/image/
cp -a ${WORKDIR}/rockdev/boot.img    ${WORKDIR}/rockdev_img_tmp/RKDevTool/rockdev/image/
cp -a ${WORKDIR}/rockdev/rootfs.img  ${WORKDIR}/rockdev_img_tmp/RKDevTool/rockdev/image/

cd ${WORKDIR}/rockdev_img_tmp/
rar a ${WORKDIR}/release/${build_tag}_rockdev.rar RKDevTool
cd ${WORKDIR}/release/
sha256sum ${build_tag}_rockdev.rar

ls -alh ${WORKDIR}/release/

echo "Build completed successfully!"
exit 0
