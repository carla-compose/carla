
# run the docker container as:
#
# sudo -E docker run --rm --gpus all -it --net=host carla:latest /bin/bash

FROM vulkan-base:latest

RUN packages='libsdl2-2.0 xserver-xorg libvulkan1 libomp5' && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $packages --no-install-recommends

RUN useradd -m carla

COPY --chown=carla:carla . /home/carla

USER carla
WORKDIR /home/carla

# you can also run CARLA in offscreen mode with -RenderOffScreen
# CMD /bin/bash CarlaUE4.sh -RenderOffScreen
CMD /bin/bash CarlaUE4.sh
