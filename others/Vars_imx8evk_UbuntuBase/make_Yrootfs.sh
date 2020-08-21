#!/bin/bash
set -x

VARISCITE_BUILD=/opt/debian_imx8mq-var-dart
YOCTO_LOCATION=/home/jreed/extra4/Downloads
YOCTO_NAME="yocto_rootfs.tar.gz"

#


HOSTNAME="yodarts"

sudo find Custom_Files -exec chown root {} \; -exec chgrp root {} \;
#sudo chgrp shadow Custom_Files/etc/shadow


sudo rm -rf rootfs
mkdir rootfs

#
#  Grab Ubuntu image, copy it to .
#
cp $YOCTO_LOCATION/$YOCTO_NAME .


cd rootfs; sudo tar --numeric-owner -xzf ../$YOCTO_NAME; cd ..

#
#   Custom_Files to copy to rootfs
#
sudo cp Custom_Files/1stboot_config.sh               rootfs/home/root
sudo cp Custom_Files/install_openssh.sh              rootfs/home/root
sudo cp Custom_Files/more_packages.sh                rootfs/home/root
sudo cp Custom_Files/usb_tcpip/usbip.sh              rootfs/home/root


#
#    Particular to variscite
#
sudo cp Custom_Files/install_debian.sh               rootfs/usr/sbin
sudo cp Custom_Files/mkfs.fat                        rootfs/sbin
sudo ln -s /sbin/mkfs.fat                            rootfs/sbin/mkfs.vfat


#
#    other bins for Variscite
#
sudo rsync -avD Custom_Files/hantro                  rootfs/opt
sudo rsync -avD Custom_Files/firmware                rootfs/lib


#
#   Removes passwd from root
#
sudo sed -i "s/root:x:0/root::0/g" rootfs/etc/passwd


#
#   Creates /etc/hostname
#
sudo /bin/bash -c "echo $HOSTNAME >   rootfs/etc/hostname"


#
#   /etc/hosts
#
sudo /bin/bash -c "echo 127.0.0.1 localhost $HOSTNAME >   rootfs/etc/hosts"


#
#   Creates /etc/resolv.conf
#
sudo rm -f                                          rootfs/etc/resolv.conf
sudo /bin/bash -c "echo nameserver 8.8.8.8 >        rootfs/etc/resolv.conf"
sudo ln -s /var/run/resolvconf/resolv.conf          rootfs/etc/resolv.conf

#
#   Remove this file, or connman will overwrite /etc/resolv.conf
#
sudo rm -f                                          rootfs/etc/tmpfiles.d/connman_resolvconf.conf


#
#   Creates /etc/fstab
#
sudo sed -i "\$aproc     /proc      proc      defaults     0   0" rootfs/etc/fstab

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
sudo sed -i "\$aalias dir='ls -CF'" rootfs/home/root/.bashrc
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
#   Creates and writes /etc/qmi-network.conf
#
sudo touch       rootfs/etc/qmi-network.conf
sudo ed rootfs/etc/qmi-network.conf << xEOF
a
APN=reseller
PROXY=yes
.
w
xEOF

#
#   Fix up /usr/bin/qmi-network to add parameter:   ip-type=4
#
sudo sed -i "s/START_NETWORK_ARGS=\"apn/START_NETWORK_ARGS=\"ip-type=4,apn/"    rootfs/usr/bin/qmi-network



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
#    Removes some crap that is not needed
#
sudo rm -rf        rootfs/usr/share/vulkan-demos
sudo rm -rf        rootfs/usr/share/mesa-demos
sudo rm -rf        rootfs/usr/share/icons


#
#    Can remove the original tarball,
#
#
rm -f ./$YOCTO_NAME




sudo cp $VARISCITE_BUILD/output/Image.gz              rootfs/boot
sudo cp $VARISCITE_BUILD/variscite/splash.bmp         rootfs/boot
sudo cp $VARISCITE_BUILD/output/*.dtb                 rootfs/boot

pushd .
cd rootfs/boot
sudo ln -s fsl-imx8mq-var-dart-sd-lvds-cb12.dtb  fsl-imx8mq-var-dart-cb12.dtb
sudo ln -s fsl-imx8mq-var-dart-sd-lvds.dtb       fsl-imx8mq-var-dart.dtb
popd















