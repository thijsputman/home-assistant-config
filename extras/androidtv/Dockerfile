FROM ubuntu:22.04
ARG S6_OVERLAY_VERSION=3.1.4.1

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install dependencies

RUN apt update && apt install -y \
  adb \
  sudo \
  wget \
  xz-utils && \
  rm -rf /var/lib/apt/lists/*

# Setup s6-overlay

RUN base_url=https://github.com/just-containers/s6-overlay/releases && \
    wget -nv -O /tmp/s6-overlay-noarch.tar.xz \
      "$base_url/download/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz" && \
    wget -nv -O /tmp/s6-overlay-arch.tar.xz \
      "$base_url/download/v$S6_OVERLAY_VERSION/s6-overlay-aarch64.tar.xz" && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz && \
    rm /tmp/s6-overlay*

COPY rootfs/ /

WORKDIR /androidtv
COPY androidtv.sh .

# Restore SHELL to its default
SHELL ["/bin/sh", "-c"]

ENTRYPOINT ["/init"]

CMD ["androidtv"]