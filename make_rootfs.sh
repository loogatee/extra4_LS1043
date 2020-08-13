#!/bin/bash
set -x

UBUNTU_LOCATION=/home/jreed/extra4/Downloads
KERNEL_DIR=/opt/linux-layerscape


UBUNTU_NAME="rootfs_lsdk2004_ubuntu_main_arm64.tgz"
BOOTPART_NAME="bootpartition_LS_arm64_lts_5.4.tgz"
DTB_NAME="fsl-ls1043a-rdb-sdk.dtb"

HOSTNAME="ls1043ardb"



#
#   The Custom files need to have the correct owner/group
#     - All files owned by root
#     - All files are root group except for /etc/shadow
#
sudo find Custom_Files -exec chown root {} \; -exec chgrp root {} \;


#
#   Remove rootfs, then re-create it
#
sudo rm -rf rootfs
mkdir rootfs


#
#  get rootfs from the repo
#
cp $UBUNTU_LOCATION/$UBUNTU_NAME .


#
#   Ubuntu root file system
#
cd rootfs; sudo tar --numeric-owner -xzf ../$UBUNTU_NAME; cd ..


#
#    Custom_Files to copy to rootfs
#
sudo cp Custom_Files/1stboot_config.sh               rootfs/root
sudo cp Custom_Files/more_packages.sh                rootfs/root
sudo cp Custom_Files/usb_tcpip/usbip.sh              rootfs/root


#
#    Getty stuff
#
#sudo ln -s /lib/systemd/system/getty@.service        rootfs/etc/systemd/system/getty.target.wants/getty@ttymxc0.service
#sudo rm -f                                           rootfs/lib/systemd/system/getty-static.service


#
#    udev stuff
#
#sudo rsync -avD Custom_Files/udev_lib/*               rootfs/lib/udev
#sudo rsync -avD Custom_Files/udev_etc/*               rootfs/etc/udev


#
#  debs
#
#sudo rsync -avD Custom_Files/network_arm64_debs       rootfs/root
#sudo rsync -avD Custom_Files/aptutils_arm64_debs      rootfs/root
#sudo rsync -avD Custom_Files/openssh_arm64_debs       rootfs/root


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
#sudo /bin/bash -c "echo 127.0.0.1 localhost $HOSTNAME >   rootfs/etc/hosts"
sudo sed -i "s/127.0.0.1	localhost/127.0.0.1	localhost $HOSTNAME/" rootfs/etc/hosts

#
#  This creates rootfs/etc/network/interfaces.d/fm1-mac3:
#
sudo /bin/bash -c "echo auto fm1-mac3 >      rootfs/etc/network/interfaces.d/fm1-mac3"
sudo sed -i "\$aiface fm1-mac3 inet static"  rootfs/etc/network/interfaces.d/fm1-mac3
sudo sed -i "\$a    address 192.168.7.2"     rootfs/etc/network/interfaces.d/fm1-mac3
sudo sed -i "\$a    netmask 255.255.255.0"   rootfs/etc/network/interfaces.d/fm1-mac3
sudo sed -i "\$a    broadcast 255.255.7.255" rootfs/etc/network/interfaces.d/fm1-mac3
sudo sed -i "\$a    gateway 192.168.7.4"     rootfs/etc/network/interfaces.d/fm1-mac3


#
#   Creates /etc/resolv.conf
#
sudo rm -f                                   rootfs/etc/resolv.conf
sudo touch                                   rootfs/etc/resolv.conf
sudo ed  rootfs/etc/resolv.conf << yEOF
a
nameserver 8.8.8.8
options edns0
.
w
yEOF
#sudo ln -s /var/run/resolvconf/resolv.conf         rootfs/etc/resolv.conf



#
#   Creates /etc/fstab
#
#sudo sed -i "\$aproc     /proc      proc      defaults     0   0" rootfs/etc/fstab



#
#   Files for implementing tcp/ip over usb
#
sudo cp Custom_Files/busybox/busybox            rootfs/bin
sudo ln -s /bin/busybox                         rootfs/sbin/udhcpd
sudo cp Custom_Files/usb_tcpip/g_ether.conf     rootfs/etc/modules-load.d
sudo cp Custom_Files/usb_tcpip/udhcpd.conf      rootfs/etc/udhcpd.conf


#
#    An example of a simple addition to an existing file
#    Add to the skel file also
#    
sudo sed -i "\$aalias dir='ls -CF'" rootfs/root/.bashrc
sudo sed -i "\$aalias dir='ls -CF'" rootfs/etc/skel/.bashrc


#
#    'source directory' thing in /etc/network/interfaces
#    
sudo sed -i "\$asource-directory /etc/network/interfaces.d"   rootfs/etc/network/interfaces

#
#    timezone thing
#    
sudo rm -f                                              rootfs/etc/localtime
sudo ln -s /usr/share/zoneinfo/America/Phoenix          rootfs/etc/localtime


#
#    Removing this allows apt-get update to work
#
sudo rm -f                                              rootfs/etc/apt/apt.conf




#
#    Can remove the original tarball,
#
rm ./$UBUNTU_NAME




#-----------------------------------------------------------------------------------
#
#   Remove bootpart, then re-create it
#
sudo rm -rf bootpart
mkdir bootpart


#
#   Boot Partition, binaries, from NXP site
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
#rm -rf bootpart/modules/*
sudo rm -f                                          rootfs/lib/modules
sudo mkdir                                          rootfs/lib/modules

#
#   Writes modules
#
#sudo rsync -avD /tmp/tmpXX/lib/modules/*             bootpart/modules
sudo rsync -avD /tmp/tmpXX/lib/modules/*              rootfs/lib/modules


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
sudo cp $KERNEL_DIR/arch/arm64/boot/dts/freescale/$DTB_NAME .
#sudo rm -rf flash_images secboot_hdrs
sudo rm *.itb
popd




