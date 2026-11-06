FROM debian:trixie-slim

WORKDIR /usr/fuzz

RUN apt-get update && apt-get install -y \
    build-essential clang llvm libclang-rt-dev git ca-certificates \
    autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --recurse-submodules https://github.com/ngtcp2/nghttp3.git

WORKDIR /usr/fuzz/nghttp3

RUN autoreconf -i \
    && ./configure CC=clang CXX=clang++ \
       CFLAGS="-g -O1 -fsanitize=fuzzer-no-link,address,undefined" \
       CXXFLAGS="-g -O1 -fsanitize=fuzzer-no-link,address,undefined" \
       --disable-dependency-tracking --enable-lib-only --disable-shared --enable-static \
    && make -j$(nproc) \
    && clang++ -std=c++23 -g -O1 -fsanitize=fuzzer,address,undefined \
       -Ilib/includes -Ilib -I. -DHAVE_CONFIG_H \
       fuzz/fuzz_http3serverreq.cc -o /usr/fuzz/fuzz_http3serverreq lib/.libs/libnghttp3.a \
    && clang++ -std=c++23 -g -O1 -fsanitize=fuzzer,address,undefined \
       -Ilib/includes -Ilib -I. -DHAVE_CONFIG_H \
       fuzz/fuzz_qpackdecoder.cc -o /usr/fuzz/fuzz_qpackdecoder lib/.libs/libnghttp3.a

WORKDIR /usr/fuzz

CMD ["./fuzz_http3serverreq", "nghttp3/fuzz/corpus/fuzz_http3serverreq"]
