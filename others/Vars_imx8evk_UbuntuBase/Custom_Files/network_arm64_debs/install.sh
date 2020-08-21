#!/bin/bash
set -x

dpkg -i libkmod2_22-1ubuntu4_arm64.deb;                          echo ""
dpkg -i kmod_22-1ubuntu4_arm64.deb;                              echo ""

dpkg -i libudev1_229-4ubuntu4_arm64.deb;                         echo ""
dpkg -i udev_229-4ubuntu4_arm64.deb;                             echo ""

dpkg -i sudo_1.8.16-0ubuntu1_arm64.deb;                          echo ""
dpkg -i libgmp10_6.1.0+dfsg-2_arm64.deb;                         echo ""
dpkg -i libidn11_1.32-3ubuntu1_arm64.deb;                        echo ""
dpkg -i libmnl0_1.0.3-5_arm64.deb;                               echo ""
dpkg -i libnettle6_3.2-1_arm64.deb;                              echo ""
dpkg -i libffi6_3.2.1-4_arm64.deb;                               echo ""
dpkg -i libhogweed4_3.2-1_arm64.deb;                             echo ""
dpkg -i libp11-kit0_0.23.2-3_arm64.deb;                          echo ""
dpkg -i libtasn1-6_4.7-3_arm64.deb;                              echo ""
dpkg -i libgnutls30_3.4.10-4ubuntu1_arm64.deb;                   echo ""
dpkg -i libgnutls-openssl27_3.4.10-4ubuntu1_arm64.deb;           echo ""
dpkg -i net-tools_1.60-26ubuntu1_arm64.deb;                      echo ""
dpkg -i iproute2_4.3.0-1ubuntu3_arm64.deb;                       echo ""
dpkg -i libisc-export160_9.10.3.dfsg.P4-8ubuntu1.16_arm64.deb;   echo ""
dpkg -i libdns-export162_9.10.3.dfsg.P4-8ubuntu1.16_arm64.deb;   echo ""
dpkg -i ifupdown_0.8.10ubuntu1_arm64.deb;                        echo ""
#dpkg -i isc-dhcp-client_4.3.3-5ubuntu12_arm64.deb;               echo ""
dpkg -i iputils-ping_20121221-5ubuntu2_arm64.deb;                echo ""

apt-get install -f



#
#  This creates rootfs/etc/network/interfaces.d/lo:
#
/bin/bash -c "echo auto lo >       /etc/network/interfaces.d/lo"
sed -i "\$aiface lo inet loopback" /etc/network/interfaces.d/lo

#
#  This creates rootfs/etc/network/interfaces.d/eth0:
#
/bin/bash -c "echo auto eth0 >          /etc/network/interfaces.d/eth0"
sed -i "\$aiface eth0 inet static"      /etc/network/interfaces.d/eth0
sed -i "\$a    address 192.168.7.2"     /etc/network/interfaces.d/eth0
sed -i "\$a    netmask 255.255.255.0"   /etc/network/interfaces.d/eth0
sed -i "\$a    broadcast 255.255.7.255" /etc/network/interfaces.d/eth0
sed -i "\$a    gateway 192.168.7.4"     /etc/network/interfaces.d/eth0

udevadm control --reload-rules ; udevadm trigger

ifup -v eth0

#
#  This creates rootfs/etc/network/interfaces.d/eth0:
#
#/bin/bash -c "echo auto eth0 >   /etc/network/interfaces.d/eth0"
#sed -i "\$aiface eth0 inet dhcp" /etc/network/interfaces.d/eth0

pushd .
cd /etc/systemd/system/getty.target.wants/
rm getty@ttymxc0.service
ln -s /lib/systemd/system/serial-getty@.service getty@ttymxc0.service
popd





