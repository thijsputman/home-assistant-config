FROM ubuntu:22.04
ARG S6_OVERLAY_VERSION=3.1.4.1

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install dependencies

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  'adb=1:10.0.*' \
  ca-certificates \
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

HEALTHCHECK --interval=5m --timeout=5s --retries=2 CMD \
  adb devices || exit 1

ENTRYPOINT ["/init"]

CMD ["androidtv"]
