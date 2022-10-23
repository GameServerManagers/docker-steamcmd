# SteamCMD Docker Image

[![Docker Pulls](https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg)](https://hub.docker.com/r/steamcmd/steamcmd)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/gameservermanagers/docker-steamcmd/Docker%20Publish)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/42d400dcdd714ae080d77fcb40d00f1c)](https://www.codacy.com/gh/GameServerManagers/docker-steamcmd/dashboard?utm_source=github.com&utm_medium=referral&utm_content=GameServerManagers/docker-steamcmd&utm_campaign=Badge_Grade)
[![Discord](https://discordapp.com/api/guilds/127498813903601664/widget.png?style=shield)](https://linuxgsm.com/discord) [![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE)

SteamCMD is a command-line version of the Steam client. It allows you to download and install games on a headless server. This container image builds daily and is available on [Docker Hub](https://hub.docker.com/r/gameservermanagers/steamcmd).

## Tags

- `latest`, `ubuntu` - Latest Ubuntu LTS release
- `ubuntu-22.04` - Ubuntu 22.04 LTS 'Jammy Jackalope'
- `ubuntu-20.04` - Ubuntu 20.04 LTS 'Focal Fossa'
- `ubuntu-18.04` - Ubuntu 18.04 LTS 'Bionic Beaver'

## Usage

docker cli

```bash
docker run -it gameservermanagers/steamcmd
```

```bash
docker run -it steamcmd/steamcmd:latest +login anonymous +app_update 740 +quit
```

# notes

This container is based off of the [steamcmd](https://github.com/steamcmd/docker) container and is primarily used for [LinuxGSM](https://linuxgsm.com) game servers.
