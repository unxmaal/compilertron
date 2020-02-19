#!/bin/bash
export PREFIX=/opt/sgug
export IRIX=/opt/irix-root
export BUILD=/root/rpmbuild/BUILD


main(){
    if [[ -e "${BUILD}/gcc-9.2.0-20190812" ]] ; then
        rm -rf "${BUILD}/gcc-9.2.0-20190812"
    fi
    mkdir -p "${BUILD}/gcc-9.2.0-20190812"
    cd "${BUILD}/gcc-9.2.0-20190812"

    mkdir -p "${PREFIX}/mips-sgi-irix6.5"

    if [[ -L /usr/lib32 ]] ; then
            unlink /usr/lib32 ;
    elif [[ -e /usr/lib32 ]] ; then
            rm -rf /usr/lib32
    fi

    if [[ -L "${PREFIX}/mips-sgi-irix6.5/sys-include" ]] ; then
            unlink "${PREFIX}/mips-sgi-irix6.5/sys-include"
    elif [[ -e "${PREFIX}/mips-sgi-irix6.5/sys-include" ]] ; then
            rm -rf "${PREFIX}/mips-sgi-irix6.5/sys-include"
    fi

    ln -s "${IRIX}/usr/lib32" /usr/lib32
    ln -s "${IRIX}/usr/include" "${PREFIX}/mips-sgi-irix6.5/sys-include"
    
    /root/rpmbuild/SOURCES/gcc-9.2.0-20190812/configure --enable-obsolete \
        --disable-multilib \
        --prefix="${PREFIX}" \
        --target=mips-sgi-irix6.5 \
        --disable-nls \
        --enable-languages=c,c++,lto \
        --disable-libstdcxx \
        --with-build-sysroot="${IRIX}" \
        --enable-lto \
        --enable-tls=no

    make -j8
    make install
}

main 2>&1 | tee /opt/sgug/gccmake.log
exit $?