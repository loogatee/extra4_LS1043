#!/bin/bash
set -x

SDCARD_ROOTFS=/media/jreed/rootfs
KERNEL_DIR=/opt/linux-imx-4.19.35


IMAGE_NAME="Image-"`cat $KERNEL_DIR/include/config/kernel.release`


#
#   makes the modules and places them in /tmp/tmpXX
#   And deletes all the links in there
#
sudo rm -rf /tmp/tmpXX
mkdir /tmp/tmpXX
pushd .
cd $KERNEL_DIR; export ARCH=arm64; export CROSS_COMPILE=aarch64-linux-gnu-; make INSTALL_MOD_PATH=/tmp/tmpXX modules_install
find /tmp/tmpXX/lib/modules -type l -exec rm -f {} \;
popd


#
#   Image to /boot
#   modules to /lib
#
sudo rm -f                                       $SDCARD_ROOTFS/boot/Image
sudo rm -f                                       $SDCARD_ROOTFS/boot/Image.gz

sudo cp $KERNEL_DIR/arch/arm64/boot/Image        $SDCARD_ROOTFS/boot/$IMAGE_NAME
sudo cp $KERNEL_DIR/arch/arm64/boot/Image        $SDCARD_ROOTFS/boot
sudo rsync -avD /tmp/tmpXX/lib/modules           $SDCARD_ROOTFS/lib


pushd .
cd $SDCARD_ROOTFS/boot
sudo gzip Image
sudo ln -s $IMAGE_NAME Image
popd






