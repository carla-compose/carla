ARG UBUNTU_VERSION="22.04"

FROM "ubuntu:${UBUNTU_VERSION}" as dependencies

USER root
SHELL ["/bin/bash", "-c"]

ARG CARLA_API_PATH=/opt/carla/PythonAPI

# Install essentials
RUN apt-get update && \
    apt-get install -y \
      fontconfig \
      x11-apps \
      python3-pip \
      libomp5 \
      libjpeg-turbo8 libtiff-dev \
      libgeos-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# Move over PythonAPI
COPY ./artifacts/PythonAPI ${CARLA_API_PATH}

# Recursively install PythonAPI requirements, keep version of first occurrence
RUN cat $(find ${CARLA_API_PATH} -type f -name "requirements.txt") > /tmp/requirements_raw.txt \
    && awk -F '==' '{print $1}' /tmp/requirements_raw.txt | awk '!visited[$1]++' > /tmp/requirements.txt \
    && pip3 install -r /tmp/requirements.txt

# Create script that adds API to pythonpath and make .bashrc source it
RUN echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_API_PATH/carla/dist/$(ls $CARLA_API_PATH/carla/dist | grep py$(python --version | awk -F'[ .]' '{print $2"."$3}').)" >> /setup_carla_env.sh; \
    echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_API_PATH/carla/agents" >> /setup_carla_env.sh; \
    echo "export PYTHONPATH=\$PYTHONPATH:$CARLA_API_PATH/carla" >> /setup_carla_env.sh; \
    echo "export CARLA_API_PATH=$CARLA_API_PATH" >> /setup_carla_env.sh; \
    echo "source /setup_carla_env.sh" >> ~/.bashrc


# Needed for (pygame based) scripts that have a GUI
ENV SDL_VIDEODRIVER=x11

USER root
SHELL ["/bin/bash", "-c"]

ARG WORKSPACE=${CARLA_API_PATH}
ENV WORKSPACE=${WORKSPACE}
WORKDIR ${WORKSPACE}

# Set entrypoint
COPY ./Util/Docker/client/entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "python3", "util/test_connection.py" ]
