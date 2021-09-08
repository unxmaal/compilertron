#-------------------------
# Use fedora 31; latest fedora has a glibc too new for Ubuntu 20.04
FROM fedora:33 as base

RUN dnf -y update && dnf -y install bzip2

#-------------------------
# Download everything up-front, to avoid untarring and everything in the various layers
# download-base will contain the irix root (with sgug files) in /tmp/irix-root,
# and the binutils and gcc SRPMS in /tmp/SRPMS/*
FROM base as download-base

# Where to download the root filesystem
ARG irix_root_url=http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2
# What sgug version to use for constructing release files
ARG sgug_version=0.0.7beta
ARG sgug_base_url=https://github.com/sgidevnet/sgug-rse/releases/download/v${sgug_version}
# can override these to download from a specific location
ARG sgug_srpms_url=${sgug_base_url}/sgug-rse-srpms-${sgug_version}.tar.gz
ARG sgug_selfhoster_url=${sgug_base_url}/sgug-rse-selfhoster-${sgug_version}.tar.gz

RUN curl -Lf ${irix_root_url} -o /tmp/irix-root.tar.bz2
RUN curl -Lf ${sgug_srpms_url} -o /tmp/sgug-srpms.tar.gz
RUN curl -Lf ${sgug_selfhoster_url} -o /tmp/sgug-selfhoster.tar.gz
RUN mkdir -p /tmp/irix-root && tar -xaf /tmp/irix-root.tar.bz2 -C /tmp/irix-root
RUN tar -xaf /tmp/sgug-selfhoster.tar.gz -C /tmp/irix-root/usr
RUN tar -xaf /tmp/sgug-srpms.tar.gz -C /tmp --wildcards "SRPMS/binutils-2*" "SRPMS/gcc-9*"

#-------------------------
# Now start building the actual image
FROM base as sgug_base

RUN dnf -y install \
	@development-tools \
	gcc-c++ make automake \
	gmp-devel mpfr-devel libmpc-devel \
	texinfo \
    rsync \
	distcc-server

RUN mkdir -p /opt/irix-base/sgug && \
    mkdir -p /opt/tmp && \
    ln -s /opt/irix-base /opt/irix

COPY --from=download-base /tmp/irix-root /opt/irix/root

#-------------------------
FROM sgug_base as sgug_binutils

# Note: assumption in build script that this is binutils-2.23.2
COPY files/build_binutils.sh /tmp/build_binutils.sh
COPY --from=download-base /tmp/SRPMS/binutils-2*.src.rpm /tmp/binutils.sgug.src.rpm
WORKDIR /tmp
RUN chmod +x *.sh && \
    rpm -Uvh binutils.sgug.src.rpm && \
    tar xvzf /root/rpmbuild/SOURCES/binutils-2*.tar.gz -C /root/rpmbuild/SOURCES && \
    ./build_binutils.sh

# Note:
#  binutils installs its own binaries in:
#    $prefix/bin (as $target-$tool)
#    $prefix/$target/bin (as $tool)
#  it installs its own linker scripts in
#    $prefix/$target/lib
#  it installs _target_ libraries (in this case) in
#    $prefix/$target/lib32

#-------------------------
FROM sgug_binutils as sgug_gcc

# Note: assumption in build script that this is gcc-9.2.0-20190812
COPY files/build_gcc.sh /tmp/build_gcc.sh
# FIXME -- once I figure out where this patch file comes from this should go upstream
COPY files/gcc.sgifixes.patch /tmp/gcc.sgifixes.patch
COPY --from=download-base /tmp/SRPMS/gcc-9.2*.sgug.src.rpm /tmp/gcc.sgug.src.rpm
WORKDIR /tmp
RUN chmod +x *.sh && \
    rpm -Uvh gcc.sgug.src.rpm && \
    cp /tmp/gcc.sgifixes.patch /root/rpmbuild/SOURCES && \
    tar xvzf /root/rpmbuild/SOURCES/gcc-9.2*.tar.gz -C /root/rpmbuild/SOURCES && \
    ./build_gcc.sh  

#-------------------------
FROM sgug_base as sgug_distcc

# Copy in built binutils and gcc -- leaving behind all the build steps
COPY --from=sgug_gcc /opt/irix-base/sgug /opt/irix-base/sgug

# We now have all the tools in bin/mips-sgi-irix6.5-*
# We also have a few tools (binutils) in mips-sgi-irix6.5/bin/*
# symlink the ones from bin/mips-sgi-irix6.5 to the bin dir without a prefix,
# because we point DISTCCD_PATH to this directory so it can find gcc as "gcc"
RUN \
     for f in /opt/irix/sgug/bin/mips-sgi-irix6.5-* ; do \
         tool=`echo -n $f | sed 's,.*mips-sgi-irix6.5-,,'` ; \
         ln -sf $f /opt/irix/sgug/mips-sgi-irix6.5/bin/$tool ; \
     done
# I don't think this is necessary, but for correctness let's do it; mirrors update-distcc-symlinks
RUN ln -s /opt/irix/sgug/bin/mips-sgi-irix6.5-{gcc,g++,gcc-9.2.0,c++,cpp} /usr/lib/distcc

FROM sgug_distcc as sgug_env

# dnf and/or rpm look for the pki key in a location that ignores the root; whatever.
RUN mkdir -p /usr/sgug/etc && cp -r /opt/irix/root/usr/sgug/etc/pki /usr/sgug/etc
# the dnf configuration for SGUG/mips
COPY files/sgug-dnf.conf /opt/irix/sgug/etc/sgug-dnf.conf
# hacky hack hack -- make ignorearch also do ignoreos
COPY files/dnf.patch /tmp/dnf.patch

FROM sgug_env as sgug_env2
RUN cd /usr/lib/python3.? && patch -p4 < /tmp/dnf.patch && rm /tmp/dnf.patch
# make a sgug-dnf script in here -- sgug-dnf just runs dnf pointing to sgug-dnf.conf
COPY files/sgug-dnf /opt/irix/sgug/bin

# Set up RPM & dnf
WORKDIR /opt/irix/root

# We need to upgrade the database to sqlite format, since dnf only opens bdb in read-only mode
# RPM has a bug here -- it screws up --root handling with --rebuilddb, and forgets to put in
# the --root when it finally renames the new dir; so it tries to rename from the wrong location
# and that wrong location is on a different docker overlay, so rename won't work.  Doing
# the upgrade in /tmp works though.
# -- only for Fedora 33 and beyond, however berkeley db seems to have endianness issues
RUN cp -r usr/sgug/var/lib/rpm /tmp && \
    rpm --dbpath /tmp/rpm --rebuilddb && \
    rm -rf usr/sgug/var/lib/rpm && \
    mv /tmp/rpm usr/sgug/var/lib/rpm

# The rpm root is the irix root -- /opt/irix/root (not /usr/sgug inside there).
# However the rpm database does not live rooted there, it lives in /opt/irix/root/usr/sgug/var/lib/rpm.
# There's no equivalent to rpm's --dbpath to dnf, so instead we just make a bunch of symlink and move on.
RUN mkdir -p etc lib var/lib && \
	ln -sf ../usr/sgug/lib/rpm lib && \
	ln -sf ../usr/sgug/lib/sgugrse-release lib && \
	ln -sf ../../usr/sgug/var/lib/rpm var/lib && \
	ln -sf ../usr/sgug/etc/yum.repos.d etc && \
	ln -sf ../usr/sgug/etc/os-release etc && \
	ln -sf ../usr/sgug/etc/sgug-release etc && \
	ln -sf ../usr/sgug/etc/sgugrse-release etc && \
	ln -sf ../usr/sgug/etc/system-release etc && \
	ln -sf ../usr/sgug/etc/system-release-cpe etc

# HACK -- we should really just build libstdc++ with gcc; the build here
# seems to look in slightly different locations than the actual built on-disk location.
# But we just hack up some symlinks for the include files; you'll still need -L for
# the libs
RUN mkdir -p /opt/irix/sgug/mips-sgi-irix6.5/include && \
    ln -s /opt/irix/root/usr/sgug/include/c++ /opt/irix/sgug/mips-sgi-irix6.5/include && \
    ln -s 9 /opt/irix/sgug/mips-sgi-irix6.5/include/9.2.0

# FIXME -- should resolve what this should be in the selfhoster tarball
# toggle some enabled bits, first entry only (so we don't enable source rpms)
RUN sed -i '0,/enabled=1/s//enabled=0/' usr/sgug/etc/yum.repos.d/sgugrselocal.repo
RUN sed -i '0,/enabled=0/s//enabled=1/' usr/sgug/etc/yum.repos.d/sgugrse.repo

WORKDIR /tmp

# Remove the symlink, in preparation for the entry script to sort it out
RUN rm /opt/irix

COPY files/entry.sh /opt/irix-base/sgug/etc/entry.sh
RUN chmod +x /opt/irix-base/sgug/etc/entry.sh

ENV LD_LIBRARY_PATH="/opt/irix/sgug/lib:/opt/irix/sgug/usr/lib:/usr/local/lib:${LD_LIBRARY_PATH}"
ENV PATH="/opt/irix/sgug/bin:/opt/irix/sgug/usr/bin:${PATH}"

EXPOSE \  
    3632/tcp \
    8186/tcp

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:8186/ || exit 1

ENTRYPOINT [ "/opt/irix-base/sgug/etc/entry.sh" ]
