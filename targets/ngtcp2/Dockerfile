FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/fuzz

RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    llvm \
    libclang-rt-dev \
    git \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/fuzz/bin /usr/fuzz/corpus /usr/fuzz/artifacts /usr/fuzz/src

COPY build.sh /usr/fuzz/build.sh
COPY entrypoint.sh /usr/fuzz/entrypoint.sh

RUN chmod +x /usr/fuzz/build.sh /usr/fuzz/entrypoint.sh \
    && /usr/fuzz/build.sh \
    && rm -rf /usr/fuzz/build.sh /usr/fuzz/src

ENV TARGET_NAME=ngtcp2
ENV TARGET_LANG=C

ENTRYPOINT ["/usr/fuzz/entrypoint.sh"]
