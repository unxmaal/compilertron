#!/bin/bash
export PREFIX=/opt/sgug
export IRIX=/opt/irix-root

cd /root/rpmbuild/SOURCES/binutils-2.23.2
./configure --prefix=$PREFIX --target=mips-sgi-irix6.5 --disable-werror --with-sysroot=$IRIX
make
make install

