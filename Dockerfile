ARG BASE_IMAGE="ubuntu:20.04"
FROM ${BASE_IMAGE}

USER root

# Options for setup script
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ENV \
    USERNAME="${USERNAME}" \
    USER_UID="${USER_UID}" \
    USER_GID="${USER_GID}"
    

# Copy Script Files and Make them executable
COPY scripts/*.sh /tmp/scripts/
RUN chmod a+rwx /tmp/scripts/*.sh

# Install Ubuntu Package and create non-root user
RUN \
    /tmp/scripts/common-ubuntu.sh && \
    /tmp/scripts/clear-layer.sh

# Install Anaconda
ARG CONDA_INSTALL_PATH=/opt/conda
ARG PYTHON_VERSION=default
ENV PATH=${CONDA_INSTALL_PATH}/bin:${PATH}
RUN \
    /tmp/scripts/conda.sh "${CONDA_INSTALL_PATH}" "${PYTHON_VERSION}" && \
    /tmp/scripts/clear-layer.sh

# Set HOME Directory
ENV HOME="/home/${USERNAME}"

RUN env > /etc/environment
USER ${USERNAME}

# Install Jupyter
RUN \
    /tmp/scripts/jupyter.sh && \
    /tmp/scripts/clear-layer.sh

COPY start.sh /scripts/start.sh
RUN sudo chmod a+rwx /scripts/start.sh
WORKDIR ${HOME}

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD "/scripts/start.sh"