# SteamCMD Docker Image

[![Docker Pulls](https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&logo=docker&logoColor=white)](https://hub.docker.com/r/steamcmd/steamcmd)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/gameservermanagers/docker-steamcmd/Docker%20Publish?style=flat-square&logo=github&logoColor=white)
![Codacy grade](https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square)
[![Discord](https://img.shields.io/discord/127498813903601664?color=7289da&logo=discord&logoColor=white&style=flat-square&label=discord)](https://linuxgsm.com/discord)
[![SteamCMD](https://img.shields.io/badge/SteamCMD-000000?style=flat-square&logo=Steam&logoColor=white)](https://developer.valvesoftware.com/wiki/SteamCMD)
![GitHub](https://img.shields.io/github/license/gameservermanagers/docker-steamcmd?style=flat-square)

SteamCMD is a command-line version of the Steam client. It allows you to download and install games on a headless server. This container image builds daily and is available on [Docker Hub](https://hub.docker.com/r/gameservermanagers/steamcmd) as well as [GitHub Container Registry](https://github.com/GameServerManagers/docker-steamcmd/pkgs/container/steamcmd).

## Tags

- `latest`, `ubuntu` - Latest Ubuntu LTS release
- `ubuntu-22.04` - Ubuntu 22.04 LTS 'Jammy Jackalope'
- `ubuntu-20.04` - Ubuntu 20.04 LTS 'Focal Fossa'
- `ubuntu-18.04` - Ubuntu 18.04 LTS 'Bionic Beaver'

## Usage

docker cli

```bash
docker run -it gameservermanagers/steamcmd:latest
```

Download Counter Strike: Global Offensive Dedicated Server to current host directory.

```bash
docker run -it -v $PWD:/data gameservermanagers/steamcmd:latest +force_install_dir /data +login anonymous +app_update 740 +quit
```

# notes

This container is based off of the [steamcmd](https://github.com/steamcmd/docker) container and is primarily used for [LinuxGSM](https://linuxgsm.com) game servers.
