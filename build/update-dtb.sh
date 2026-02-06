#!/bin/bash

set -x

dtc -I dts -O dtb rk3588-dxb-lp4-v10-linux.dts -o rk3588-dxb-lp4-v10-linux.dtb

# need update resource
../rkbin/tools/resource_tool  --unpack --image=ok_boot_resource
ls -alh out
cp rk3588-dxb-lp4-v10-linux.dtb out/rk-kernel.dtb
cd out
../../rkbin/tools/resource_tool logo.bmp logo_kernel.bmp rk-kernel.dtb
mv resource.img ../ok_boot_resource



