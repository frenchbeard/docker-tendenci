FROM ubuntu:16.04
MAINTAINER frenchbeard <frenchbeardsec@gmail.com>

ENV TENDENCI_VERSION=7.2.34 \
    TENDENCI_USER="tendenci" \
    TENDENCI_HOME="/home/tendenci" \
    TENDENCI_LOG_DIR="/var/log/tendenci"

ENV TENDENCI_INSTALL_DIR="${TENDENCI_HOME}/install" \
    TENDENCI_DATA_DIR="${TENDENCI_HOME}/data" \
    TENDENCI_BUILD_DIR="${TENDENCI_HOME}/build" \
    TENDENCI_VIRTUALENV="${TENDENCI_HOME}/virtualenv" \
    TENDENCI_RUNTIME_DIR="${TENDENCI_HOME}/runtime" \
    APP_NAME="default"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && apt-get install -y build-essential python-dev libevent-dev libpq-dev \
        libjpeg8 libjpeg-dev libfreetype6 libfreetype6-dev git python-pip \
        python-virtualenv git sudo \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX

COPY assets/build/ ${TENDENCI_BUILD_DIR}
COPY assets/runtime/ ${TENDENCI_RUNTIME_DIR}
RUN bash -x ${TENDENCI_BUILD_DIR}/install.sh

EXPOSE 8000/tcp

VOLUME [ "${TENDENCI_DATA_DIR}", "${TENDENCI_LOG_DIR}" ]
WORKDIR ${TENDENCI_INSTALL_DIR}

ENTRYPOINT [ "/home/tendenci/runtime/entrypoint.sh" ]
CMD [ "app:start" ]
