#!/bin/bash
set -uxo pipefail

# $1: name of the executable (e.g. edax_runner.exe)
# $2: pattern of the libedax libraries of the OS (e.g. "libedax-x64*.dll").
#     libedax is built for several levels of CPU, and edax_runner chooses the fastest one.

dst="build"
edax_runner_bin_name=$1
libedax_shared_library_pattern=$2

rm -rf "$dst"
mkdir -p "$dst/data"

dart compile exe bin/edax_runner.dart -o "$dst/$edax_runner_bin_name"
chmod +x "$dst/$edax_runner_bin_name"

# shellcheck disable=SC2086
cp resources/dll/$libedax_shared_library_pattern "$dst/"
cp resources/data/*.dat "$dst/data"
cp resources/config.ini "$dst/config.ini"
cp resources/learning_list.txt "$dst/learning_list.txt"
