FROM carla-prerequisites:latest

ARG GIT_BRANCH

USER carla
WORKDIR /home/carla

COPY . /home/carla/carla

RUN cd /home/carla/carla && \
  ./Update.sh && \
  make CarlaUE4Editor && \
  make PythonAPI ARGS="--python-version='3.10'" && \
  make build.utils && \
  make package

WORKDIR /home/carla/carla

COPY entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD [""]