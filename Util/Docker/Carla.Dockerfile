FROM carla-prerequisites:latest

ARG GIT_BRANCH

USER carla

COPY --chown=carla . /home/carla/carla

WORKDIR /home/carla/carla

RUN ./Update.sh

RUN make CarlaUE4Editor
  
RUN make PythonAPI ARGS="--python-version='3.10'" 

RUN make build.utils

RUN make package