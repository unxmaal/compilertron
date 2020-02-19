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
FROM sgug_gcc as sgug_distcc

COPY files/entry.sh /opt/sgug/entry.sh
RUN chmod +x /opt/sgug/entry.sh

EXPOSE \  
    8088/tcp \
    8188/tcp

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:8188/ || exit 1

ENTRYPOINT [ "/opt/sgug/entry.sh" ] 