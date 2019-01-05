
# Compiling Bash

As root user:

* Create a .bashrc file
```export PATH="/opt/binutils/bin:/opt/gcc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export CC="/opt/gcc/bin/mips-sgi-irix6.5-gcc"
export CXX="/opt/gcc/bin/mips-sgi-irix6.5-g++"
export CFLAGS="-B/opt/binutils/bin/mips-sgi-irix6.5- --sysroot=/opt/irix-root"
export CXXFLAGS="-B/opt/binutils/bin/mips-sgi-irix6.5- --sysroot=/opt/irix-root"
export TARGET=mips-sgi-irix6.5
export PREFIX=/opt/gcc
export TARGET_PREFIX=$PREFIX/$TARGET
```
* source it
```
source ~/.bashrc
```

* Get bash source
* Extract bash source tarball to /opt/bash-4.4
* Fix linker issues
```
find . -type f | xargs sed -i 's/-rdynamic/-export-dynamic/g'
```
* Fix gcc lib issue
```
ln -s /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/libgcc/libgcc_s.so.1 /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/libgcc_s.so
```
* Compile bash
```
./configure --prefix=/opt/bash --host=x86_64-unknown-linux-gnu
make
make install
```

# Installation
* create a tarball of /opt/bash
```
tar cvzf bash_4.4-mips.tar.gz /opt/bash
```
* Copy to IRIX system
* Extract to /opt

# Example
```
bash-4.4# /opt/bash/bin/bash --version
GNU bash, version 4.4.0(1)-release (x86_64-unknown-linux-gnu)
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
bash-4.4# uname -a
IRIX64 blue 6.5 07202013 IP35
```

