#!/bin/bash

#
#  Best to execute this manually.  Verify it works.   THEN execute 1stboot
#
#cd network_arm64_debs; ./install.sh; cd ..

#apt-get update


#apt-get -y  install dialog
#apt-get -y  install apt-utils
#apt-get -y  install locales
#apt-get -y  install nvi
#apt-get -y  install ntp

#locale-gen en_US.UTF-8
#dpkg-reconfigure locales

#cd openssh_arm64_debs; ./install.sh; cd ..

#apt-get -y  install lua5.1
#apt-get -y  install liblua5.1-0-dev
#apt-get -y  install libfcgi-dev
#apt-get -y  install rsync
#apt-get -y  install libffi6
#apt-get -y  install libffi-dev
#apt-get -y  install lua-socket
#apt-get -y  install lua-bitop
#apt-get -y  install luarocks
#apt-get -y  install libzmq5
#apt-get -y  install libzmq3-dev

#
#  static IP for Google TimeServer.  I think ubuntu's are swamped
#
#sed -i "s/0.ubuntu.pool.ntp.org/216.239.35.0/" /etc/ntp.conf


addgroup --gid 222 johnr
adduser --home /home/johnr --shell /bin/bash --uid 222 --gid 222 johnr
usermod -aG sudo johnr

