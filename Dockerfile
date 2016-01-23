FROM gcc

MAINTAINER Badalyan Vyacheslav <v.badalyan@open-bs.ru>

ENV libsrtp_tag=v1.5.3
ENV pjproject_branch=master
ENV testsute_branch=master
ENV sipp_branch=master

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update -y --force-yes && apt-get dist-upgrade -y --force-yes && \
	apt-get install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
		autoconf \
		binutils-dev \
		build-essential \
		doxygen \
		freetds-dev \
		git \
		libasound2-dev \
		libbluetooth-dev \
		libc-client-dev \
		libcorosync-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libfreeradius-client-dev \
		libfreeradius-dev \
		libgmime-2.6-dev \
		libgsl0-dev \
		libgsm1-dev \
		libical-dev \
		libiksemel-dev \
		libjack-dev \
		libjansson-dev \
		libldap-dev \
		liblua5.1-dev \
		liblua5.2-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libneon27-dev \
		libnewt-dev \
		libogg-dev \
		libpcap-dev \
		libpopt-dev \
		libpq-dev \
		libresample-dev \
		libsctp-dev \
		libsnmp-dev \
		libspandsp-dev \
		libspeex-dev \
		libspeexdsp-dev \
		libsqlite3-dev \
		libssl-dev \
		libusb-dev \
		libvorbis-dev \
		libvpb-dev \
		libxml2-dev \
		libxslt1-dev \
		libz-dev \
		lua5.2 \
		lua5.1 \
		python-dev \
		python-setuptools \
		python-twisted \
		python-yaml \
		subversion \
		unixodbc-dev \
		uuid \
		uuid-dev && \
	apt-get clean all

ENV NPROC 32

### LIBSRTP 1.5+

ONBUILD RUN git clone https://github.com/cisco/libsrtp.git /usr/src/libsrtp && \
	cd /usr/src/libsrtp && \
	git checkout tags/${libsrtp_tag} -B ${libsrtp_tag} && \
	./configure --enable-openssl --prefix=/usr && \
	make -j"$(NPROC)" && make libsrtp.so.1 && make install && ldconfig && \
	rm -rf /usr/src/libsrtp

### PJSIP MASTER

ONBUILD RUN git clone https://github.com/asterisk/pjproject /usr/src/pjproject && \
	cd /usr/src/pjproject && \
	git checkout -B ${pjproject_branch} && \
	./configure --enable-shared --with-external-srtp --prefix=/usr && \
	echo CFLAGS+=-g > user.mak && \
	cp pjlib/include/pj/config_site_sample.h pjlib/include/pj/config_site.h && \
	echo "#define PJ_HAS_IPV6 1" >> pjlib/include/pj/config_site.h && \
	make  -j"$(NPROC)" dep && make  -j"$(nproc)" && make install && \
	cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/sbin/pjsua && \
	make -C pjsip-apps/src/python install && ldconfig && \
	rm -rf /usr/src/pjproject

### ASTERISK TEST SUTE

ONBUILD  RUN git clone https://gerrit.asterisk.org/testsuite /usr/src/testsute && \
	cd /usr/src/testsute/asttest && \
	git checkout -B ${testsute_branch} && \
	make  -j"$(NPROC)" && make install && \
	cd /usr/src/testsute/addons && \
	make update && \
	cd starpy && \
	python setup.py install

### SIP-P

ONBUILD  RUN git clone https://github.com/SIPp/sipp.git /usr/src/sipp && \
	cd /usr/src/sipp && \
	./build.sh --full && make install && \
	rm -rf /usr/src/sipp


