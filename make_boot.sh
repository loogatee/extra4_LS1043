#!/bin/bash
set -x

UBUNTU_LOCATION=/home/jreed/extra4/Downloads
KERNEL_DIR=/opt/linux-layerscape

HOSTNAME="ls1043ardb"

UBUNTU_NAME="rootfs_lsdk2004_ubuntu_main_arm64.tgz"
BOOTPART_NAME="bootpartition_LS_arm64_lts_5.4.tgz"


#-----------------------------------------------------------------------------------
#
#   Remove rootfs, then re-create it
#
sudo rm -rf bootpart
mkdir bootpart


#
#   Ubuntu root file system
#
cd bootpart; sudo tar --numeric-owner -xzf $UBUNTU_LOCATION/$BOOTPART_NAME; cd ..


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
#   Removes existing 5.4.3 modules
#
sudo rm -rf bootpart/modules/*

#
#   Writes modules
#
sudo rsync -avD /tmp/tmpXX/lib/modules/*              bootpart/modules


#
#   Image, Image.gz, and vmlinuz-5.4.3
#
pushd .
cd bootpart
sudo rm Image Image.gz vmlinuz-5.4.3
sudo cp $KERNEL_DIR/arch/arm64/boot/Image  .
sudo gzip -k Image
sudo cp Image.gz vmlinuz-5.4.3
sudo rm -f *1043*.dtb
sudo cp $KERNEL_DIR/arch/arm64/boot/dts/freescale/fsl-ls1043a-rdb-sdk.dtb .
sudo rm -rf flash_images secboot_hdrs
sudo rm *.itb
popd






