#!/usr/bin/env bash
set -euo pipefail

source_root=$(cd "$1" && pwd)
out=$2
mkdir -p "$out"
out=$(cd "$out" && pwd)
commit=4d16210cc91bb99fddaa372dceef8e2ca8990bfc
test "$(git -C "$source_root" rev-parse HEAD)" = "$commit"

flags=$(grep -m1 '^flags' /proc/cpuinfo)
printf '%s\n' "$flags" > "$out/cpu.txt"
for flag in avx2 bmi1 bmi2 f16c fma abm movbe avx512f avx512bw avx512cd avx512dq avx512vl; do
    grep -qw "$flag" <<< "$flags" || { echo "PGO runner lacks $flag" >&2; exit 1; }
done

{
    printf 'source %s\nrun %s\n' "$commit" "${GITHUB_RUN_ID:-local}"
    gcc --version
    getconf GNU_LIBC_VERSION
} > "$out/build-info.txt"

work=$(mktemp -d)
stage=$work/engine
mkdir -p "$stage"
git -C "$source_root" archive "$commit" | tar -x -C "$stage"
printf '%s  %s\n' f8b2299612d9fa4414157e70e932636e33111c2602d0c2fc382a7d90ef21b792 "$stage/bin/data/eval.dat" | sha256sum -c

run_logged() {
    local log=$1
    shift
    printf '%q ' "$@" > "$log"
    printf '\n' >> "$log"
    "$@" >> "$log" 2>&1 || { tail -100 "$log"; return 1; }
}

for arch in x86-64 x86-64-v3 x86-64-v4; do
    engine=libedax-$arch.so
    suffix=${arch#x86-64}
    packaged=libedax$suffix.so
    evidence=$out/$arch
    mkdir -p "$evidence" "$work/train-$arch/data" "$work/test-$arch/data"
    cp "$stage/bin/data/eval.dat" "$work/train-$arch/data/"
    cp "$stage/bin/data/eval.dat" "$work/test-$arch/data/"
    common=(-C "$stage/src" libbuild "ARCH=$arch" COMP=gcc OS=linux)
    run_logged "$evidence/unprofiled.txt" make "${common[@]}"
    nm -D --defined-only "$stage/bin/$engine" | awk '{print $(NF - 1), $NF}' | sort > "$evidence/unprofiled.abi"

    run_logged "$evidence/instrument.txt" make "${common[@]}" 'CC=gcc -fprofile-generate -fprofile-update=atomic'
    instrumented=$(sha256sum "$stage/bin/$engine" | cut -d' ' -f1)
    printf '%s  %s\n' "$instrumented" "$engine" > "$evidence/instrumented.sha256"

    gcc -O1 -D_GNU_SOURCE "$stage/tests/libedax_test.c" -L"$stage/bin" "-l:$engine" -Wl,-rpath,'$ORIGIN' -ldl -o "$work/train-$arch/api"
    cp "$stage/bin/$engine" "$work/train-$arch/"
    (
        cd "$work/train-$arch"
        run_logged "$evidence/training-api.txt" env LD_LIBRARY_PATH="$PWD" ./api "./$engine"
        grep -Eq '^[1-9][0-9]* checks, 0 failures$' "$evidence/training-api.txt"
        run_logged "$evidence/training-search.txt" env LD_LIBRARY_PATH="$PWD" ./api "./$engine" bench 19 1
        grep -Eq '^bench: 19 positions, [1-9][0-9]* nodes,' "$evidence/training-search.txt"
    )

    # Both stages pass the same output path to GCC, so it finds the GCDA for this shared library.
    shopt -s nullglob
    profiles=("$stage/bin/$engine"-*.gcda "$stage/bin/${engine%.so}"-*.gcda)
    test "${#profiles[@]}" -gt 0
    for profile in "${profiles[@]}"; do test -s "$profile"; done
    sha256sum "${profiles[@]}" > "$evidence/profiles.sha256"
    gcov-dump -l "${profiles[0]}" > "$evidence/profile-counts.txt"
    grep -Eq 'runs=[1-9][0-9]*' "$evidence/profile-counts.txt"

    run_logged "$evidence/final-link.txt" make "${common[@]}"         'CC=gcc -fprofile-use -fprofile-correction -Werror=missing-profile -Werror=coverage-mismatch'
    test "$(sha256sum "$stage/bin/$engine" | cut -d' ' -f1)" != "$instrumented"
    nm -D --defined-only "$stage/bin/$engine" | awk '{print $(NF - 1), $NF}' | sort > "$evidence/pgo.abi"
    diff -u "$evidence/unprofiled.abi" "$evidence/pgo.abi"
    nm -D "$stage/bin/$engine" > "$evidence/dynamic-symbols.txt"
    if grep -q '__gcov' "$evidence/dynamic-symbols.txt"; then
        echo "$packaged still contains gcov symbols" >&2
        exit 1
    fi

    gcc -O1 -D_GNU_SOURCE "$stage/tests/libedax_test.c" -L"$stage/bin" "-l:$engine" -Wl,-rpath,'$ORIGIN' -ldl -o "$work/test-$arch/api"
    cp "$stage/bin/$engine" "$work/test-$arch/"
    (
        cd "$work/test-$arch"
        run_logged "$evidence/final-api.txt" env LD_LIBRARY_PATH="$PWD" ./api "./$engine"
        grep -Eq '^[1-9][0-9]* checks, 0 failures$' "$evidence/final-api.txt"
        run_logged "$evidence/final-search.txt" env LD_LIBRARY_PATH="$PWD" ./api "./$engine" bench 19 1
        grep -Eq '^bench: 19 positions, [1-9][0-9]* nodes,' "$evidence/final-search.txt"
        diff -u <(grep '^bench:' "$evidence/training-search.txt" | cut -d, -f1-2)             <(grep '^bench:' "$evidence/final-search.txt" | cut -d, -f1-2)
    )

    cp "$stage/bin/$engine" "$out/$packaged"
    readelf --file-header --dynamic --version-info "$out/$packaged" > "$evidence/elf.txt"
    grep -q 'Advanced Micro Devices X86-64' "$evidence/elf.txt"
    grep -Eq 'Type:.*DYN' "$evidence/elf.txt"
    glibc=$(grep -o 'GLIBC_[0-9.]*' "$evidence/elf.txt" | sort -uV | tail -1)
    test -n "$glibc"
    test "$(printf '%s\n' "$glibc" GLIBC_2.35 | sort -V | tail -1)" = GLIBC_2.35
    printf '%s requires up to %s\n' "$packaged" "$glibc" | tee "$evidence/glibc.txt"
    python3 "$stage/tests/check-build-paths.py" "$out/$packaged" > "$evidence/build-paths.txt"
done

(
    cd "$out"
    sha256sum libedax.so libedax-v3.so libedax-v4.so > SHA256SUMS.txt
    tar -czf linux-libedax-pgo.tar.gz libedax.so libedax-v3.so libedax-v4.so SHA256SUMS.txt
    sha256sum linux-libedax-pgo.tar.gz > ARCHIVE-SHA256.txt
)
