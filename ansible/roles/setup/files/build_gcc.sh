#!/bin/bash

main(){

    mkdir -p $PREFIX/mips-sgi-irix6.5

    if [[ ! -e /usr/lib32 ]] ; then
        ln -s $IRIX/usr/lib32 /usr/lib32
    fi
    if [[ ! -e $PREFIX/mips-sgi-irix6.5/sys-include ]] ; then
        ln -s $IRIX/usr/include $PREFIX/mips-sgi-irix6.5/sys-include
    fi
    cd /root/rpmbuild/SOURCES/gcc-9.2.0-20190812

    ./configure --enable-obsolete \
        --disable-multilib \
        --prefix=$PREFIX \
        --target=mips-sgi-irix6.5 \
        --disable-nls \
        --enable-languages=c,c++,lto \
        --disable-libstdcxx \
        --with-build-sysroot=$IRIX \
        --enable-lto \
        --enable-tls=no

    make -j10
    make install
}

main 2>&1 | tee /opt/sgug/gccmake.log
exit $?
