#!/bin/bash
export PREFIX=/opt/irix/sgug
export IRIX=/opt/irix/root
export BUILD=/root/rpmbuild/BUILD
export SOURCES=/root/rpmbuild/SOURCES

cd ${SOURCES}/binutils-2.23.2
patch -p1 < ../binutils2_23.sgifixes.patch
cd -

mkdir -p "${BUILD}/binutils-2.23.2"
cd "${BUILD}/binutils-2.23.2"
"${SOURCES}/binutils-2.23.2/configure" \
    --prefix=$PREFIX \
    --target=mips-sgi-irix6.5 \
    --disable-werror \
    --with-sysroot="$IRIX"
make -s -j32
make install
