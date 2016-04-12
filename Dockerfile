FROM phusion/baseimage:0.9.17

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
  apt-get update && \
  apt-get install -y \
    autoconf \
    automake \
    libtool \
    make \
    gcc-4.9 \
    g++-4.9 \
    libboost1.54-dev \
    libboost-program-options1.54-dev \
    libboost-filesystem1.54-dev \
    libboost-system1.54-dev \
    libboost-thread1.54-dev \
    libboost-date-time1.54-dev \
    protobuf-compiler \
    libprotobuf-dev \
    lua5.2 \
    liblua5.2-dev \
    git \
    libsqlite3-dev \
    libspatialite-dev \
    libgeos-dev \
    libgeos++-dev \
    libcurl4-openssl-dev \
    wget \
    unzip && \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 90 && \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 90 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /valhalla
WORKDIR /valhalla

RUN git clone https://github.com/zeromq/libzmq.git && \
  cd libzmq && \
  git checkout 32f2b784b9874cd3670d5a406af41c3e554dcd24 && \
  ./autogen.sh && \
  ./configure --without-libsodium && \
  make -j4 && \
  make install && \
  cd ..

RUN git clone --recurse-submodules https://github.com/kevinkreiser/prime_server.git && \
  cd prime_server && \
  git checkout 9564abc58f13740cfefa73d98bf86138833a7777 && \
  ./autogen.sh && \
  ./configure && \
  make -j4 && \
  make install && \
  cd ..

ADD midgard midgard
RUN cd midgard && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD baldr baldr
RUN cd baldr && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD sif sif
RUN cd sif && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD skadi skadi
RUN cd skadi && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD mjolnir mjolnir
RUN cd mjolnir && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD loki loki
RUN cd loki && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD odin odin
RUN cd odin && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD thor thor
RUN cd thor && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD tyr tyr
RUN cd tyr && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

ADD tools tools
RUN cd tools && ./autogen.sh && ./configure CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE && make -j4 && make install && cd ..

RUN ldconfig

RUN mkdir -p /data/valhalla
ADD conf conf

RUN rm -rf /tmp/* /var/tmp/*

ENV TERM xterm
EXPOSE 8002
CMD ["tools/tyr_simple_service", "conf/valhalla.json"]
