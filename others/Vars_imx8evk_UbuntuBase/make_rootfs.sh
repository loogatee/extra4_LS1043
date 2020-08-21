#!/bin/bash
set -x

VARISCITE_BUILD=/opt/debian_imx8mq-var-dart
UBUNTU_LOCATION=/home/jreed/extra4/Downloads
UBUNTU_NAME="ubuntu-base-16.04.6-base-arm64.tar.gz"
#UBUNTU_NAME="yocto_rootfs.tar.gz"

# wget http://cdimage.ubuntu.com/ubuntu-base/releases/16.04.6/release/$UBUNTU_NAME


HOSTNAME="dartsy"

sudo find Custom_Files -exec chown root {} \; -exec chgrp root {} \;
#sudo chgrp shadow Custom_Files/etc/shadow


sudo rm -rf rootfs
mkdir rootfs

#
#  Grab Ubuntu image, copy it to .
#
cp $UBUNTU_LOCATION/$UBUNTU_NAME .


cd rootfs; sudo tar --numeric-owner -xzf ../$UBUNTU_NAME; cd ..

#
#   Custom_Files to copy to rootfs
#
sudo cp Custom_Files/1stboot_config.sh               rootfs/root
sudo cp Custom_Files/more_packages.sh                rootfs/root
sudo cp Custom_Files/usb_tcpip/usbip.sh              rootfs/root


#
#    Particular to variscite
#
sudo cp Custom_Files/install_debian.sh               rootfs/usr/sbin
sudo cp Custom_Files/mkfs.fat                        rootfs/sbin
sudo ln -s /sbin/mkfs.fat                            rootfs/sbin/mkfs.vfat


#
#    Getty stuff
#
sudo ln -s /lib/systemd/system/getty@.service        rootfs/etc/systemd/system/getty.target.wants/getty@ttymxc0.service
sudo rm -f                                           rootfs/etc/systemd/system/getty.target.wants/getty@tty1.service
sudo rm -f                                           rootfs/lib/systemd/system/getty-static.service



#
#    udev stuff
#
sudo rsync -avD Custom_Files/udev_lib/*               rootfs/lib/udev
sudo rsync -avD Custom_Files/udev_etc/*               rootfs/etc/udev


#
#    debs
#
sudo rsync -avD Custom_Files/network_arm64_debs      rootfs/root
sudo rsync -avD Custom_Files/aptutils_arm64_debs     rootfs/root

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
sudo /bin/bash -c "echo nameserver 8.8.8.8 >         rootfs/etc/resolv.conf"
#sudo ln -s /var/run/resolvconf/resolv.conf          rootfs/etc/resolv.conf

#
#   Creates /etc/fstab
#
sudo sed -i "\$aproc     /proc      proc      defaults     0   0" rootfs/etc/fstab



#
#   busybox, g_ether
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
#
#
rm -f ./$UBUNTU_NAME




sudo cp $VARISCITE_BUILD/output/Image.gz              rootfs/boot
sudo cp $VARISCITE_BUILD/variscite/splash.bmp         rootfs/boot
sudo cp $VARISCITE_BUILD/output/*.dtb                 rootfs/boot

pushd .
cd rootfs/boot
sudo ln -s fsl-imx8mq-var-dart-sd-lvds-cb12.dtb  fsl-imx8mq-var-dart-cb12.dtb
sudo ln -s fsl-imx8mq-var-dart-sd-lvds.dtb       fsl-imx8mq-var-dart.dtb
popd


