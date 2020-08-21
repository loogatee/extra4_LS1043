#!/bin/bash
set -x

UBUNTU_LOCATION=/home/jreed/extra4/Downloads
KERNEL_DIR=/opt/linux-imx

HOSTNAME="imx8evk"

UBUNTU_NAME="ubuntu-base-16.04.6-base-arm64.tar.gz"



#
#   The Custom files need to have the correct owner/group
#     - All files owned by root
#     - All files are root group except for /etc/shadow
#
sudo find Custom_Files -exec chown root {} \; -exec chgrp root {} \;
#sudo chgrp shadow Custom_Files/etc/shadow


#
#   Remove rootfs, then re-create it
#
sudo rm -rf rootfs
mkdir rootfs


#
#  If it's there locally, then grab it
#  Else get if from the repo
#
if test -f $UBUNTU_LOCATION/$UBUNTU_NAME
then
    cp $UBUNTU_LOCATION/$UBUNTU_NAME .
    TMP1=0
else
    wget http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.6/release/$UBUNTU_NAME
    TMP1=1
fi


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
sudo ln -s /lib/systemd/system/getty@.service        rootfs/etc/systemd/system/getty.target.wants/getty@ttymxc0.service
sudo rm -f                                           rootfs/lib/systemd/system/getty-static.service


#
#    udev stuff
#
sudo rsync -avD Custom_Files/udev_lib/*               rootfs/lib/udev
sudo rsync -avD Custom_Files/udev_etc/*               rootfs/etc/udev


#
#  debs
#
sudo rsync -avD Custom_Files/network_arm64_debs       rootfs/root
sudo rsync -avD Custom_Files/aptutils_arm64_debs      rootfs/root
sudo rsync -avD Custom_Files/openssh_arm64_debs       rootfs/root


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
#sudo ln -s /var/run/resolvconf/resolv.conf         rootfs/etc/resolv.conf


#
#   Creates /etc/fstab
#
sudo sed -i "\$aproc     /proc      proc      defaults     0   0" rootfs/etc/fstab



#
#
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
#    Can remove the original tarball,
#    or copy to local location if it's not there yet
#
if test $TMP1 = 1
then
    mv ./$UBUNTU_NAME $UBUNTU_LOCATION
else
    rm ./$UBUNTU_NAME
fi


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
sudo cp $KERNEL_DIR/arch/arm64/boot/Image              rootfs/boot
sudo rsync -avD /tmp/tmpXX/lib/modules                 rootfs/lib

#
#   Uncomment if you have a local copy of firmware
#
#sudo rsync -avD ../evkbinaries/rootfs/lib/firmware     rootfs/lib


