#!/bin/bash
set -x

YOCTO_LOCATION=/home/jreed/extra4/Downloads
KERNEL_DIR=/opt/linux-imx-4.19.35

HOSTNAME="Ymx8evk"

YOCTO_NAME="yocto_rootfs.tar.gz"
#YOCTO_NAME="imx-image-multimedia-imx8mqevk.tar.gz"
#YOCTO_NAME="imx-image-full-imx8mqevk.tar.gz"



#
#   The Custom files need to have the correct owner/group
#     - All files owned by root
#     - All files are root group except for /etc/shadow
#
sudo find Custom_Files -exec chown root:root {} \;
#sudo chgrp shadow Custom_Files/etc/shadow


#
#   Remove rootfs, then re-create it
#
sudo rm -rf rootfs
mkdir rootfs


cp $YOCTO_LOCATION/$YOCTO_NAME .


#
#   Yocto root file system
#
cd rootfs; sudo tar --numeric-owner -xzf ../$YOCTO_NAME; cd ..


#
#    Custom_Files to copy to rootfs
#
sudo cp Custom_Files/1stboot_config.sh               rootfs/home/root
sudo cp Custom_Files/more_packages.sh                rootfs/home/root
sudo cp Custom_Files/usbip.sh                        rootfs/home/root


#
#    Getty stuff
#
#sudo ln -s /lib/systemd/system/getty@.service        rootfs/etc/systemd/system/getty.target.wants/getty@ttymxc0.service
sudo rm -f                                            rootfs/etc/systemd/system/getty@tty1.service


#
#   Removes passwd from root
#
sudo sed -i "s/root:x:0/root::0/g" rootfs/etc/passwd

#
#   Creates /etc/hostname
#
sudo /bin/bash -c "echo $HOSTNAME >   rootfs/etc/hostname"

#
#   Creates /etc/hosts
#
sudo /bin/bash -c "echo 127.0.0.1 localhost $HOSTNAME >   rootfs/etc/hosts"


#
#   Creates /etc/resolv.conf
#
sudo rm -f                                          rootfs/etc/resolv.conf
sudo /bin/bash -c "echo nameserver 8.8.8.8 >        rootfs/etc/resolv.conf"
#sudo ln -s /var/run/resolvconf/resolv.conf         rootfs/etc/resolv.conf


#
#   Creates /etc/fstab
#
#sudo sed -i "\$aproc     /proc      proc      defaults     0   0" rootfs/etc/fstab


#
#   setup for zeromq
#
sudo cp Custom_Files/zmq/libzmq*     rootfs/usr/lib
sudo ln -s libzmq.so.5.1.0           rootfs/usr/lib/libzmq.so.5
sudo ln -s libzmq.so.5.1.0           rootfs/usr/lib/libzmq.so
sudo cp Custom_Files/zmq/zmq*        rootfs/usr/include
sudo cp Custom_Files/zmq/libso*      rootfs/usr/lib
sudo ln -s libsodium.so.23.1.0       rootfs/usr/lib/libsodium.so.23


#
#   setup for lua
#
sudo mkdir                           rootfs/usr/include/lua5.1
sudo cp Custom_Files/lua/*.h         rootfs/usr/include/lua5.1
sudo cp Custom_Files/lua/lib*        rootfs/usr/lib
sudo ln -s liblua5.1.so.0.0.0        rootfs/usr/lib/liblua5.1.so
sudo ln -s liblua5.1.so.0.0.0        rootfs/usr/lib/liblua5.1.so.0


#
#    An example of a simple addition to an existing file
#    Add to the skel file also
#    
sudo sed -i "\$aalias dir='ls -CF'" rootfs/home/root/.profile
sudo sed -i "\$aalias dir='ls -CF'" rootfs/etc/skel/.bashrc

#
#   Creates and writes /etc/connman/main.conf
#
sudo mkdir -p    rootfs/etc/connman
sudo touch       rootfs/etc/connman/main.conf
sudo ed rootfs/etc/connman/main.conf << xEOF
a
[General]
AllowHostnameUpdates=false
NetworkInterfaceBlacklist=eth0
.
w
xEOF

#
#    Fixes up 80-wired.network with a static IP for eth0
#
sudo rm -f    rootfs/lib/systemd/network/80-wired.network
sudo touch    rootfs/lib/systemd/network/80-wired.network
sudo ed  rootfs/lib/systemd/network/80-wired.network << yEOF
a
[Match]
Name=eth0

[Network]
Address=192.168.7.2/24
Gateway=192.168.7.4
.
w
yEOF


#
#   Adds /etc/yum.repos.d/myrepo.repo
#
sudo mkdir -p    rootfs/etc/yum.repos.d
sudo touch       rootfs/etc/yum.repos.d/myrepo.repo
sudo ed          rootfs/etc/yum.repos.d/myrepo.repo << yEOF
a
[myrepo]
name=nxpboard
baseurl=http://192.168.7.4:80
enabled=1
metadata_expire=0
gpgcheck=0
.
w
yEOF


#
#   Fixes up sudoers 
#
sudo sed -i "s/^# %sudo/%sudo/"    rootfs/etc/sudoers

#
#   Busybox udhcpd
#
sudo ln -s /bin/busybox  rootfs/sbin/udhcpd

#
#   Configuration files for tcp/ip over usb.  
#
sudo cp Custom_Files/usb_tcpip/81-wired.network   rootfs/lib/systemd/network
sudo cp Custom_Files/usb_tcpip/g_ether.conf       rootfs/etc/modules-load.d
sudo cp Custom_Files/usb_tcpip/udhcpd.conf        rootfs/etc

#
#   Fix up /usr/bin/qmi-network to add parameter:   ip-type=4
#
sudo sed -i "s/START_NETWORK_ARGS=\"apn/START_NETWORK_ARGS=\"ip-type=4,apn/"    rootfs/usr/bin/qmi-network

#
#   Copy Custom file qmi-network.conf to /etc
#
sudo cp Custom_Files/qmi/qmi-network.conf        rootfs/etc


#
#    Removes some crap that is not needed
#
sudo rm -rf        rootfs/usr/share/vulkan-demos
sudo rm -rf        rootfs/usr/share/mesa-demos
sudo rm -rf        rootfs/usr/share/icons


#
#    Removes local copy of Yocto .tar.gz
#
rm ./$YOCTO_NAME


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
sudo rm -f rootfs/boot/*
sudo cp $KERNEL_DIR/arch/arm64/boot/Image              rootfs/boot
sudo rsync -avD /tmp/tmpXX/lib/modules                 rootfs/lib

#
#   Uncomment if you have a local copy of firmware
#
#sudo rsync -avD ../evkbinaries/rootfs/lib/firmware     rootfs/lib


