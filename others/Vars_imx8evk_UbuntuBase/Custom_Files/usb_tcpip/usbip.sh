#!/bin/bash


modprobe g_ether
ifconfig usb0 up
ifconfig usb0 192.168.5.2

sleep 1
/sbin/udhcpd -S /etc/udhcpd.conf &



















