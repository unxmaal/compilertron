#!/bin/bash

export AS_FOR_TARGET="mips-sgi-irix6.5-as"
export LD_FOR_TARGET="mips-sgi-irix6.5-ld"
export NM_FOR_TARGET="mips-sgi-irix6.5-nm"
export OBJDUMP_FOR_TARGET="mips-sgi-irix6.5-objdump"
export RANLIB_FOR_TARGET="mips-sgi-irix6.5-ranlib"
export STRIP_FOR_TARGET="mips-sgi-irix6.5-strip"
export READELF_FOR_TARGET="mips-sgi-irix6.5-readelf"
export target_configargs="--enable-libstdcxx-threads=no"

main(){
    touch /opt/src/gcc/gcc/doc/gcc.info
    cd /opt/src/gcc
    /opt/src/gcc/configure --enable-obsolete --disable-multilib --prefix=/opt/gcc --target=mips-sgi-irix6.5 --disable-nls --enable-languages=c,c++
    make
    make install
}

main
exit $?