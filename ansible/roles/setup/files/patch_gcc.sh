#!/bin/bash

cd /root/rpmbuild/SOURCES/gcc-9.2.0-20190812
patch -p0 < ../gcc9-hack.patch
patch -p0 < ../gcc9-i386-libgomp.patch
patch -p0 < ../gcc9-sparc-config-detection.patch
patch -p0 < ../gcc9-libgomp-omp_h-multilib.patch
patch -p0 < ../gcc9-isl-dl.patch
patch -p0 < ../gcc9-libstdc++-docs.patch
patch -p0 < ../gcc9-no-add-needed.patch
patch -p0 < ../gcc9-foffload-default.patch
patch -p0 < ../gcc9-Wno-format-security.patch
patch -p0 < ../gcc9-rh1574936.patch
patch -p0 < ../gcc9-d-shared-libphobos.patch
patch -p1 < ../gcc.sgifixes.patch
cd ..