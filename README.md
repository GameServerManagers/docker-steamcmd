# SteamCMD Docker Image

[![SteamCMD](https://user-images.githubusercontent.com/4478206/197542699-ae13797a-78bb-4f37-81c2-d4880fd7709f.jpg)](https://developer.valvesoftware.com/wiki/SteamCMD)

[![Docker Pulls](https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&logo=docker&logoColor=white)](https://hub.docker.com/r/gameservermanagers/steamcmd)
[![Build Status](https://img.shields.io/github/actions/workflow/status/GameServerManagers/docker-steamcmd/docker-publish.yml?style=flat-square)](https://github.com/GameServerManagers/docker-steamcmd/actions)
[![Codacy grade](https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square&logo=codacy&logoColor=white)](https://www.codacy.com/gh/GameServerManagers/docker-steamcmd/dashboard)
[![SteamCMD Badge](https://img.shields.io/badge/SteamCMD-000000?style=flat-square&logo=Steam&logoColor=white)](https://developer.valvesoftware.com/wiki/SteamCMD)
[![MIT License](https://img.shields.io/github/license/gameservermanagers/docker-steamcmd?style=flat-square)](https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE)

> Lightweight, daily-built SteamCMD base image for game server automation.

## Quick Start

Pull the latest image and open SteamCMD interactive prompt:

```bash
docker pull gameservermanagers/steamcmd:latest
docker run -it --rm gameservermanagers/steamcmd:latest
```

Download (update) a dedicated server into the current host directory (example: CS2 / app 730):

```bash
docker run -it --rm \
  -v "$PWD:/data" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 730 validate +quit
```

Persist Steam content in a named volume:

```bash
docker volume create steamcmd-data
docker run -it --rm -v steamcmd-data:/home/steam/Steam gameservermanagers/steamcmd:latest +login anonymous +quit
```

## Tags & Platforms

| Tag(s) | Ubuntu Release | Notes |
| ------ | -------------- | ----- |
| `latest`, `ubuntu` | 24.04 LTS (Noble) | Alias to most recent LTS |
| `ubuntu-24.04` | 24.04 LTS | Current LTS |
| `ubuntu-22.04` | 22.04 LTS | Previous LTS |
| `ubuntu-20.04` | 20.04 LTS | Legacy (receives security updates) |
| `ubuntu-18.04` | 18.04 LTS | Legacy / nearing EOL upstream |

Currently built for: `linux/amd64`.

## Features

- Daily scheduled build + build on Dockerfile changes
- Non-root `steam` user (security best practice)
- Minimal packages; apt caches cleaned
- HEALTHCHECK (lightweight SteamCMD invocation)
- Multi-version tag set for pinning

## Usage Examples

Anonymous login and quit (cache initialization):

```bash
docker run --rm gameservermanagers/steamcmd:latest +login anonymous +quit
```

Install/Update Valheim dedicated server (app 896660) into a local folder:

```bash
mkdir -p valheim && \
docker run --rm -v "$PWD/valheim:/data" gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 896660 validate +quit
```

Run with a different timezone:

```bash
docker run --rm -e TZ=UTC gameservermanagers/steamcmd:latest +login anonymous +quit
```

## Data Persistence

Steam content is stored under `/home/steam/Steam` (owned by the non-root `steam` user). Mount a volume there to persist downloads across runs.

```bash
docker run -v steamcmd-data:/home/steam/Steam gameservermanagers/steamcmd:latest +login anonymous +quit
```

## Configuration

Common tunables (all optional):

| Option | How | Purpose |
| ------ | --- | ------- |
| Timezone | `-e TZ=Europe/London` | Control tzdata (if installed) |
| Working dir | `-w /home/steam` | Override working directory |
| User mapping | `--user $(id -u):$(id -g)` | Run with host UID/GID (if perms needed) |

Steam credentials (if you need a non-anonymous app):

```bash
docker run -it --rm gameservermanagers/steamcmd:latest +login <username> <password> +app_update <appid> +quit
```

Consider using Steam Guard / login tokens; avoid embedding secrets in shell history. Use `--env-file` for larger sets of env variables if needed.

## Healthcheck

The image defines a `HEALTHCHECK` that periodically performs a minimal anonymous login and metadata refresh. To disable at runtime, you can override with `--no-healthcheck` (Docker 25+) or build your own image `FROM` this one and use `HEALTHCHECK NONE`.

## Security Notes

- Runs as non-root `steam`
- Network access only to Steam endpoints during operations
- Keep host Docker updated; image alone does not mitigate kernel CVEs

## Contributing

Issues & PRs welcome. Before submitting:

1. Run formatters: `prettier --write .`
2. Run linters: super-linter workflow (or locally with the provided dev container)
3. Keep layers minimal; squash RUN chains where reasonable

## Related Projects

- [LinuxGSM](https://linuxgsm.com) – Game server management
- [steamcmd/docker](https://github.com/steamcmd/docker) – Upstream reference

## License

MIT – see [LICENSE](./LICENSE.md).

---

> Looking for additional architectures or features? Open an issue to discuss multi-arch builds or tag deprecation timelines.

## Troubleshooting

Empty output directory:

- Ensure the order: `+force_install_dir` comes BEFORE `+login` (SteamCMD requirement – it warns otherwise). If reversed, files may go to the default Steam library inside the container instead of your mounted directory.
- Verify permissions: the container runs as user `steam` (UID 1000). If your host user ID differs and you see permission errors, try adding `--user $(id -u):$(id -g)` or pre-chown the host directory.
- Add `validate` only when necessary; it forces extra file checks and can slow installs.


Confirm installation path by adding `+app_status <appid>` before `+quit` to inspect state.
