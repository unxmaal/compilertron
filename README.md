# Overview

Compilertron creates a cross-compiler VM. 

Currently effort is focused on IRIX.

Run 'vagrant up' to create and provision the VM.

# Road Map
## Done
* Debian VM
* Additional 50gb volume at /opt
* fetches gcc

## Remaining

# copy irix /lib32 /usr/lib32 /usr/include to /opt/irix-root
# build binutils-2.17
./configure --target=mips-sgi-irix6.5 --prefix=/opt/irix-binutils --with-sysroot=/opt/irix-root --enable-werror=no
make 
make install

# add /opt/irix-binutils/bin to your path
# create a separate build directory for gcc 4.7.4 and enter it
# run these commands - note how the configure script is run from other directory:
export AS_FOR_TARGET="mips-sgi-irix6.5-as"
export LD_FOR_TARGET="mips-sgi-irix6.5-ld"
export NM_FOR_TARGET="mips-sgi-irix6.5-nm"
export OBJDUMP_FOR_TARGET="mips-sgi-irix6.5-objdump"
export RANLIB_FOR_TARGET="mips-sgi-irix6.5-ranlib"
export STRIP_FOR_TARGET="mips-sgi-irix6.5-strip"
export READELF_FOR_TARGET="mips-sgi-irix6.5-readelf"
export target_configargs="--enable-libstdcxx-threads=no"
/opt/src/gcc-4.7.4/configure --enable-obsolete --disable-multilib --prefix=/opt/irix-gcc --target=mips-sgi-irix6.5 --disable-nls --enable-languages=c,c++
make

# creating gcc info file may fail - in that case, just touch gcc/doc/gcc.info and restart make
# libstdc++ may have a couple of issues building but it is buildable
 - please tell when you hit them, they can be circumvented by slightly
 editing c++config.h (possibly this could be done in crossconfig.m4
 already)
