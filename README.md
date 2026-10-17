# SteamCMD Docker Image

<p align="center">
  <a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://user-images.githubusercontent.com/4478206/197542699-ae13797a-78bb-4f37-81c2-d4880fd7709f.jpg" alt="SteamCMD"></a>
<br>
<a href="https://hub.docker.com/r/gameservermanagers/steamcmd"><img src="https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&amp;logo=docker&amp;logoColor=white" alt="Docker Pulls"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/actions"><img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/GameServerManagers/docker-steamcmd/action-docker-publish.yml?style=flat-square"></a>
<a href="https://app.codacy.com/gh/GameServerManagers/docker-steamcmd"><img src="https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square&logo=codacy&logoColor=white" alt="Codacy grade"></a>
<a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://img.shields.io/badge/SteamCMD-000000?style=flat-square&amp;logo=Steam&amp;logoColor=white" alt="SteamCMD"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE.md"><img src="https://img.shields.io/github/license/gameservermanagers/docker-steamcmd?style=flat-square" alt="MIT License"></a></p>

## About

SteamCMD is a command-line version of the Steam client. It allows you to download and install games/server apps on a headless server.

This image is rebuilt weekly (and whenever the Dockerfile changes) so the Ubuntu base and SteamCMD stay current. It is published to [Docker Hub](https://hub.docker.com/r/gameservermanagers/steamcmd) and [GitHub Container Registry](https://github.com/GameServerManagers/docker-steamcmd/pkgs/container/steamcmd):

```text
gameservermanagers/steamcmd
ghcr.io/gameservermanagers/steamcmd
```

Images are built for `linux/amd64` only. SteamCMD is an x86 binary and does not run natively on ARM.

## Tags

| Tag(s)             | Ubuntu Release               | Standard Support Ends\* | Notes                             |
| ------------------ | ---------------------------- | ----------------------- | --------------------------------- |
| `latest`, `ubuntu` | 26.04 LTS (Resolute Raccoon) | May 2031                | Current LTS                       |
| `ubuntu-26.04`     | 26.04 LTS (Resolute Raccoon) | May 2031                | Current LTS                       |
| `ubuntu-24.04`     | 24.04 LTS (Noble Numbat)     | May 2029                | Previous LTS                      |
| `ubuntu-22.04`     | 22.04 LTS (Jammy Jellyfish)  | June 2027               | Older LTS                         |
| `ubuntu-20.04`     | 20.04 LTS (Focal Fossa)      | May 2025 (ended)        | Legacy (ESM only; may be removed) |

\*Dates are the end of standard (free) security updates according to Canonical's LTS schedule. Extended Security Maintenance (ESM) may continue past these dates. An image may be deprecated sooner if upstream packages (such as SteamCMD dependencies) become unavailable.

### Debian (testing only)

| Tag(s)      | Debian Release | Notes                                                    |
| ----------- | -------------- | -------------------------------------------------------- |
| `debian-13` | 13 (Trixie)    | For testing LinuxGSM on Debian. Not a supported release. |

The Debian images enable the `contrib` and `non-free` components, because the `steamcmd` package is in `non-free`.

Pin a specific `ubuntu-XX.04` tag if you need a stable base. `latest` moves to each new Ubuntu LTS shortly after release.

## Usage

Pull the latest image and open SteamCMD interactive prompt:

```bash
docker run -it --rm gameservermanagers/steamcmd:latest
```

Download and update an app into the current host directory (example: Garry's Mod Dedicated Server - appid 4020):

```bash
docker run -it --rm \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD:/data" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

### Docker Compose

```yaml
services:
  steamcmd:
    image: gameservermanagers/steamcmd:latest
    environment:
      PUID: 1000
      PGID: 1000
    volumes:
      - ./server-data:/data
      - ./steam-app:/home/steam/.local/share/Steam
    command: +force_install_dir /data +login anonymous +app_update 4020 validate +quit
```

```bash
docker compose run --rm steamcmd
```

## Data Persistence

SteamCMD stores its own files (the SteamCMD binaries, app manifests, depot cache, workshop cache and login data) in `/home/steam/.local/share/Steam`. Use `+force_install_dir` to put the app files in their own directory. If you leave out `+force_install_dir`, or put it after the first `+app_update`, the app is installed to:

```text
/home/steam/.local/share/Steam/steamapps/common/<AppName>
```

Mount a separate directory (e.g. `/data`) and pass `+force_install_dir /data` to keep the app files apart from the Steam cache. Also persisting `/home/steam/.local/share/Steam` means SteamCMD doesn't re-download its own update on every run, and keeps your login cached.

### Bind Mount Example

```bash
docker run -it --rm \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD:/data" \
  -v "/path/on/host/steamcmd-app:/home/steam/.local/share/Steam" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

### Docker Volume Example

```bash
docker volume create steamcmd-data
docker volume create steamcmd-app
docker run -it --rm \
  -v "steamcmd-data:/data" \
  -v "steamcmd-app:/home/steam/.local/share/Steam" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

## User, UID & GID (PUID / PGID)

The image uses a non-root user `steam` (default UID:GID 1000:1000). To change these IDs at runtime, set the `PUID` and `PGID` environment variables. The entrypoint starts as root, remaps the `steam` user/group, then drops privileges with `gosu` before running SteamCMD, so the files it creates match your host user.

### Runtime Override (recommended)

```bash
docker run --rm \
  -e PUID=1001 -e PGID=1001 \
  -v "$PWD/steam-app:/home/steam/.local/share/Steam" \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

### Running with `--user`

If your platform requires the container to start as non-root (e.g. `--user 1000:1000`, rootless setups, or Kubernetes `runAsUser`), the entrypoint skips the remapping and runs SteamCMD as that user. `PUID`/`PGID` are ignored in this mode. The built-in Steam directory is owned by UID 1000, so with any other UID you must mount a writable directory at `/home/steam/.local/share/Steam`.

### Building the Image

There is a single `Dockerfile`. Choose the base with the `DISTRO` (`ubuntu` or `debian`) and `DISTRO_VERSION` build arguments (defaults to the current Ubuntu LTS). You can also bake in alternate default IDs:

```bash
docker build --build-arg DISTRO_VERSION=24.04 --build-arg PUID=1001 --build-arg PGID=1001 -t steamcmd:ubuntu-24.04-uid1001 .
docker build --build-arg DISTRO=debian --build-arg DISTRO_VERSION=13 -t steamcmd:debian-13 .
```

### Troubleshooting permissions

| Symptom                        | Cause                                                          | Fix                                                      |
| ------------------------------ | -------------------------------------------------------------- | -------------------------------------------------------- |
| Files not showing in directory | Host dir owned by different UID                                | Run with matching PUID/PGID or chown host dir            |
| Steam Guard code every run     | Steam data dir not persisted (no volume or unwritable)         | Mount and ensure ownership of the Steam data dir         |
| Root-owned files in host mount | Ran container with `--user root`                               | Remove `--user`; use PUID/PGID env vars                  |
| `Permission denied` on startup | Started with `--user` other than 1000 without a Steam data dir | Use PUID/PGID instead, or mount a writable Steam dir too |

## Login Examples

SteamCMD supports anonymous and authenticated logins. Use anonymous wherever possible.

### Anonymous (preferred)

```bash
docker run --rm \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD/steam-app:/home/steam/.local/share/Steam" \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

### Authenticated (username/password)

Some apps (e.g. certain private branches, tools, or beta depots) require a Steam account.

#### Stateless (no persistent Steam data)

Because nothing is persisted, this will almost always ask for a Steam Guard code on first use, and again on later runs:

```bash
docker run --rm \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +@ShutdownOnFailedCommand 1 +force_install_dir /data \
  +login "${STEAM_USER}" "${STEAM_PASS}" +app_update 223350 +quit
```

#### Persistent (recommended)

Persist `/home/steam/.local/share/Steam` so the login is cached and later runs skip the Steam Guard prompt.

```bash
docker run --rm \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD/steam-app:/home/steam/.local/share/Steam" \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +@ShutdownOnFailedCommand 1 \
  +force_install_dir /data \
  +login "${STEAM_USER}" "${STEAM_PASS}" +app_update 223350 +quit
```

Recommendations:

- For authenticated workflows, always mount persistent Steam data (see Data Persistence above) to avoid repeated Steam Guard prompts.
- Pass credentials via environment variables or a one-shot secret. Don't hard-code them in compose files committed to source control.
- When Steam Guard (2FA / email) asks for a code, you can pass it inline as a third argument (`+login user pass CODE`). Or run once interactively to cache the login in the mounted Steam directory.
- Use a dedicated account that only has the entitlements you need, never your main account.
- Treat the mounted Steam data directory as sensitive because it contains cached login tokens. Do not publish it.

### Handling Steam Guard / 2FA

1. Run interactively (`docker run -it ...`) once with a persistent Steam data mount.
2. Enter the code when prompted (do NOT add it to scripts).
3. Later scripted runs succeed without prompting because the login is cached.

## SteamCMD Commands

Common commands/flags you can chain after the image name (order matters; see the notes below):

| Command / Flag                                 | Purpose                                                             | Example Snippet                                |
| ---------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------- |
| `+login anonymous`                             | Anonymous login (most dedicated servers allow)                      | `+login anonymous`                             |
| `+login <user> <pass>`                         | Authenticated login (needed for some apps / private betas)          | `+login myuser mypass`                         |
| `+@NoPromptForPassword 1`                      | Suppress interactive password/guard prompts (fail fast)             | `+@NoPromptForPassword 1 +login myuser mypass` |
| `+@ShutdownOnFailedCommand 1`                  | Abort remaining commands if one fails                               | `+@ShutdownOnFailedCommand 1`                  |
| `+@sSteamCmdForcePlatformType <os>`            | Force platform (linux / windows / macos) for content                | `+@sSteamCmdForcePlatformType windows`         |
| `+force_install_dir <path>`                    | Set target directory for app files (must come before `+app_update`) | `+force_install_dir /data`                     |
| `+app_update <appid>`                          | Install or update an app (server / game)                            | `+app_update 896660`                           |
| `+app_update <appid> -beta <branch>`           | Install a specific beta branch                                      | `+app_update 896660 -beta public-test`         |
| `+app_update <appid> validate`                 | Integrity check & re-download missing/corrupt files (slower)        | `+app_update 740 validate`                     |
| `+app_status <appid>`                          | Print install status / progress (debug)                             | `+app_status 896660`                           |
| `+app_info_update 1`                           | Refresh app info cache (used before querying details)               | `+app_info_update 1`                           |
| `+workshop_download_item <appid> <itemid>`     | Download a specific workshop item                                   | `+workshop_download_item 4020 3418671232`      |
| `+download_depot <appid> <depotid> <manifest>` | Fetch a specific depot/manifest (version pinning)                   | `+download_depot 90 90 402078904020789`        |
| `+runscript <file>`                            | Execute batch of commands from script file                          | `+runscript /scripts/install.txt`              |
| `+quit`                                        | Exit steamcmd when previous commands complete                       | `+quit`                                        |

### Command Notes

- Recommended order: `+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +force_install_dir /data +login ... +app_update <appid> validate +quit`
- Always put `+force_install_dir` before `+login` and the first `+app_update`. Otherwise files go to the default library (`/home/steam/.local/share/Steam/steamapps/common`).
- `@` settings such as `+@sSteamCmdForcePlatformType` must also come before `+login`.
- Only append `validate` when you need it: for an initial install, or when you suspect corruption.
- Use a script file (`+runscript`) for complex multi-app workflows. Write each line like the inline form, without the leading `+` and without shell quoting.
- For workshop items, install the base app (server) first. Workshop content lands in the app's workshop directory.
- `+download_depot` ignores `+force_install_dir` and saves to `/home/steam/.local/share/Steam/steamcmd/linux32/steamapps/content/`. It may need an authenticated login with access to the right branch. Manifest IDs are version-specific.

## FAQ

**Q: How do I find an appid?**
Search [SteamDB](https://steamdb.info) and use the numeric App ID shown.

**Q: Why do I get "Failed to connect" or SSL errors?**
Usually this is a transient network problem, or a firewall doing deep packet inspection. Retry, or check that outbound HTTPS (443) and the Steam ports (TCP/UDP 27015–27050) are open.

**Q: Can I run multiple updates in one container invocation?**
Yes. Either chain several `+app_update` commands, or use a runscript file with one per line.

**Q: Do I need to expose any ports?**
Not for downloading content. Game server ports belong to the separate server container you build/run from the downloaded files.

**Q: Does it run on ARM (Raspberry Pi, Apple Silicon)?**
Not natively. SteamCMD is x86-only. On Apple Silicon, Docker Desktop can run the amd64 image under emulation (`--platform linux/amd64`), but it will be slower.

## Notes

This image is inspired by the [steamcmd/docker](https://github.com/steamcmd/docker) image and is primarily used for [LinuxGSM](https://linuxgsm.com) game servers.

### Supported releases

The versions that get built are listed in [`versions.json`](versions.json). A weekly workflow checks Ubuntu's release data for a new LTS. When one is released and the image builds and passes a SteamCMD smoke test, the workflow opens a pull request that adds it and moves `latest` to it.
