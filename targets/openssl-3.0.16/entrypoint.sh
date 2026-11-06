#!/bin/bash
set -e

BANNER="
======================================================
               LUZZ FUZZING CONTAINER                 
======================================================
Target:     ${TARGET_NAME:-openssl}
Language:   ${TARGET_LANG:-C}
Engine:     libFuzzer (Clang)
Sanitizers: AddressSanitizer (ASan), UndefinedBehaviorSanitizer (UBSan)
======================================================
"
echo "$BANNER"

# Available harnesses
HARNESSES=($(ls -1 /usr/fuzz/bin/ 2>/dev/null || true))
if [ ${#HARNESSES[@]} -eq 0 ]; then
    echo "[!] Error: No fuzz harnesses found in /usr/fuzz/bin!"
    exit 1
fi

echo "[+] Available harnesses (${#HARNESSES[@]}):"
for h in "${HARNESSES[@]}"; do
    echo "    * $h"
done
echo ""

# Parse first argument or env var
SELECTED_HARNESS=""
REMAINING_ARGS=()

if [ $# -gt 0 ]; then
    if [ -f "/usr/fuzz/bin/$1" ]; then
        SELECTED_HARNESS="$1"
        shift
        REMAINING_ARGS=("$@")
    else
        REMAINING_ARGS=("$@")
    fi
fi

if [ -z "$SELECTED_HARNESS" ]; then
    SELECTED_HARNESS="${FUZZ_TARGET:-${HARNESSES[0]}}"
fi

if [ ! -f "/usr/fuzz/bin/$SELECTED_HARNESS" ]; then
    echo "[!] Error: Selected harness '$SELECTED_HARNESS' does not exist."
    echo "[!] Available harnesses: ${HARNESSES[*]}"
    exit 1
fi

echo "[+] Active harness: $SELECTED_HARNESS"

# Setup corpus directory
CORPUS_DIR="${CORPUS_DIR:-/usr/fuzz/corpus/$SELECTED_HARNESS}"
mkdir -p "$CORPUS_DIR"
SEED_COUNT=$(find "$CORPUS_DIR" -type f | wc -l)
echo "[+] Active corpus directory: $CORPUS_DIR (seed inputs: $SEED_COUNT)"

# Setup artifact/crash directory
ARTIFACT_DIR="${ARTIFACT_DIR:-/usr/fuzz/artifacts}"
mkdir -p "$ARTIFACT_DIR"
echo "[+] Artifacts/Crashes directory: $ARTIFACT_DIR"

# Execution Knobs / Ручки
MAX_TIME="${MAX_TIME:-0}"
MAX_LEN="${MAX_LEN:-4096}"
TIMEOUT="${TIMEOUT:-25}"
RUNS="${RUNS:-}"

echo ""
echo "[+] Execution Knobs / Ручки:"
echo "    - Max total time: ${MAX_TIME}s (0 = infinite / manual stop)"
echo "    - Max input length: ${MAX_LEN} bytes"
echo "    - Per-input timeout: ${TIMEOUT}s"
[ -n "$RUNS" ] && echo "    - Max runs: $RUNS"
[ ${#REMAINING_ARGS[@]} -gt 0 ] && echo "    - Extra CLI flags: ${REMAINING_ARGS[*]}"
echo "======================================================"
echo "[*] Launching libFuzzer on '$SELECTED_HARNESS'..."
echo ""

FUZZ_ARGS=(
    "-artifact_prefix=$ARTIFACT_DIR/"
    "-max_len=$MAX_LEN"
    "-timeout=$TIMEOUT"
)

if [ "$MAX_TIME" -gt 0 ]; then
    FUZZ_ARGS+=("-max_total_time=$MAX_TIME")
fi

if [ -n "$RUNS" ]; then
    FUZZ_ARGS+=("-runs=$RUNS")
fi

# Run the fuzzer
set +e
/usr/fuzz/bin/"$SELECTED_HARNESS" "${FUZZ_ARGS[@]}" "$CORPUS_DIR" "${REMAINING_ARGS[@]}"
EXIT_CODE=$?
set -e

echo ""
echo "======================================================"
echo "[*] Fuzzing session ended with code: $EXIT_CODE"
CRASHES=($(find "$ARTIFACT_DIR" -type f 2>/dev/null || true))
echo "[*] Crash artifacts found: ${#CRASHES[@]}"
if [ ${#CRASHES[@]} -gt 0 ]; then
    echo "[!] Detected crash files:"
    for c in "${CRASHES[@]}"; do
        echo "    - $c"
    done
fi
echo "======================================================"
exit $EXIT_CODE
