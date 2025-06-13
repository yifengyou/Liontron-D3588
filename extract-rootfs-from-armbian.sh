#!/bin/bash

set -x

# $0 SOURCE_DIR TARGET_DIR
# find img.xz from SOURCE_DIR
# output rootfs.img to TARGET_DIR

if [ $# -eq 2 ]; then
	SOURCE_DIR=$1
	TARGET_DIR=$2
elif [ $# -eq 1 ]; then
	SOURCE_DIR=$1
	TARGET_DIR=$1
else
	echo "Usage: $0 SOURCE_DIR TARGET_DIR"
	exit 0
fi

ARMBIAN_IMG=$(ls ${SOURCE_DIR}/*.img.xz | head -n1)
xz -kdc ${ARMBIAN_IMG} > armbian.img

# 使用fdisk和awk提取分区信息（示例输出：/dev/sda1 2048 2097151）
partition_info=$(fdisk -l armbian.img | awk '/^Device/{flag=1; next} flag{print $1, $2, $3; exit}')

# 解析start和end扇区
start_sector=$(echo "${partition_info}" | awk '{print $2}')
end_sector=$(echo "${partition_info}" | awk '{print $3}')
count=$((end_sector - start_sector + 1)) # dd的count需要+1[6](@ref)

# 执行dd提取分区
mkdir -p "${TARGET_DIR}"
dd if=armbian.img of="${TARGET_DIR}/rootfs.img" \
	bs=512 \
	skip="${start_sector}" \
	count="${count}" \
	status=progress

cd ${TARGET_DIR}
ls -alh rootfs.img
file rootfs.img


