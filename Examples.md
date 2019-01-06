
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

--------------------------------------------
# ncurses

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

* Get ncurses source
* Extract ncurses source tarball to /opt/ncurses-6.1
* Fix linker issues
```
find . -type f | xargs sed -i 's/-D_XOPEN_SOURCE=500//g'
```
* Fix gcc lib issue
```
cp /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/libgcc/libgcc_s.so* /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
cp /opt/src/gcc-build/mips-sgi-irix6.5/libstdc++-v3/src/.libs/libstdc++.so* /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
cp /opt/src/gcc-build/mips-sgi-irix6.5/libstdc++-v3/src/.libs/libstdc++.a /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
```
* Compile ncurses
```
./configure --prefix=/opt/ncurses --host=x86_64-unknown-linux-gnu --enable-pc-files
make
```
* Fix progs/Makefile
/opt/bin/install can't strip the binaries, so remove the '-s' flag here:
```
INSTALL_PROG	= ${INSTALL} -s
```
* make install
```
make install
```

# Installation
* create a tarball of /opt/ncurses
```
tar cvzf ncurses_6.1-mips.tar.gz /opt/ncurses
```
* Copy to IRIX system
* Extract to /opt

--------------------------------------------

# Libevent

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

* Get libevent source
* Extract libevent source tarball to /opt/libevent-2.1.8
* Fix gcc lib issue
```
cp /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/libgcc/libgcc_s.so* /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
cp /opt/src/gcc-build/mips-sgi-irix6.5/libstdc++-v3/src/.libs/libstdc++.so* /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
cp /opt/src/gcc-build/mips-sgi-irix6.5/libstdc++-v3/src/.libs/libstdc++.a /opt/gcc/lib/gcc/mips-sgi-irix6.5/4.7.4/.
```
* Compile libevent
```
./configure --prefix=/opt/libevent --host=x86_64-unknown-linux-gnu --disable-openssl --disable-shared
make
make install
```

# Installation
* create a tarball of /opt/libevent
```
tar cvzf libevent-2.1.8-mips.tar.gz /opt/libevent
```
* Copy to IRIX system
* Extract to /opt

------------------------------

# tmux

As root user:


* Get tmux source
* Extract tmux source tarball to /opt/tmux-2.8
* Set up pkg-config for libevent
```
export PKG_CONFIG_PATH=/opt/libevent/lib/pkgconfig/:$PKG_CONFIG_PATH
pkg-config --cflags --libs libevent
```
* Set up pkg-config for ncurses
```
export PKG_CONFIG_PATH=/opt/ncurses-6.1/misc:$PKG_CONFIG_PATH
pkg-config --cflags --libs ncurses
pkg-config --cflags --libs ncurses++
```


* Compile tmux
```
./configure --prefix=/opt/tmux --host=x86_64-unknown-linux-gnu
--enable-static


./configure --prefix=/opt/tmux --host=x86_64-unknown-linux-gnu  CFLAGS="-I/opt/libevent/include -I/opt/ncurses/include/ncurses" LDFLAGS="-static -L/opt/libevent/lib -L/opt/libevent/include -L/opt/ncurses/lib -L/opt/ncurses/include/ncurses" CPPFLAGS="-I/opt/libevent/include -I/opt/ncurses/include/ncurses" LDFLAGS="-static -L/opt/libevent/lib -L/opt/libevent/include -L/opt/ncurses/lib -L/opt/ncurses/include/ncurses" LIBNCURSES_LIBS LIBNCURSES_CFLAGS

make
make install
```

# Installation
* create a tarball of /opt/libevent
```
tar cvzf libevent-2.1.8-mips.tar.gz /opt/libevent
```
* Copy to IRIX system
* Extract to /opt