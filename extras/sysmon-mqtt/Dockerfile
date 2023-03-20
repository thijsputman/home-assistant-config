FROM alpine:3.17
ARG S6_OVERLAY_VERSION=3.1.4.1
ENV SYSMON_IN_DOCKER=true

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Setup s6-overlay

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
      linux/arm64)  arch=aarch64 ;; \
      linux/arm/v7) arch=armhf ;; \
      linux/amd64)  arch=x86_64 ;; \
      *) echo "Invalid target platform '$TARGETPLATFORM'!" && exit 1 ;; \
    esac && \
    # Download installers
    base_url=https://github.com/just-containers/s6-overlay/releases && \
    wget -nv -O /tmp/s6-overlay-noarch.tar.xz \
      "$base_url/download/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz" && \
    wget -nv -O /tmp/s6-overlay-arch.tar.xz \
      "$base_url/download/v$S6_OVERLAY_VERSION/s6-overlay-$arch.tar.xz" && \
    # Execute installers
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz && \
    # Cleanup
    rm /tmp/s6-overlay*

# Install dependencies

RUN apk add --no-cache \
  bash~=5.2 \
  gawk~=5.1 \
  mosquitto-clients~=2.0 \
  jq~=1.6

COPY rootfs/ /

WORKDIR /sysmon
COPY sysmon.sh .

# Restore SHELL to its default
SHELL ["/bin/sh", "-c"]

ENTRYPOINT ["/init"]

CMD ["sysmon"]
