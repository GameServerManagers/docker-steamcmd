FROM ubuntu:22.04

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

## Upgrade Ubuntu
RUN echo "**** apt upgrade ****" \
    && apt-get update; \
    apt-get upgrade -y

# Install UTF-8 unicode
RUN echo "**** Install UTF-8 ****" \
    && apt-get update \
    && apt-get install -y locales apt-utils debconf-utils ca-certificates
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Install SteamCMD

RUN echo "**** Install SteamCMD ****" \
&& echo steam steam/question select "I AGREE" | debconf-set-selections \
&& echo steam steam/license note '' | debconf-set-selections \
&& dpkg --add-architecture i386 \
&& apt-get update -y \
&& apt-get install -y --no-install-recommends libsdl2-2.0-0:i386 locales steamcmd \
&& ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Update SteamCMD
RUN steamcmd +quit
