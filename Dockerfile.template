FROM gcc

MAINTAINER Badalyan Vyacheslav <v.badalyan@open-bs.ru>

ENV libsrtp_tag=v1.5.4
ENV pjproject_branch=tags/2.4.5
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
		python-autobahn \
		python-requests \
		python-dev \
		python-setuptools \
		python-twisted \
		python-yaml \
		subversion \
		unixodbc-dev \
		uuid \
		xmlstarlet \
		svn \
		uuid-dev && \
	apt-get clean all

ENV proc=32

### SIP-P

RUN git clone -b ${sipp_branch} --depth 1 https://github.com/SIPp/sipp.git /usr/src/sipp && \
	cd /usr/src/sipp && \
	./build.sh --full && make install && \
	rm -rf /usr/src/sipp

### LIBSRTP 

ONBUILD RUN git clone -b tags/${libsrtp_tag} --depth 1 https://github.com/cisco/libsrtp.git /usr/src/libsrtp && \
	cd /usr/src/libsrtp && \
	./configure --enable-openssl --prefix=/usr && \
	make -j${proc} && make libsrtp.so.1 && make install && ldconfig && \
	rm -rf /usr/src/libsrtp

### PJPROJECT

ONBUILD RUN svn co http://svn.pjsip.org/repos/pjproject/${pjproject_branch} /usr/src/pjproject && \
	cd /usr/src/pjproject && \
	./configure --enable-shared --with-external-srtp --prefix=/usr && \
	echo CFLAGS+=-g > user.mak && \
	cp pjlib/include/pj/config_site_sample.h pjlib/include/pj/config_site.h && \
	echo "#define PJ_HAS_IPV6 1" >> pjlib/include/pj/config_site.h && \
	make -j${proc} dep && make -j${proc} && make install && \
	cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/sbin/pjsua && \
	make -C pjsip-apps/src/python install && ldconfig && \
	rm -rf /usr/src/pjproject

### ASTERISK TEST SUTE

ONBUILD  RUN git clone -b ${testsute_branch} --depth 1 https://gerrit.asterisk.org/testsuite /usr/src/testsute && \
	cd /usr/src/testsute/asttest && \
	make && make install && \
	cd /usr/src/testsute/addons && \
	make update && \
	cd starpy && \
	python setup.py install


