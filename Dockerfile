ARG DISTRO=ubuntu
ARG DISTRO_VERSION=26.04
ARG BASE_IMAGE=${DISTRO}:${DISTRO_VERSION}
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG PUID=1000
ARG PGID=1000
ARG GOSU_VERSION=1.19
ARG GOSU_SHA256=52c8749d0142edd234e9d6bd5237dff2d81e71f43537e2f4f66f75dd4b243dd0

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>" \
  org.opencontainers.image.title="SteamCMD" \
  org.opencontainers.image.description="SteamCMD headless image for acquiring dedicated server files" \
  org.opencontainers.image.url="https://github.com/GameServerManagers/docker-steamcmd" \
  org.opencontainers.image.source="https://github.com/GameServerManagers/docker-steamcmd" \
  org.opencontainers.image.vendor="GameServerManagers" \
  org.opencontainers.image.licenses="MIT"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Remove ubuntu user if present
RUN if id ubuntu >/dev/null 2>&1; then \
  touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu; \
  fi

COPY steamcmd-wrapper.sh /tmp/steamcmd-wrapper.sh

# Install SteamCMD
RUN echo "**** Install SteamCMD ****" \
  && . /etc/os-release \
  && if [ "${ID}" = "rocky" ]; then \
    dnf -y install --setopt=install_weak_deps=False \
      ca-certificates \
      glibc-langpack-en \
      glibc.i686 \
      libstdc++.i686 \
      SDL2.i686 \
      tar \
      tzdata \
    && mkdir -p /usr/lib/games/steam /usr/games \
    && curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /usr/lib/games/steam \
    && install -m 755 /tmp/steamcmd-wrapper.sh /usr/games/steamcmd \
    && curl -fsSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && echo "${GOSU_SHA256}  /usr/local/bin/gosu" | sha256sum -c - \
    && chmod +x /usr/local/bin/gosu \
    && dnf clean all \
    && rm -rf /var/cache/dnf; \
  else \
    echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && if [ "${ID}" = "debian" ]; then \
      sed -i 's/^Components: main$/Components: main contrib non-free/' /etc/apt/sources.list.d/debian.sources; \
    fi \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      locales \
      lib32gcc-s1 \
      libsdl2-2.0-0:i386 \
      tzdata \
      steamcmd \
      gosu \
    && if [ "${ID}" = "debian" ]; then \
      sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen; \
    else \
      locale-gen en_US.UTF-8; \
    fi \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*; \
  fi \
  && ln -s /usr/games/steamcmd /usr/bin/steamcmd \
  && rm -rf /usr/share/man /usr/share/doc /usr/share/info /usr/share/lintian /usr/share/locale/* \
  && mkdir -p /usr/share/man/man1 \
  && rm -rf /tmp/* /var/tmp/*

# Add unicode support
ENV LANG=en_US.UTF-8

# Create non-root user (default IDs; can be adjusted at runtime by entrypoint)
RUN groupadd -g "${PGID}" steam \
  && useradd -l -u "${PUID}" -g steam -m -d /home/steam -s /bin/bash steam

WORKDIR /home/steam

# Bootstrap SteamCMD as steam user
RUN su -s /bin/bash - steam -c 'steamcmd +login anonymous +quit || true'

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["+help", "+quit"]
