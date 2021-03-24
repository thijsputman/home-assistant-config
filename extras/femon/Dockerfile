FROM ubuntu:20.04

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# s6-overlay
RUN apt-get update && apt-get install -y \
      gnupg=2.2.* \
      wget && \
    rm -rf /var/lib/apt/lists/* && \
    # Download just-containers s6-overlay installer and its signature
    wget -O /tmp/s6-installer \
      https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-aarch64-installer && \
    wget -O /tmp/s6-installer.sig \
      https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-aarch64-installer.sig && \
    # Import just-containers' public key; use gpgv to validate installer
    wget -O - https://keybase.io/justcontainers/pgp_keys.asc?fingerprint=db301ba3f6f807e0d0e6ccb86101b2783b2fd161 | \
      gpg --no-default-keyring --keyring /tmp/s6-installer.gpg --import && \
    gpgv --keyring /tmp/s6-installer.gpg /tmp/s6-installer.sig /tmp/s6-installer && \
    # Execute the installer
    chmod +x /tmp/s6-installer && /tmp/s6-installer / && \
    # Cleanup
    rm /tmp/s6-installer* && \
    apt-get purge -y \
      gnupg \
      wget

RUN apt-get update && apt-get install -y \
      dvb-apps=1.1.* \
      mosquitto-clients=1.6.* && \
    rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

WORKDIR /femon

COPY femon.sh .

# Restore SHELL to its default
SHELL ["/bin/sh", "-c"]

ENTRYPOINT ["/init"]
