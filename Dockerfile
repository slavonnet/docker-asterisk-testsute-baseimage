FROM gcc

MAINTAINER Badalyan Vyacheslav <v.badalyan@open-bs.ru>

ARG libsrtp_tag=v1.5.3
ARG pjproject_branch=master
ARG testsute_branch=master
ARG sipp_branch=master

RUN apt-get update -y && apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
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
	libgtk2.0-dev \
	libh323plus-dev \
	libical-dev \
	libiksemel-dev \
	libjack-dev \
	libjansson-dev \
	libldap-dev \
	liblua5.2-dev \
	libmysqlclient-dev \
	libmysqlclient15-dev \
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
	libsqlite0-dev \
	libsqlite3-dev \
	libsrtp-dev \
	libssl-dev \
	libusb-dev \
	libvorbis-dev \
	libvpb-dev \
	libxml2-dev \
	libxslt1-dev \
	libz-dev \
	lua5.2 \
	portaudio19-dev \
	python-dev \
	python-setuptools \
	python-twisted \
	python-yaml \
	subversion \
	unixodbc-dev \
	uuid \
	uuid-dev 

### LIBSRTP 1.5+

RUN git clone https://github.com/cisco/libsrtp.git /usr/src/libsrtp
WORKDIR /usr/src/libsrtp
RUN git checkout tags/${libsrtp_tag} -B ${libsrtp_tag}
RUN ./configure --enable-openssl --prefix=/usr
RUN make -j"$(nproc)" && make libsrtp.so.1 && make install && ldconfig


### PJSIP MASTER

RUN git clone https://github.com/asterisk/pjproject /usr/src/pjproject
WORKDIR /usr/src/pjproject
RUN git checkout -B ${pjproject_branch}
RUN  ./configure --enable-shared --with-external-srtp --prefix=/usr
RUN echo CFLAGS+=-g > user.mak
RUN cp pjlib/include/pj/config_site_sample.h pjlib/include/pj/config_site.h
RUN echo "#define PJ_HAS_IPV6 1" >> pjlib/include/pj/config_site.h 
RUN make  -j"$(nproc)" dep && make  -j"$(nproc)" && make install
RUN cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/sbin/pjsua
RUN make -C pjsip-apps/src/python install && ldconfig


### ASTERISK TEST SUTE

RUN git clone https://gerrit.asterisk.org/testsuite /usr/src/testsute
WORKDIR /usr/src/testsute/asttest
RUN git checkout -B ${testsute_branch}
RUN make  -j"$(nproc)" && make install
WORKDIR /usr/src/testsute/addons
RUN make update
WORKDIR starpy
RUN python setup.py install


### SIP-P

RUN git clone https://github.com/SIPp/sipp.git /usr/src/sipp
WORKDIR /usr/src/sipp
RUN ./build.sh --full && make installl

### ASTERISK INSTALL
WORKDIR /usr/src/asterisk
RUN git checkout -B ${sipp_branch}
RUN ./configure  --prefix=/usr --enable-dev-mode
RUN make menuselect.makeopts
RUN menuselect/menuselect --enable ADDRESS_SANITIZER --enable-category MENUSELECT_TESTS --enable DONT_OPTIMIZE --enable TEST_FRAMEWORK menuselect.makeopts
RUN make -j"$(nproc)" make install && make config && make samples


#CLEANUP for size!
RUN apt-get clean all
RUN rm -rf /usr/src/pjproject /usr/src/sipp /usr/src/libsrtp

### RUN TEST!!

#WORKDIR /usr/src/testsute
#ENTRYPOINT ./runtests.py -l
#CMD ["-c"]



