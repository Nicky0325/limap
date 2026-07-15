FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        git \
        libboost-filesystem-dev \
        libboost-graph-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libcgal-dev \
        libcgal-qt5-dev \
        libceres-dev \
        libeigen3-dev \
        libflann-dev \
        libfreeimage-dev \
        libglew-dev \
        libgl1-mesa-dri \
        libglx-mesa0 \
        libgoogle-glog-dev \
        libgflags-dev \
        libgmock-dev \
        libgtest-dev \
        libhdf5-dev \
        libmetis-dev \
        libqt5opengl5-dev \
        libsqlite3-dev \
        libunwind-dev \
        libx11-6 \
        libxext6 \
        libxrender1 \
        mesa-utils \
        ninja-build \
        python3.10-dev \
        python3.10-venv \
        qtbase5-dev \
        sudo \
        unzip \
        wget \
        x11-apps \
        xauth \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
RUN python3.10 -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

COPY requirements.txt /tmp/limap/requirements.txt
COPY .devcontainer/gpu-constraints.txt /tmp/limap/gpu-constraints.txt

RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install \
        torch==2.4.1 torchvision==0.19.1 \
        --index-url https://download.pytorch.org/whl/cu118 \
    && python -m pip install \
        --constraint /tmp/limap/gpu-constraints.txt \
        --requirement /tmp/limap/requirements.txt \
    && rm -rf /root/.cache/pip

RUN python -m pip install "scikit-build-core>=0.10" "pybind11>=2.11" \
    && rm -rf /root/.cache/pip

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}" \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" \
    && chown -R "${USERNAME}:${USERNAME}" "${VIRTUAL_ENV}" \
    && install -d -o "${USERNAME}" -g "${USERNAME}" /home/vscode/.cache \
    && install -d -o "${USERNAME}" -g "${USERNAME}" /home/vscode/.cache/ccache

ENV CCACHE_DIR=/home/vscode/.cache/ccache
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display
ENV QT_X11_NO_MITSHM=1

USER vscode
WORKDIR /workspaces/limap
