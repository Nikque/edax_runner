#!/bin/bash
set -euo pipefail
abi=$1
target=$2
source_id=4d16210cc91bb99fddaa372dceef8e2ca8990bfc
weights_sha=f8b2299612d9fa4414157e70e932636e33111c2602d0c2fc382a7d90ef21b792
root=$PWD
test "$(uname -m)" = "$abi"
test "$(git -C edax rev-parse HEAD)" = "$source_id"
printf '%s  %s\n' "$weights_sha" edax/bin/data/eval.dat | shasum -a 256 -c
mkdir -p dist/evidence
logs=$root/dist/evidence
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
for dir in instrumented profile-ffi profile-api final-check; do
    mkdir -p "$tmp/$dir/data"
    cp edax/bin/data/eval.dat "$tmp/$dir/data/"
done
run() {
    local log=$1
    shift
    if ! "$@" > "$logs/$log" 2>&1; then
        cat "$logs/$log"
        exit 1
    fi
}
build_lib() {
    local output=$1 flags=$2
    run "$output-build.log" make -C edax/src -B libbuild ARCH="$target" COMP=clang OS=osx CC="clang -arch $abi $flags"
    cp "edax/bin/libedax-$target.dylib" "$tmp/$output/libedax.universal.dylib"
    test "$(lipo -archs "$tmp/$output/libedax.universal.dylib")" = "$abi"
}
build_test() {
    local stage=$1
    clang -arch "$abi" -O1 edax/tests/libedax_test.c "$tmp/$stage/libedax.universal.dylib" \
        -Wl,-rpath,@loader_path -o "$tmp/$stage/api-test"
}
build_lib instrumented '-fprofile-instr-generate'
build_test instrumented
clang -arch "$abi" -O2 -I edax/src .github/scripts/mac_libedax_train.c "$tmp/instrumented/libedax.universal.dylib" \
    -Wl,-rpath,@loader_path -o "$tmp/instrumented/ffi-train"
for stage in profile-ffi profile-api; do
    cp "$tmp/instrumented/"{libedax.universal.dylib,api-test,ffi-train} "$tmp/$stage/"
done
(cd "$tmp/profile-ffi" && run training-ffi.log env LLVM_PROFILE_FILE="$tmp/ffi-%m.profraw" ./ffi-train)
(cd "$tmp/profile-api" && run training-api.log env LLVM_PROFILE_FILE="$tmp/api-%m.profraw" ./api-test ./libedax.universal.dylib)
grep -E '^[1-9][0-9]* checks, 0 failures' "$logs/training-api.log"
test "$(find "$tmp" -maxdepth 1 -name '*.profraw' -size +0c | wc -l | tr -d ' ')" = 2
xcrun llvm-profdata merge "$tmp/"*.profraw -o "$tmp/edax.profdata"
xcrun llvm-profdata show --counts "$tmp/edax.profdata" | tee "$logs/profile.txt"
grep -Eq '^Maximum function count: [1-9][0-9]*$' "$logs/profile.txt"
xcrun llvm-profdata show --counts --all-functions "$tmp/edax.profdata" > "$tmp/functions.txt"
grep -Eq 'edax_go:|play_go:' "$tmp/functions.txt"
build_lib final-check "-fprofile-instr-use=$tmp/edax.profdata -Werror=profile-instr-out-of-date -Werror=profile-instr-unprofiled"
build_test final-check
(cd "$tmp/final-check" && run final-api.log ./api-test ./libedax.universal.dylib)
grep -E '^[1-9][0-9]* checks, 0 failures' "$logs/final-api.log"
lib="$tmp/final-check/libedax.universal.dylib"
otool -D "$lib" | tee "$logs/install-name.txt"
grep -Fx '@rpath/libedax.universal.dylib' "$logs/install-name.txt"
otool -L "$lib" > "$logs/dependencies.txt"
if otool -l "$lib" | grep '__llvm_prf' > /dev/null; then echo "Profile counters found in final library" >&2; exit 1; fi
python3 edax/tests/check-build-paths.py "$lib" | tee "$logs/build-paths.txt"
{
    printf 'Source: %s\nArchitecture: %s\nRun: %s\n' "$source_id" "$abi" "$GITHUB_RUN_ID"
    clang --version
    shasum -a 256 "$tmp/edax.profdata"
} > "$logs/build-id.txt"
cp "$lib" dist/libedax.universal.dylib
(cd dist && shasum -a 256 libedax.universal.dylib | tee SHA256SUMS)
