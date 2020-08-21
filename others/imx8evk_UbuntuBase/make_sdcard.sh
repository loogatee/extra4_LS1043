#!/bin/bash
set -x

BOOT=/media/jreed/BOOT
ROOTFS=/media/jreed/rootfs
KERNEL_DIR=/opt/linux-imx

#
#   overwrites any existing 
#
cp $KERNEL_DIR/arch/arm64/boot/dts/freescale/imx8mq-evk.dtb      $BOOT
cp $KERNEL_DIR/arch/arm64/boot/Image                             $BOOT


#
#   Now finish up by copying the rootfs to disk
#
sudo rm -rf $ROOTFS/*
sudo rsync -avD rootfs/* $ROOTFS


#
#   Waits until all the disk data is written
#
sync;sync;
