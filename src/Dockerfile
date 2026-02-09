FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Системные зависимости + всё для сборки Cython (gcc/python-dev)
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-dev python-is-python3 \
      build-essential \
      git ca-certificates \
      libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Сначала зависимости (лучше для кеша)
COPY requirements.txt /workspace/requirements.txt

RUN python -m pip install --upgrade pip setuptools wheel && \
    # зависимости DenseTNT
    python -m pip install -r requirements.txt && \
    # PyTorch под CUDA 11.8
    python -m pip install --upgrade \
      torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 \
      --index-url https://download.pytorch.org/whl/cu118 && \
    # Argoverse 2 API (из инструкции репозитория)
    python -m pip install av2

# Теперь код
COPY . /workspace

# Сборка Cython расширения (из инструкции репозитория)
RUN cd src && \
    cython -a utils_cython.pyx && \
    python setup.py build_ext --inplace && \
    cd /workspace

CMD ["bash"]