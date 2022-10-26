# SteamCMD Docker Image

<p align="center">
  <a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://user-images.githubusercontent.com/4478206/197542699-ae13797a-78bb-4f37-81c2-d4880fd7709f.jpg" alt="SteamCMD"></a>
<br>
<a href="https://hub.docker.com/r/gameservermanagers/steamcmd"><img src="https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&amp;logo=docker&amp;logoColor=white" alt="Docker Pulls"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/actions"><img src="https://img.shields.io/github/workflow/status/gameservermanagers/docker-steamcmd/Docker%20Publish?style=flat-square&logo=github&logoColor=white" alt="GitHub Workflow Status"></a>
<a href="https://www.codacy.com/gh/GameServerManagers/docker-steamcmd/dashboard"><img src="https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square&logo=codacy&logoColor=white" alt="Codacy grade"></a>
<a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://img.shields.io/badge/SteamCMD-000000?style=flat-square&amp;logo=Steam&amp;logoColor=white" alt="SteamCMD"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE"><img src="https://img.shields.io/github/license/gameservermanagers/docker-steamcmd?style=flat-square" alt="MIT License"></a></p>

## About

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

## Notes

This container is based off of the [steamcmd](https://github.com/steamcmd/docker) container and is primarily used for [LinuxGSM](https://linuxgsm.com) game servers.
