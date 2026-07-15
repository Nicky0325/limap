#!/usr/bin/env bash
set -Eeuo pipefail

stage="NVIDIA driver visibility"
fail() {
    printf 'LIMAP devcontainer smoke test failed [%s]: %s\n' "$stage" "$1" >&2
    exit 1
}
trap 'fail "command failed; inspect the preceding output for details."' ERR

nvidia-smi

stage="Python imports and CUDA execution"
python - <<'PY'
import limap
import open3d
import pycolmap
import torch

if not torch.cuda.is_available():
    raise RuntimeError(
        "torch.cuda.is_available() is false; verify --gpus=all, the host driver, "
        "and NVIDIA Container Toolkit"
    )

value = (torch.arange(6, device="cuda", dtype=torch.float32) ** 2).sum().item()
if value != 55.0:
    raise RuntimeError(f"unexpected CUDA tensor result: {value}")

print(f"LIMAP: {limap.__version__}")
print(f"PyTorch: {torch.__version__}")
print(f"PyTorch CUDA runtime: {torch.version.cuda}")
print(f"GPU: {torch.cuda.get_device_name(0)}")
print(f"pycolmap: {pycolmap.__version__}")
print(f"Open3D: {open3d.__version__}")
print(f"CUDA tensor smoke result: {value}")
PY

printf 'LIMAP devcontainer smoke test passed.\n'
