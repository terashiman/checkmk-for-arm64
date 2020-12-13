#!/bin/bash

VERSION="2.0.0b1"
SNAP7_VERSION="1.4.2"

if [ $# -gt 0 ]; then
  VERSION="$1"
fi

echo "building Check_MK ${VERSION}..."

# get check_mk sources and build dependencies
if [ ${INSTALL_DEPENDENCIES:-0} -eq 1 ]; then
    apt-get -y install apache2 build-essential chrpath cmake debhelper dnsutils dpatch flex fping git git-buildpackage make rpcbind \
        rrdtool smbclient snmp apache2-dev default-libmysqlclient-dev dietlibc-dev libboost-all-dev libboost-dev \
        libdbi-dev libevent-dev libffi-dev libfreeradius-dev libgd-dev libglib2.0-dev \
        libgnutls28-dev libgsf-1-dev libkrb5-dev libmcrypt-dev libncurses-dev libpango1.0-dev libpcap-dev libperl-dev \
        libpq-dev libreadline-dev librrd-dev libsqlite3-dev libssl-dev libxml2-dev tk-dev uuid-dev
fi

wget -qO- https://mathias-kettner.de/support/${VERSION}/check-mk-raw-${VERSION}.cre.tar.gz | tar -xvz
cd check-mk-raw-${VERSION}.cre
./configure --with-boost-libdir=/usr/lib/arm-linux-gnueabihf

# patch files
patch -p0 < ../omd-Makefile-remove-module-navicli.patch
#patch -p0 < ../omdlib-reduce-certificate-maximum-validity-period.patch
#patch -p0 < ../python-make-add-fno-semantic-interposition.patch

# prepare snap7
wget -qO omd/packages/snap7/snap7-iot-arm-${SNAP7_VERSION}.tar.gz https://jaist.dl.sourceforge.net/project/snap7/Snap7-IoT/snap7-iot-arm/snap7-iot-arm-1.4.2.tar.gz
tar -xvzf omd/packages/snap7/snap7-iot-arm-${SNAP7_VERSION}.tar.gz -C omd/packages/snap7
mv omd/packages/snap7/snap7-iot-arm-${SNAP7_VERSION} omd/packages/snap7/snap7-${SNAP7_VERSION}
cp omd/packages/snap7/snap7-${SNAP7_VERSION}/build/unix/arm_v7_x64_linux.mk omd/packages/snap7/snap7-${SNAP7_VERSION}/build/unix/aarch64_linux.mk
ln -s arm_v7_x64-linux omd/packages/snap7/snap7-${SNAP7_VERSION}/build/bin/aarch64-linux
tar czf omd/packages/snap7/snap7-${SNAP7_VERSION}.tar.gz -C omd/packages/snap7 snap7-${SNAP7_VERSION}

sed -i -e 's/x86_64/aarch64/g' ./omd/packages/Python3/Python3.make
sed -i -e 's: ./configure: cp -af /usr/share/misc/config.guess . \&\& ./configure:' ./omd/packages/net-snmp/net-snmp.make
sed -i -e 's: ./configure: cp -af /usr/share/misc/config.guess . \&\& ./configure:' ./omd/packages/nagios/nagios.make
sed -i -e 's: ./configure: cp -af /usr/share/misc/config.guess . \&\& ./configure:' ./omd/packages/nsca/nsca.make
sed -i -e 's: ./configure: cp -af /usr/share/misc/config.guess . \&\& ./configure:' ./omd/packages/pnp4nagios/pnp4nagios.make

# compile and package
make deb

# cleanup
if [ $? -eq 0 ]; then
    mv check-mk-raw-${VERSION}* ..
    cd ..
    rm -rf check-mk-raw-${VERSION}.cre
fi
