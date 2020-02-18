# Overview

Runs compilertron in a docker container

# Prereqs
* Docker
* If you're running Docker in a VM, ensure you allocate 8-16GB RAM and 10 cores
* Otherwise adjust the `make -j##` stanzas in the build scripts

# Setup
* git clone this repo
* obtain the following files and place them in ansible/.
    * sgug_rse: "https://github-production-release-asset-2e65be.s3.amazonaws.com/232236744/b45be480-38a2-11ea-9052-76fadec4c942?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20200215%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20200215T152648Z&X-Amz-Expires=300&X-Amz-Signature=82e979b6d02b423851ac155fcbf06c9eb707237d6ce9a99d9e452f5be633889c&X-Amz-SignedHeaders=host&actor_id=1377410&response-content-disposition=attachment%3B%20filename%3Dsgug-rse-srpms-0.0.3alpha.tar.gz&response-content-type=application%2Foctet-stream"
    * irix_root: "http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2"

# Usage
```
docker build .
```

Stages are listed in the Dockerfile in the FROM entries:
```
FROM  sgug_binutils as sgug_gcc
```
In this example, the stage is 'sgug_gcc'.

You can specify a stage to build, which will skip the prior stages (if they are unchanged), saving time.

```
docker build --target sgug_gcc .
```

# Debugging
Given this error:
```
make[3]: Leaving directory '/root/rpmbuild/BUILD/gcc-9.2.0-20190812/libcc1'
make[2]: Leaving directory '/root/rpmbuild/BUILD/gcc-9.2.0-20190812/libcc1'
/bin/bash: line 3: cd: mips-sgi-irix6.5/libssp: No such file or directory
make[1]: *** [Makefile:11439: install-target-libssp] Error 1
make[1]: Leaving directory '/root/rpmbuild/BUILD/gcc-9.2.0-20190812'
make: *** [Makefile:2315: install] Error 2
Removing intermediate container a1125d4886bc
 ---> 560e87405a9c
 Successfully built 560e87405a9c
 ```

Docker has created a container with id 560e87405a9c . 

You may run it interactively:

```
docker run -it 560e87405a9c bash
```

Note that changes must be made in the Dockerfile and a new container must be built for those changes to persist. Any interactions within a running container are ephemeral.
