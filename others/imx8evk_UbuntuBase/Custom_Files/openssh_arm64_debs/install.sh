#!/bin/bash
set -x


dpkg -i libdbus-1-3_1.10.6-1ubuntu3_arm64.deb;        echo ""
dpkg -i libck-connector0_0.4.6-5_arm64.deb;           echo ""
dpkg -i libkrb5support0_1.13.2+dfsg-5_arm64.deb;      echo ""
dpkg -i libk5crypto3_1.13.2+dfsg-5_arm64.deb;         echo ""
dpkg -i libkeyutils1_1.5.9-8ubuntu1_arm64.deb;        echo ""
dpkg -i libkrb5-3_1.13.2+dfsg-5_arm64.deb;            echo ""
dpkg -i libgssapi-krb5-2_1.13.2+dfsg-5_arm64.deb;     echo ""
dpkg -i libwrap0_7.6.q-25_arm64.deb;                  echo ""
dpkg -i libbsd0_0.8.2-1_arm64.deb;                    echo ""
dpkg -i libedit2_3.1-20150325-1ubuntu2_arm64.deb;     echo ""
dpkg -i libbsd0_0.8.2-1_arm64.deb;                    echo ""
dpkg -i libssl1.0.0_1.0.2g-1ubuntu4_arm64.deb;        echo ""
dpkg -i openssh-client_7.2p2-4_arm64.deb;             echo ""
dpkg -i openssh-sftp-server_7.2p2-4_arm64.deb;        echo ""
dpkg -i openssh-server_7.2p2-4_arm64.deb;             echo ""

/bin/sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
/usr/sbin/service ssh restart

