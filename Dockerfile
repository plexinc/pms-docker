FROM ubuntu:16.04

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

# Install required packages
ADD ["https://github.com/just-containers/s6-overlay/releases/download/v1.17.2.0/s6-overlay-amd64.tar.gz", \
     "/tmp/"]

ENTRYPOINT ["/init"]

RUN \
# Extract S6 overlay
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \

# Update and get dependencies
    apt-get update && \
    apt-get install -y \
      curl \
      sudo \
      wget \
      xmlstarlet \
      uuid-runtime \
    && \

# Add user
    useradd -U -d /config -s /bin/false plex && \
    usermod -G users plex && \

# Setup directories
    mkdir -p \
      /config \
      /transcode \
      /data \
    && \

# Cleanup
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf var/tmp/*

EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode

ENV VERSION=latest \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

COPY root/ /
