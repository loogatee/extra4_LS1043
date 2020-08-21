#!/bin/bash
set -x


#locale-gen en_US.UTF-8

#
# useful
#
#apt-get -y  install iptables
#apt-get -y  install usbutils
#apt-get -y  install vim
#apt-get -y  install ntp
#apt-get -y  install git
#apt-get -y  install curl
#apt-get -y  install lrzsz
#apt-get -y  install minicom
#apt-get -y  install sshfs
#apt-get -y  install lua5.1
#apt-get -y  install rsync


#
#  wifi
#
#apt-get -y  install wireless-tools
#apt-get -y  install wpasupplicant
#cp /lib/firmware/brcm/wpa_supplicant.conf /etc/wpa_supplicant


#
#   Node:  this might be out-of-date
#
#curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
#sudo apt-get install -y nodejs


#
#  --------- Now do some procedures
#



#
#  static IP for Google TimeServer.  I think ubuntu's are swamped
#
#sed -i "s/0.ubuntu.pool.ntp.org/216.239.35.0/" /etc/ntp.conf



#
#  udev rule for ttyUSB
#
#/bin/bash -c 'echo SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"0403\", ATTRS{idProduct}==\"6001\", MODE=\"0666\" > /etc/udev/rules.d/99-usb-serial.rules'
#
# http://vncprado.github.io/udev-rules-for-ttyusb/
#     udevadm info -a -n /dev/ttyUSB0 | grep '{serial}' | head -n1
#     SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", ATTRS{serial}=="A6008isP", SYMLINK+="ttyUSB.arduino"
#

#
#
#
#chmod 777 /opt
#git clone https://github.com/mascarenhas/alien.git /opt/alien
#cd /opt/alien; luarocks install alien FFI_LIBDIR=/usr/lib/arm-linux-gnueabihf



#
#  Setup routing??
#
# sudo sysctl -w net.ipv4.ip_forward=1
# sudo iptables -A FORWARD -i wlan0 -j ACCEPT
# sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# echo "1" > /proc/sys/net/ipv4/ip_dynaddr
# echo "1" > /proc/sys/net/ipv4/ip_forward
# iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE












