#!/bin/bash
set -euo pipefail

echo "[*] Cloning ngtcp2 repository with submodules..."
git clone --depth 1 --recurse-submodules https://github.com/ngtcp2/ngtcp2.git /usr/fuzz/src/ngtcp2

cd /usr/fuzz/src/ngtcp2

echo "[*] Generating build files with autoreconf..."
autoreconf -i

echo "[*] Configuring ngtcp2 with sanitizers and fuzzer instrumentation..."
./configure \
    CC=clang \
    CXX=clang++ \
    CFLAGS="-g -O1 -fsanitize=fuzzer-no-link,address,undefined" \
    CXXFLAGS="-g -O1 -fsanitize=fuzzer-no-link,address,undefined" \
    --disable-dependency-tracking \
    --enable-lib-only \
    --disable-shared \
    --enable-static

echo "[*] Compiling ngtcp2 static library..."
make -j"$(nproc)"

mkdir -p /usr/fuzz/bin
mkdir -p /usr/fuzz/corpus

echo "[*] Building fuzz targets..."
FUZZERS=(
    decode_frame
    ksl
    rob
    read_write_pkt
    read_write_handshake_pkt
)

for fuzzer in "${FUZZERS[@]}"; do
    if [ -f "fuzz/${fuzzer}.cc" ]; then
        echo "  -> Compiling ${fuzzer}..."
        clang++ -std=c++17 -g -O1 \
            -fsanitize=fuzzer,address,undefined \
            -Ilib/includes -Ilib -I. -DHAVE_CONFIG_H \
            fuzz/"${fuzzer}".cc -o /usr/fuzz/bin/"${fuzzer}" \
            lib/.libs/libngtcp2.a

        # Copy corpus if available
        if [ -d "fuzz/corpus/${fuzzer}" ]; then
            echo "  -> Setting up seed corpus for ${fuzzer}..."
            mkdir -p "/usr/fuzz/corpus/${fuzzer}"
            cp -r fuzz/corpus/"${fuzzer}"/* "/usr/fuzz/corpus/${fuzzer}/" 2>/dev/null || true
        fi
    fi
done

echo "[+] ngtcp2 fuzz targets successfully built!"
ls -la /usr/fuzz/bin/
