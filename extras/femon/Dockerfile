FROM ubuntu:20.04

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# s6-overlay
COPY just-containers.asc /tmp/just-containers.asc
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg=2.2.* \
      wget && \
    rm -rf /var/lib/apt/lists/* && \
    # Download just-containers s6-overlay installer and its signature
    wget -nv -O /tmp/s6-installer \
      https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-aarch64-installer && \
    wget -nv -O /tmp/s6-installer.sig \
      https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-aarch64-installer.sig && \
    # Import just-containers' public key; use gpgv to validate installer
    gpg --no-default-keyring --keyring /tmp/s6-installer.gpg --import \
      < /tmp/just-containers.asc && \
    gpgv --keyring /tmp/s6-installer.gpg /tmp/s6-installer.sig /tmp/s6-installer && \
    # Execute the installer
    chmod +x /tmp/s6-installer && /tmp/s6-installer / && \
    # Cleanup
    rm /tmp/s6-installer* && \
    apt-get purge -y \
      gnupg \
      wget

RUN apt-get update && apt-get install -y --no-install-recommends \
      dvb-apps=1.1.* \
      mosquitto-clients=1.6.* && \
    rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

WORKDIR /femon

COPY femon.sh .

# Restore SHELL to its default
SHELL ["/bin/sh", "-c"]

ENTRYPOINT ["/init"]
