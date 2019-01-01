#!/bin/bash

export PATH=/opt/binutils/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

main(){
    cd /opt/scratch
    /opt/gcc/bin/mips-sgi-irix6.5-gcc -o hello hello.c
}

main 
exit $?
