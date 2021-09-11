# Overview

This Dockerfile & associated bits create a container that functions as both a
`mips-sgi-irix6.5` distcc compiler server, as well as (optionally) a local
cross-compilation environment.  If used as a cross-compilation environment,
`dnf` can be used inside the container to install mips binary packages from
the SGUG repos.

# Prereqs
* Docker
* If you're running Docker in a VM, ensure you allocate 8-16GB RAM and 10 cores, as this script will build gcc as part of the setup

# Setup
* git clone this repo
* Build the container (see below)
* Enjoy the container

# Usage

## Building the container

Basic build:
```
docker build . -t compilertron
```

As part of the build, a few large files will be downloaded (IRIX root, sgug-rse files).  If you have these available locally, you
can specify build args to get them from a different URL:

```
docker build \
    --tag compilertron \
    --build-arg irix_root_url=http://myserver/sgi/irix-root.6.5.30.tar.bz2 \
    --build-arg sgug_srpms_url=http://myserver/sgi/sgug-rse-srpms-0.0.7beta.tar.gz \
    --build-arg sgug_selfhoster_url=http://myserver/sgi/sgug-rse-selfhoster-0.0.7beta.tar.gz \
    .
```

These downloads happen first, so they will be cached even if you make changes to later parts of the Dockerfile.

Stages are listed in the Dockerfile in the FROM entries:
```
FROM  sgug_binutils as sgug_gcc
```
In this example, the stage is 'sgug_gcc'.

You can specify a stage to build, which will skip the prior stages (if they are unchanged), saving time.

```
docker build --target sgug_gcc .
```

## Using as a distcc server

Just create a container as normal from the image.  See `docker-compose.yaml` for an example.

## Using as a cross-compile environment

Create `/opt/irix` locally, and attach it to `/opt/irix` in the container.  See `docker-compose.yml` for an example.  On first run, the container will copy its internal irix sysroot and compilers into `/opt/irix`, and from that point will use that directory to run from.  The compiler binaries in `/opt/irix/sgug/bin` are available outside of the container.

Note -- you can map another directory from outside of the container to `/opt/irix` inside, e.g. `/foo/cheeseburger:/opt/irix`.  However, _you must
make a symlink from /opt/irix to wherever the real directory is_.  The `/opt/irix` paths are hardcoded into a sysroot in the compiler; if you don't
do this, you'll have to pass sysroot and a bunch of other compile flags, and you don't want to have to do that.

### Installing new packages

The `sgug-dnf` script *inside the container* should be used to install new packages.  They will be installed to the `/opt/irix/root/usr/sgug` directory; in other words, in the normal location in the `/opt/irix/root` sysroot.  Example:

```
docker exec -it compilertron sgug-dnf install zlib-devel
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
