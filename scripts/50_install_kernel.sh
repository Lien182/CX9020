#!/bin/bash

set -e
set -o nounset

if [ $# -ne 1 ] || ! [ -d $1 ]; then
	echo -e "Usage:\n $0 <rootfs_mount>\n\nexample:\n $0 /tmp/rootfs\n\n"
	exit -1
fi

ROOTFS_MOUNT=$1

KERNEL=kernel
kernel_version=`cat ${KERNEL}/include/config/kernel.release`
CCAT_FIRMWARE=tools/ccat.rbf

LINARO=gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf
CROSS_PATH=`pwd`/tools/${LINARO}/bin
CROSS_PREFIX=${CROSS_PATH}/arm-linux-gnueabihf-

# install kernel
pushd ${KERNEL}
rm -rf ${ROOTFS_MOUNT}/lib/modules/${kernel_version}/
make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} INSTALL_MOD_PATH=${ROOTFS_MOUNT} modules_install
popd
mkdir -p ${ROOTFS_MOUNT}/boot
cp -v ${KERNEL}/arch/arm/boot/zImage ${ROOTFS_MOUNT}/boot/vmlinuz-${kernel_version}
sh -c "echo 'uname_r=${kernel_version}' > ${ROOTFS_MOUNT}/boot/uEnv.txt"
sh -c "echo 'optargs=libphy.num_phys=2 console=tty0 quiet' >> ${ROOTFS_MOUNT}/boot/uEnv.txt"

# install device tree binary
mkdir -p ${ROOTFS_MOUNT}/boot/dtbs/${kernel_version}/
cp -a ${KERNEL}/arch/arm/boot/dts/imx53-cx9020.dtb ${ROOTFS_MOUNT}/boot/dtbs/${kernel_version}/
sh -c "echo 'dtb=imx53-cx9020.dtb' >> ${ROOTFS_MOUNT}/boot/uEnv.txt"

# install ccat firmware
cp -v ${CCAT_FIRMWARE} ${ROOTFS_MOUNT}/boot/ccat.rbf
sh -c "echo 'ccat=/boot/ccat.rbf' >> ${ROOTFS_MOUNT}/boot/uEnv.txt"

echo "DONE: $0!"
