FROM ubuntu:22.04

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"

# Install SteamCMD
RUN echo "**** Install SteamCMD ****" \
&& echo steam steam/question select "I AGREE" | debconf-set-selections \
&& echo steam steam/license note '' | debconf-set-selections \
&& dpkg --add-architecture i386 \
&& apt-get update -y \
&& apt-get install -y --no-install-recommends libsdl2-2.0-0:i386 locales steamcmd \
&& ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Update SteamCMD
RUN steamcmd +quit