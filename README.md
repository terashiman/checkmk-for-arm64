Script for building [Checkmk](https://github.com/tribe29/checkmk) that works with the most cost-effective EC2 instance type in AWS.

Tested on Ubuntu 20.04 LTS, AWS EC2 t4g.medium.

### How to build

    $ INSTALL_DEPENDENCIES=1 bash build_check_mk.sh <version>
    e.g.) $ INSTALL_DEPENDENCIES=1 bash build_check_mk.sh 2.0.0b1

### How to Install

    # apt install traceroute dialog graphviz apache2 apache2-utils libdbi1 libnl-3-200 libpango-1.0-0 php-cli php-cgi php-gd php-sqlite3 php-json php-pear smbclient rpcbind unzip xinetd freeradius-utils rpm lcab libgsf-1-114 poppler-utils libpq5
    # dpkg -i check-mk-raw-*_arm64.deb
    e.g.) # dpkg -i check-mk-raw-2.0.0b1_0.focal_arm64.deb

### Patches

#### Remove module navicli

note: navicli is only released as a binary for the i386/x86_64 architecture, so it cannot be used on arm64 systems.

    cp omd/Makefile omd/Makefile_v2
    vim omd/Makefile_v2
    -    navicli \
    diff -u omd/Makefile omd/Makefile_v2 > ../omd-Makefile-remove-module-navicli.patch

