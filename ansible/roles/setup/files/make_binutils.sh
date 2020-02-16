#!/bin/bash
export PREFIX=/opt/sgug
export IRIX=/opt/irix-root

mkdir -p /root/rpmbuild/BUILD/binutils-2.23.2
cd /root/rpmbuild/BUILD/binutils-2.23.2
/root/rpmbuild/SOURCES/binutils-2.23.2/configure --prefix=$PREFIX \
    --target=mips-sgi-irix6.5 \
    --disable-werror \
    --with-sysroot=$IRIX
make
make install