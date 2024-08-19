# This is a Dockerfile for realichaind.
FROM debian:bullseye as build-image

# Install required system packages
RUN apt-get update && apt-get install -y \
    automake \
    bsdmainutils \
    curl \
    g++ \
    libtool \
    make \
    pkg-config \
    patch 

# Build Realichain
COPY . /tmp/realichain/

WORKDIR /tmp/realichain

RUN cd depends && \
    NO_QT=true make HOST=$(uname -m)-linux-gnu -j$(nproc)

RUN ./autogen.sh && \
    ./configure --without-gui --enable-tests --prefix=/tmp/realichain/depends/$(uname -m)-linux-gnu && \
    make -j$(nproc) && \
    make check && \
    make install

# extract shared dependencies of realichaind and realichain-cli
# copy relevant binaries to /usr/bin, the COPY --from cannot use $(uname -m) variable in argument
RUN mkdir /tmp/ldd && \
    ./depends/ldd_copy.sh -b "./depends/$(uname -m)-linux-gnu/bin/realichaind" -t "/tmp/ldd" && \
    ./depends/ldd_copy.sh -b "./depends/$(uname -m)-linux-gnu/bin/realichain-cli" -t "/tmp/ldd" && \
    cp ./depends/$(uname -m)-linux-gnu/bin/* /usr/bin/

FROM debian:bullseye-slim

COPY --from=build-image /usr/bin/realichaind /usr/bin/realichaind
COPY --from=build-image /usr/bin/realichain-cli /usr/bin/realichain-cli
COPY --from=build-image /tmp/ldd /tmp/ldd

# restore ldd files in correct paths
RUN cp --verbose -RT /tmp/ldd / && \
    rm -rf /tmp/ldd && \
    ldd /usr/bin/realichaind

# Create user to run daemon
RUN useradd -m -U realichaind
USER realichaind

RUN mkdir /home/realichaind/.realichain
VOLUME [ "/home/realichaind/.realichain" ]

# Main network ports
EXPOSE 8200
EXPOSE 8201

# Test network ports
EXPOSE 18200
EXPOSE 18201

# Regression test network ports
EXPOSE 18444
EXPOSE 28201

ENTRYPOINT ["/usr/bin/realichaind", "-printtoconsole"]

