

1.   gunzip the image

         gunzip YoctoImageNXP.img.gz


2.   YoctoImageNXP.img is 2 gigabytes.    'dd' this onto an sdcard.
     Replace /dev/sdb with the sdcard block device on your system.

         sudo dd if=YoctoImageNXP.img of=/dev/sdb bs=1M


3.   Resize the rootfs if you'd like.   THIS IS NOT NECESSARY, but
     gives you more room in rootfs.    You might want to do this
     if you have an 8G, 16G, or 32G card.


     sudo gparted /dev/sdb

         a.  Right Click on the line with /dev/sdb2, ext4, rootfs
         b.  Select 'Resize/Move'
         c.  Change 'New size' to value appropriate for your sdcard.
             You can add all the 'Free space' into 'New size'
         d.  Hit the Apply icon.   It's the check-mark.


4.   Connect usb cable:  NXP OTG port (USB micro) to Ubuntu USB port.  Open serial terminal.
     I use minicom.   In this way, you can observe the boot-up.

         minicom -b 115200 -D /dev/ttyUSB0 -o -8


5.   Place sdcard in NXP, and boot.   Login as root.  (no password)

         <placeholder>

6.   Modify 1stboot_config.sh for the purpose of adding a user.
     The example shows adding user 'johnr'.   Change this to
     the user you would like to add.

          vi 1stboot_config.sh
          ./1stboot_config.sh

--------------------------------------------------------------------
--------------------------------------------------------------------

** Notes on functionality in the build **


1.  The build does not contain hdmi capability.   A graphical
    monitor is not possible.

        <placeholder>


2.  eth0 configuration is static with IP address of 192.168.7.2.
    It expects the gateway to be 192.168.7.4

        To modify:  /lib/systemd/network/80-wired.network


3.  connman has been setup to blacklist eth0, so that it will not
    interfere with systemd network settings.

        See:        /etc/connman/main.conf


4.  nameserver is set to 8.8.8.8

        See:        /etc/resolv.conf


5.  ssh, scp, and sftp all work as expected
    Some examples, using login johnr.

        ssh -l johnr 192.168.7.2

        scp /tmp/xyz.txt johnr@192.168.7.2:~

        kubuntu file browser 'dolphin':

              Network -> Add Network Folder -> Secure shell (ssh)

              Server configuration:

                  sftp://johnr@192.168.7.2:22


6.  The release contains 'buildessential' so compiler and build tools are on the target

        which gcc


7.  Instructions for connecting to the modem, and acquiring service


    A.   Unplug the ethernet cable.   All my testing was done with the ethernet
         cable unplugged.

    B.   Modify /etc/qmi-network.conf to change the APN of the SIM card plugged
         into the Telit modem.

             <placeholder>

    C.   Issue the qmi-qmi-network /dev/cdc-wdm0 start

             qmi-network /dev/cdc-wdm0 start

    D.   Get an IP address from the LTE provider:

             udhcpc -i wwan0

    E.   ping google

             ping 8.8.8.8
             ping www.google.com


