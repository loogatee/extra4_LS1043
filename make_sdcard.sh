#!/bin/bash
set -x

BOOT=/media/jreed/boot
ROOTFS=/media/jreed/system


sudo rm -rf $BOOT/*
sudo rsync -avD bootpart/* $BOOT

#
#   Now finish up by copying the rootfs to disk
#
#sudo rm -rf $ROOTFS/*
#sudo rsync -avD rootfs/* $ROOTFS


#
#   Waits until all the disk data is written
#
sync;sync;
