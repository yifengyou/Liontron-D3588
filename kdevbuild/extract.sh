#!/bin/bash

set -x

rm -f ok_boot_*

../u-boot-v2017/tools/dumpimage -i boot.img -T flat_dt  -p 0 ok_boot_fdt
ls -alh ok_boot_fdt

../u-boot-v2017/tools/dumpimage -i boot.img -T flat_dt  -p 1 ok_boot_kernel
ls -alh ok_boot_kernel

../u-boot-v2017/tools/dumpimage -i boot.img -T flat_dt  -p 2 ok_boot_resource
ls -alh ok_boot_resource

rm -rf out
/data/rk3588/rk3588-latest/kernel/scripts/resource_tool  --unpack --image=ok_boot_resource
ls -alh out

