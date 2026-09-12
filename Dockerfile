#ARG CONTAINER=ghcr.io/openwrt/sdk
#ARG ARCH=mips_24kc
#FROM $CONTAINER:$ARCH

ARG BASE_IMAGE=ghcr.io/openwrt/buildbot/buildworker-v3.11.8:v21

FROM $BASE_IMAGE

# Install clang development libraries
USER root
RUN apt-get update && apt-get install -y \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

ARG USER=buildbot
ARG WORKDIR=/builder/
ARG CMD="/bin/bash"

#ARG DOWNLOAD_FILE="imagebuilder-.*x86_64.tar.[xz|zst]"
ARG DOWNLOAD_FILE="sdk-.*.Linux-x86_64.tar.[xz|zst]"
ARG TARGET=x86/64
ARG FILE_HOST=downloads.openwrt.org
ARG VERSION_PATH

ENV DOWNLOAD_FILE=$DOWNLOAD_FILE
ENV TARGET=$TARGET
ENV FILE_HOST=$FILE_HOST
ENV VERSION_PATH=$VERSION_PATH

USER $USER
WORKDIR $WORKDIR

#ADD --chown=buildbot:buildbot keys/*.asc /builder/keys/
COPY --chmod=0755 setup.sh /builder/setup.sh

ARG RUN_SETUP=0
ENV RUN_SETUP=$RUN_SETUP
RUN if [ "$RUN_SETUP" -eq 1 ]; then /builder/setup.sh; fi

#ENTRYPOINT [ ]

# required to have CMD as ENV to be executed
ENV CMD_ENV=${CMD}
CMD ${CMD_ENV}

LABEL "com.github.actions.name"="OpenWrt SDK"

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
