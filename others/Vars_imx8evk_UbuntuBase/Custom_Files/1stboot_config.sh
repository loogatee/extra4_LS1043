#!/bin/bash


systemctl disable avahi-daemon


addgroup -g 222 johnr
adduser -h /home/johnr -s /bin/bash -u 222 -G johnr johnr
usermod -aG sudo johnr

