# Custom Dockerfile for the release base image (based off of discontinued https://gitlab.com/nvidia/container-images/vulkan )

ARG DEBIAN_FRONTEND=noninteractive
ARG BASE_DIST=ubuntu22.04
ARG CUDA_VERSION=12.2.0

FROM nvidia/cuda:${CUDA_VERSION}-base-${BASE_DIST}

RUN apt-get update && apt-get install -y --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1  \
    libgles2  \
    libxcb1-dev \
    libjpeg8 \
    libtiff5 \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Vulkan SDK
# You can set VULKAN_SDK_VERSION as latest via build-arg=`curl https://vulkan.lunarg.com/sdk/latest/linux.txt`
ARG VULKAN_SDK_VERSION=1.3.268.0
ARG VULKAN_API_VERSION=1.3.268
# Download the Vulkan SDK and extract the headers, loaders, layers and binary utilities
RUN wget -q --show-progress \
    --progress=bar:force:noscroll \
    https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}/linux/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.xz \
    -O /tmp/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.gz \ 
    && echo "Installing Vulkan SDK ${VULKAN_SDK_VERSION}" \
    && mkdir -p /opt/vulkan \
    && tar -xf /tmp/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.gz -C /opt/vulkan \
    && mkdir -p /usr/local/include/ && cp -ra /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/include/* /usr/local/include/ \
    && mkdir -p /usr/local/lib && cp -ra /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/lib/* /usr/local/lib/ \
    && cp -a /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/lib/libVkLayer_*.so /usr/local/lib \
    && mkdir -p /usr/local/share/vulkan/explicit_layer.d \
    && cp /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/etc/vulkan/explicit_layer.d/VkLayer_*.json /usr/local/share/vulkan/explicit_layer.d \
    && mkdir -p /usr/local/share/vulkan/registry \
    && cp -a /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/share/vulkan/registry/* /usr/local/share/vulkan/registry \
    && cp -a /opt/vulkan/${VULKAN_SDK_VERSION}/x86_64/bin/* /usr/local/bin \
    && ldconfig \
    && rm /tmp/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.gz && rm -rf /opt/vulkan

# Generate Nvidia driver config
RUN mkdir -p /etc/vulkan/icd.d && \
    echo "{" > /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "    \"file_format_version\" : \"1.0.0\"," >> /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "    \"ICD\": {" >> /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "        \"library_path\": \"libGLX_nvidia.so.0\"," >> /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "        \"api_version\" : \"${VULKAN_API_VERSION}\"" >> /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "    }" >> /etc/vulkan/icd.d/nvidia_icd.json; \
    echo "}" >> /etc/vulkan/icd.d/nvidia_icd.json

# Setup the required capabilities for the container runtime    
ENV NVIDIA_DRIVER_CAPABILITIES compute,graphics,utility
