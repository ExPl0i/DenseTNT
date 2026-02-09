FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Система + сборка расширений (Cython) + python3.8
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3.8 python3.8-dev python3.8-distutils python3-pip \
      build-essential \
      git ca-certificates \
      libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

ARG REPO_URL="https://github.com/ExPl0i/DenseTNT.git"
ARG REPO_BRANCH="argoverse2"

WORKDIR /workspace
RUN git clone --depth 1 --branch "${REPO_BRANCH}" "${REPO_URL}" /workspace/DenseTNT

WORKDIR /workspace/DenseTNT

RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install -r requirements.txt && \
    # PyTorch CUDA 11.8
    python -m pip install \
      torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 \
      --index-url https://download.pytorch.org/whl/cu118 && \
    # Argoverse2 API (как в README)
    python -m pip install av2

# Компиляция Cython (как в README)
RUN cd src && \
    cython -a utils_cython.pyx && \
    python setup.py build_ext --inplace

CMD ["bash"]