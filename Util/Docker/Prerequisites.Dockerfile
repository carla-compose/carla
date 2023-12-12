FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

ARG EPIC_USER
ARG EPIC_PASS
ENV DEBIAN_FRONTEND=noninteractive

RUN echo $EPIC_USER
RUN echo $EPIC_PASS

# Setup
USER root

# Install GnuPG2 and import key
RUN apt-get update && apt-get install -y gnupg2
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A4B469963BF863CC

# Update apt-get
RUN apt-get update ; \
  apt-get install -y wget software-properties-common && \
  add-apt-repository ppa:ubuntu-toolchain-r/test && \
  add-apt-repository ppa:deadsnakes/ppa

# Install Dependencies
RUN apt-get update ; \
  apt-get install -y build-essential \
    xdg-user-dirs \
    sudo \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libfontconfig1 \
    libfreetype6 \
    libglu1 \
    libglvnd-dev \
    libnss3 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libsm6 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libxv1 \
    x11-xkb-utils \
    xauth \
    xfonts-base \
    xkb-data \
    clang-8 \
    lld-8 \
    g++-7 \
    cmake \
    ninja-build \
    libvulkan1 \
    libvulkan-dev \
    vulkan-tools \
    python \
    python3.8 \
    python3.10 \
    python-dev \
    python3.8-dev \
    python3.10-dev \
    python3.8-distutils \
    python3.10-distutils \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    tzdata \
    sed \
    curl \
    unzip \
    autoconf \
    libtool \
    rsync \
    libxml2-dev \
    git \
    nano \
    aria2

# Install pip for python 3.8 and 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.8 get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Install Python Packages
RUN pip3.8 install -Iv setuptools==47.3.1 && \
  pip3.8 install distro && \
  pip3.8 install pygame && \
  pip3.8 install numpy

RUN pip3.10 install -Iv setuptools==47.3.1 && \
  pip3.10 install distro && \
  pip3.10 install pygame && \
  pip3.10 install numpy

# Set Alternatives and Defaults
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
  update-alternatives --set python3 /usr/bin/python3.10 && \
  update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 && \
  update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

# Enable Vulkan support for NVIDIA GPUs
RUN apt-get update && apt-get install -y --no-install-recommends libvulkan1 && \
      rm -rf /var/lib/apt/lists/* && \
      VULKAN_API_VERSION=`dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9|\.]+'` && \
      mkdir -p /etc/vulkan/icd.d/ && \
      echo \
      "{\
        \"file_format_version\" : \"1.0.0\",\
        \"ICD\": {\
          \"library_path\": \"libGLX_nvidia.so.0\",\
          \"api_version\" : \"${VULKAN_API_VERSION}\"\
        }\
      }" > /etc/vulkan/icd.d/nvidia_icd.json

# Setup carlauser and UnrealEngine
RUN useradd -m carlauser && echo "carlauser:carlauser" | chpasswd && adduser carlauser sudo
COPY --chown=carlauser:carlauser . /home/carlauser
USER carlauser
WORKDIR /home/carlauser
ENV UE4_ROOT /home/carlauser/UE4.26

RUN git clone --depth 1 -b carla "https://${EPIC_USER}:${EPIC_PASS}@github.com/CarlaUnreal/UnrealEngine.git" ${UE4_ROOT}

RUN cd $UE4_ROOT && \
  ./Setup.sh && \
  ./GenerateProjectFiles.sh && \
  make

WORKDIR /home/carlauser/
