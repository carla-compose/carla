FROM carla-prerequisites:latest

ARG GIT_BRANCH

USER carla
WORKDIR /home/carla

COPY --chown=carla . /home/carla/carla

RUN cd /home/carla/carla && \
  ./Update.sh

RUN cd /home/carla/carla && \
  make CarlaUE4Editor

RUN cd /home/carla/carla && \
  make PythonAPI ARGS="--python-version='3.10'" 

RUN cd /home/carla/carla && \
  make build.utils

RUN cd /home/carla/carla && \
  make package

WORKDIR /home/carla/carla
