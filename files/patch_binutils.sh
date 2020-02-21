#!/bin/bash

cd /root/rpmbuild/SOURCES/binutils-2.23.2
patch -p1 < ../binutils2_23.sgifixes.patch
cd -