#!/usr/bin/env bash
set -Eeuo pipefail

stage="repository discovery"
fail() {
    printf 'LIMAP devcontainer setup failed [%s]: %s\n' "$stage" "$1" >&2
    exit 1
}
trap 'fail "command failed; fix the reported error and rerun .devcontainer/post-create.sh."' ERR

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

stage="Git submodules"
git submodule update --init --recursive

stage="compiler cache configuration"
detected_jobs="$(nproc)"
if (( detected_jobs > 8 )); then
    detected_jobs=8
fi
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-$detected_jobs}"
export MAX_JOBS="${MAX_JOBS:-$CMAKE_BUILD_PARALLEL_LEVEL}"
export CCACHE_DIR="${CCACHE_DIR:-/home/vscode/.cache/ccache}"
export CCACHE_BASEDIR="$repo_root"
export CCACHE_COMPILERCHECK=content
export CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
mkdir -p "$CCACHE_DIR"
ccache --max-size "${CCACHE_MAXSIZE:-10G}"

stage="editable LIMAP build"
python -m pip install --no-deps --no-build-isolation -ve . \
    -Cbuild-dir=build/devcontainer

printf 'LIMAP devcontainer setup complete (build directory: %s/build/devcontainer).\n' "$repo_root"
