#!/usr/bin/env bash
set -Eeuo pipefail

stage="host architecture"
cookie_tmp=""

fail() {
    printf 'LIMAP devcontainer preflight failed [%s]: %s\n' "$stage" "$1" >&2
    exit 1
}

cleanup() {
    if [[ -n "$cookie_tmp" && -e "$cookie_tmp" ]]; then
        rm -f "$cookie_tmp"
    fi
}
trap cleanup EXIT
trap 'fail "unexpected command failure; review the message above and retry."' ERR

[[ "$(uname -m)" == "x86_64" ]] || fail "native x86_64 Linux is required (found $(uname -m))."

stage="Docker client"
command -v docker >/dev/null 2>&1 || fail "Docker is not installed; install Docker Engine and add your user to the docker group."

stage="Docker daemon"
docker info >/dev/null 2>&1 || fail "cannot access the Docker daemon; start Docker and ensure 'docker info' works without sudo."

stage="NVIDIA Container Toolkit"
runtimes="$(docker info --format '{{json .Runtimes}}' 2>/dev/null)" || fail "could not inspect Docker runtimes."
[[ "$runtimes" == *nvidia* ]] || fail "the NVIDIA runtime is not configured; install NVIDIA Container Toolkit, run 'sudo nvidia-ctk runtime configure --runtime=docker', and restart Docker."

stage="display"
[[ -n "${DISPLAY:-}" ]] || fail "DISPLAY is empty; start this from an X11/XWayland desktop session and export DISPLAY."

stage="Xauthority tooling"
command -v xauth >/dev/null 2>&1 || fail "xauth is missing; install it on the host (for Ubuntu: sudo apt install xauth)."

stage="Xauthority cookie"
cookie="$(xauth nlist "$DISPLAY" 2>/dev/null)" || fail "could not read the Xauthority database; verify XAUTHORITY and your desktop session."
[[ -n "$cookie" ]] || fail "no Xauthority cookie exists for DISPLAY=$DISPLAY; verify XAUTHORITY or reconnect to the desktop session."

host_user="${USER:-$(id -un)}"
cookie_file="/tmp/limap-devcontainer-${host_user}.xauth"
cookie_tmp="$(mktemp "${cookie_file}.XXXXXX")"
printf '%s\n' "$cookie" | sed 's/^..../ffff/' | xauth -f "$cookie_tmp" nmerge -
chmod 600 "$cookie_tmp"
mv -f "$cookie_tmp" "$cookie_file"
cookie_tmp=""

printf 'LIMAP devcontainer preflight passed; Xauthority cookie: %s\n' "$cookie_file"
