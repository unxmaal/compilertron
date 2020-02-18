#!/bin/bash

cd /root/rpmbuild/SOURCES/gcc-9.2.0-20190812
patch -p1 < ../gcc.sgifixes.patch
cd ..
