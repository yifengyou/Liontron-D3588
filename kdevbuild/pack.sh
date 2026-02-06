#!/bin/bash

set -x

TIMESTAMP=`date +"%Y%m%d%H%M%S"`
cp Image ok_boot_kernel -a
mkdir ../rockdev
../rkbin/tools/mkimage -f boot.its -E -p 0x800 ../rockdev/boot.img
md5sum ../rockdev/boot.img
realpath ../rockdev/boot.img
