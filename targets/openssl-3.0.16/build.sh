#!/bin/bash
set -euo pipefail

echo "[*] Downloading OpenSSL 3.0.16..."
wget -q -t 5 https://github.com/openssl/openssl/releases/download/openssl-3.0.16/openssl-3.0.16.tar.gz -O /tmp/openssl.tar.gz
tar -xzf /tmp/openssl.tar.gz -C /usr/fuzz/src/
rm -f /tmp/openssl.tar.gz

cd /usr/fuzz/src/openssl-3.0.16

PATH_TO_LIBFUZZER=$(find /usr/lib/llvm-* -name libclang_rt.fuzzer-x86_64.a | head -n 1)
if [ -z "$PATH_TO_LIBFUZZER" ]; then
    echo "[!] Error: libclang_rt.fuzzer-x86_64.a not found!"
    exit 1
fi
echo "[+] Found libFuzzer library: $PATH_TO_LIBFUZZER"

echo "[*] Configuring OpenSSL for libFuzzer and sanitizers (ASan + UBSan)..."
CC=clang ./config enable-fuzz-libfuzzer \
    --with-fuzzer-lib="$PATH_TO_LIBFUZZER" \
    -DPEDANTIC enable-asan enable-ubsan no-shared \
    -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION \
    -fsanitize=fuzzer-no-link \
    -fno-sanitize=alignment,function \
    enable-weak-ssl-ciphers enable-rc5 enable-md2 \
    no-tests --debug

echo "[*] Compiling OpenSSL fuzz targets..."
LDCMD=clang++ make -j"$(nproc)"

mkdir -p /usr/fuzz/bin
mkdir -p /usr/fuzz/corpus

FUZZERS=(
    asn1
    asn1parse
    bignum
    bndiv
    client
    cmp
    cms
    conf
    crl
    ct
    server
    x509
)

for fuzzer in "${FUZZERS[@]}"; do
    if [ -f "fuzz/${fuzzer}" ]; then
        echo "  -> Installing fuzzer binary ${fuzzer}..."
        cp "fuzz/${fuzzer}" /usr/fuzz/bin/"${fuzzer}"

        mkdir -p "/usr/fuzz/corpus/${fuzzer}"
        # Copy seed corpus if available
        if [ -d "fuzz/corpora/${fuzzer}" ] && [ -n "$(ls -A fuzz/corpora/${fuzzer} 2>/dev/null)" ]; then
            echo "  -> Copying seed corpus for ${fuzzer}..."
            cp -r fuzz/corpora/"${fuzzer}"/* "/usr/fuzz/corpus/${fuzzer}/" 2>/dev/null || true
        else
            # Provide initial seed input
            echo -ne "\x30\x00" > "/usr/fuzz/corpus/${fuzzer}/seed_0.bin"
        fi
    fi
done

echo "[+] OpenSSL fuzz targets successfully built!"
ls -la /usr/fuzz/bin/
