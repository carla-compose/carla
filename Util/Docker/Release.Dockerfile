
# run the docker container as:
#
# sudo -E docker run --rm --gpus all -it --net=host carla:latest /bin/bash

FROM vulkan-base:latest

RUN packages='libsdl2-2.0 xserver-xorg libvulkan1 libomp5' && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $packages --no-install-recommends

RUN useradd -m carla

COPY --chown=carla:carla . /home/carla

# Create env setup script to make CARLA PythonAPI easily accessible (needs interactive shell!)
ARG CARLA_PYAPI_PATH=/home/carla/PythonAPI
ENV CARLA_PYAPI_PATH=${CARLA_PYAPI_PATH}

RUN echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_PYAPI_PATH/carla/dist/$(ls $CARLA_PYAPI_PATH/carla/dist | grep .egg)" >> $CARLA_PYAPI_PATH/setup_env.sh; \
    echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_PYAPI_PATH/carla/agents" >> $CARLA_PYAPI_PATH/setup_env.sh; \
    echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_PYAPI_PATH/carla" >> $CARLA_PYAPI_PATH/setup_env.sh; \
    echo "source $CARLA_PYAPI_PATH/setup_env.sh" >> /etc/bash.bashrc

USER carla
WORKDIR /home/carla

HEALTHCHECK --interval=1s --timeout=5s --start-period=10s --retries=3 \
  CMD python3 ./PythonAPI/util/ping.py

# you can also run CARLA in offscreen mode with -RenderOffScreen
# CMD /bin/bash CarlaUE4.sh -RenderOffScreen
CMD /bin/bash CarlaUE4.sh
