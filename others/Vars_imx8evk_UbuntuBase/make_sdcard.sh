#!/bin/bash
set -x


VARISCITE_BUILD=/opt/debian_imx8mq-var-dart


sudo umount /dev/sdb1

sudo rm -rf $VARISCITE_BUILD/rootfs/*

pushd .
cd $VARISCITE_BUILD
sudo MACHINE=imx8mq-var-dart ./var_make_debian.sh -c modules
popd

sudo rsync -avD rootfs $VARISCITE_BUILD


pushd .
cd $VARISCITE_BUILD
sudo MACHINE=imx8mq-var-dart ./var_make_debian.sh -c rtar
sudo MACHINE=imx8mq-var-dart ./var_make_debian.sh -c sdcard -d /dev/sdb
popd

