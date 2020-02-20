FROM debian:buster as base

RUN apt-get -y update &&\
    apt-get -y install build-essential \
    bison \
    flex \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    parted \
    texinfo \
    git \
    unzip \
    openssh-server \
    autoconf \
    gettext \
    distcc \
    rpm \
    tree \
    vim \
    file
#-------------------------
FROM base as sgug
RUN mkdir -p /opt/sgug && \
    mkdir -p /opt/irix-root
COPY ansible/irix-root.6.5.30.tar.bz2 /opt/irix-root.6.5.30.tar.bz2
COPY ansible/sgug-rse-srpms-0.0.3alpha.tar.gz /opt/sgug-rse-srpms-0.0.3alpha.tar.gz

RUN tar -xvjf /opt/irix-root.6.5.30.tar.bz2 -C /opt/irix-root && \
    tar -xvzf /opt/sgug-rse-srpms-0.0.3alpha.tar.gz -C /opt/sgug

#-------------------------
FROM sgug as sgug_binutils

COPY ansible/roles/setup/files/make_binutils.sh /opt/sgug/make_binutils.sh
COPY ansible/roles/setup/files/patch_binutils.sh /opt/sgug/patch_binutils.sh
RUN chmod +x /opt/sgug/*.sh && \
    rpm -Uvh /opt/sgug/rpmbuild/SRPMS/binutils-2.23.2-24.sgugalpha.src.rpm && \
    tar xvzf /root/rpmbuild/SOURCES/binutils-2.23.2.tar.gz -C /root/rpmbuild/SOURCES && \
    /opt/sgug/patch_binutils.sh && \
    /opt/sgug/make_binutils.sh

#-------------------------
FROM  sgug_binutils as sgug_gcc

COPY ansible/roles/setup/files/patch_gcc.sh /opt/sgug/patch_gcc.sh
COPY ansible/roles/setup/files/build_gcc.sh /opt/sgug/build_gcc.sh
RUN chmod +x /opt/sgug/*.sh && \
    rpm -Uvh /opt/sgug/rpmbuild/SRPMS/gcc-9.2.0-1.sgugalpha.src.rpm && \
    tar xvzf /root/rpmbuild/SOURCES/gcc-9.2.0-20190812.tar.gz -C /root/rpmbuild/SOURCES && \
    /opt/sgug/patch_gcc.sh && \
    /opt/sgug/build_gcc.sh  

#-------------------------
#FROM base as sgug_distcc

FROM  sgug_gcc as sgug_distcc
# COPY --from=sgug_gcc /opt/sgug /opt/
# COPY --from=sgug_gcc /opt/irix-root /opt/

COPY files/entry.sh /opt/sgug/entry.sh
RUN chmod +x /opt/sgug/entry.sh && \
    update-distcc-symlinks
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/cc && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-addr2line /opt/sgug/mips-sgi-irix6.5/bin/addr2line && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++ /opt/sgug/mips-sgi-irix6.5/bin/c++ && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-c++filt /opt/sgug/mips-sgi-irix6.5/bin/c++filt && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-cpp /opt/sgug/mips-sgi-irix6.5/bin/cpp && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-elfedit /opt/sgug/mips-sgi-irix6.5/bin/elfedit && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-g++ /opt/sgug/mips-sgi-irix6.5/bin/g++ && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc /opt/sgug/mips-sgi-irix6.5/bin/gcc && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcc-9.2.0 /opt/sgug/mips-sgi-irix6.5/bin/gcc-9.2.0 && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov /opt/sgug/mips-sgi-irix6.5/bin/gcov && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-dump /opt/sgug/mips-sgi-irix6.5/bin/gcov-dump && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-gcov-tool /opt/sgug/mips-sgi-irix6.5/bin/gcov-tool && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-readelf /opt/sgug/mips-sgi-irix6.5/bin/readelf && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-size /opt/sgug/mips-sgi-irix6.5/bin/size && \
    # ln -s /opt/sgug/bin/mips-sgi-irix6.5-strings /opt/sgug/mips-sgi-irix6.5/bin/strings

EXPOSE \  
    8086/tcp \
    8186/tcp

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:8186/ || exit 1

ENTRYPOINT [ "/opt/sgug/entry.sh" ] 