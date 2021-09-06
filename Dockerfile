FROM fedora:latest as base

RUN dnf -y update
RUN dnf -y install \
	@development-tools \
	gcc-c++ make automake \
	gmp-devel mpfr-devel libmpc-devel \
	bzip2 \
	texinfo \
	distcc

FROM base as sgug
RUN mkdir -p /opt/sgug && \
    mkdir -p /opt/irix-root

WORKDIR /opt
RUN curl -OL http://mirror.larbob.org/compilertron/irix-root.6.5.30.tar.bz2
RUN tar -xvjf /opt/irix-root.6.5.30.tar.bz2 -C /opt/irix-root

#-------------------------
FROM sgug as sgug_srpms

WORKDIR /opt/sgug
RUN curl -OL https://github.com/sgidevnet/sgug-rse/releases/download/v0.0.6beta/sgug-rse-srpms-0.0.6beta.tar.gz
RUN tar -xvf sgug-rse-srpms*.tar.gz

# #-------------------------
FROM sgug as sgug_binutils

COPY files/make_binutils.sh /opt/sgug/make_binutils.sh
COPY files/patch_binutils.sh /opt/sgug/patch_binutils.sh
COPY --from=sgug_srpms /opt/sgug/SRPMS/binutils-2.23.2-25.sgug.src.rpm /opt/sgug/binutils-2.23.2-25.sgug.src.rpm
RUN chmod +x /opt/sgug/*.sh && \
    rpm -Uvh /opt/sgug/binutils-2.23.2-25.sgug.src.rpm && \
    tar xvzf /root/rpmbuild/SOURCES/binutils-2.23.2.tar.gz -C /root/rpmbuild/SOURCES && \
    /opt/sgug/patch_binutils.sh && \
    /opt/sgug/make_binutils.sh

#-------------------------
FROM sgug_binutils as sgug_gcc

COPY files/patch_gcc.sh /opt/sgug/patch_gcc.sh
COPY files/build_gcc.sh /opt/sgug/build_gcc.sh
COPY --from=sgug_srpms /opt/sgug/SRPMS/gcc-9.2*.sgug.src.rpm /opt/sgug/gcc-9.2.0-1.sgug.src.rpm
RUN chmod +x /opt/sgug/*.sh && \
    rpm -Uvh /opt/sgug/gcc-9.2.0-1.sgug.src.rpm && \
    tar xvzf /root/rpmbuild/SOURCES/gcc-9.2*.tar.gz -C /root/rpmbuild/SOURCES && \
    /opt/sgug/patch_gcc.sh && \
    /opt/sgug/build_gcc.sh  

#-------------------------
FROM base as sgug_distcc

#FROM  sgug_gcc as sgug_distcc
COPY --from=sgug_gcc /opt/sgug /opt/sgug
COPY --from=sgug_gcc /opt/irix-root /opt/irix-root

COPY files/entry.sh /opt/sgug/entry.sh
COPY files/update-distcc-symlinks.py /opt/sgug/update-distcc-symlinks.py
RUN chmod +x /opt/sgug/entry.sh && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/cc && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-addr2line /opt/sgug/mips-sgi-irix6.5/bin/addr2line && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++ /opt/sgug/mips-sgi-irix6.5/bin/c++ && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++filt /opt/sgug/mips-sgi-irix6.5/bin/c++filt && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-cpp /opt/sgug/mips-sgi-irix6.5/bin/cpp && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-elfedit /opt/sgug/mips-sgi-irix6.5/bin/elfedit && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-g++ /opt/sgug/mips-sgi-irix6.5/bin/g++ && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/gcc && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc-9.2.0 /opt/sgug/mips-sgi-irix6.5/bin/gcc-9.2.0 && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov /opt/sgug/mips-sgi-irix6.5/bin/gcov && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-dump /opt/sgug/mips-sgi-irix6.5/bin/gcov-dump && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-tool /opt/sgug/mips-sgi-irix6.5/bin/gcov-tool && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-readelf /opt/sgug/mips-sgi-irix6.5/bin/readelf && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-size /opt/sgug/mips-sgi-irix6.5/bin/size && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-strings /opt/sgug/mips-sgi-irix6.5/bin/strings && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-cc && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-addr2line /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-addr2line && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++ /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-c++ && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++filt /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-c++filt && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-cpp /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-cpp && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-elfedit /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-elfedit && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-g++ /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-g++ && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-gcc && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc-9.2.0 /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-gcc-9.2.0 && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-gcov && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-dump /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-gcov-dump && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-tool /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-gcov-tool && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-readelf /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-readelf && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-size /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-size && \
    ln -s /opt/sgug/bin/mips-sgi-irix6.5-strings /opt/sgug/mips-sgi-irix6.5/bin/mips-sgi-irix6.5-strings && \
    python3 /opt/sgug/update-distcc-symlinks.py \
    ln -s -b /opt/sgug/bin/mips-sgi-irix6.5-* /usr/lib/distcc/

FROM sgug_distcc as sgug_env

WORKDIR /opt/sgug
RUN curl -OL https://github.com/sgidevnet/sgug-rse/releases/download/v0.0.7beta/sgug-rse-selfhoster-0.0.7beta.tar.gz
RUN tar -C /opt/irix-root/usr -xzf sgug-rse-selfhoster-0.0.7beta.tar.gz

# This makes it easier to find the gpg key -- come to think of it, doing this will make it
# easier to install things too, we wouldn't need to specify root but w/e
RUN ln -s /opt/irix-root/usr/sgug /usr/sgug
COPY files/sgug-dnf.conf /opt/sgug/sgug-dnf.conf
# hacky hack hack -- make ignorearch also do ignoreos
COPY files/dnf.patch /opt/sgug/dnf.patch
RUN patch -d/ -p0 < /opt/sgug/dnf.patch
COPY files/sdnf /opt/sgug/bin

# we need to upgrade the rpm store to sqlite, or dnf won't touch it.  For some reason it fails to replace
# the old lib, so we do it manually
RUN rpm --root /opt/irix-root/usr/sgug --rebuilddb ; \
	mv /opt/irix-root/usr/sgug/var/lib/rpm /opt/irix-root/usr/sgug/var/lib/rpm.orig && \
	mv /opt/irix-root/usr/sgug/var/lib/rpmrebuilddb.*/ /opt/irix-root/usr/sgug/var/lib/rpm

# toggle some enabled bits, first entry only (so we don't enable source rpms)
RUN sed -i '0,/enabled=1/s//enabled=0/' /usr/sgug/etc/yum.repos.d/sgugrselocal.repo
RUN sed -i '0,/enabled=0/s//enabled=1/' /usr/sgug/etc/yum.repos.d/sgugrse.repo

ENV LD_LIBRARY_PATH="/opt/sgug/lib:/opt/sgug/usr/lib:/usr/local/lib:${LD_LIBRARY_PATH}"
ENV PATH="/opt/sgug/bin:/opt/sgug/usr/bin:${PATH}"

#EXPOSE \  
#    3632/tcp \
#    8186/tcp
#
#HEALTHCHECK --interval=5m --timeout=3s \
#  CMD curl -f http://0.0.0.0:8186/ || exit 1

ENTRYPOINT /usr/bin/tail -f /dev/null
