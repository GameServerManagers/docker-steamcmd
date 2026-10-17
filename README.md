# SteamCMD Docker Image

<p align="center">
  <a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://user-images.githubusercontent.com/4478206/197542699-ae13797a-78bb-4f37-81c2-d4880fd7709f.jpg" alt="SteamCMD"></a>
<br>
<a href="https://hub.docker.com/r/gameservermanagers/steamcmd"><img src="https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&amp;logo=docker&amp;logoColor=white" alt="Docker Pulls"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/actions"><img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/GameServerManagers/docker-steamcmd/action-docker-publish.yml?style=flat-square"></a>
<a href="https://app.codacy.com/gh/GameServerManagers/docker-steamcmd"><img src="https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square&logo=codacy&logoColor=white" alt="Codacy grade"></a>
<a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://img.shields.io/badge/SteamCMD-000000?style=flat-square&amp;logo=Steam&amp;logoColor=white" alt="SteamCMD"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License"></a></p>

## About

SteamCMD is the command-line version of the Steam client. It downloads and updates games and dedicated server files on a headless server.

This image runs SteamCMD as a non-root user. It is rebuilt weekly, and whenever the Dockerfile changes, so the base image and SteamCMD stay current. It is published to [Docker Hub](https://hub.docker.com/r/gameservermanagers/steamcmd) and [GitHub Container Registry](https://github.com/GameServerManagers/docker-steamcmd/pkgs/container/steamcmd):

```text
gameservermanagers/steamcmd
ghcr.io/gameservermanagers/steamcmd
```

Images are built for `linux/amd64` only, because SteamCMD is an x86 program. See the [FAQ](#faq) for ARM.

## Tags

### Ubuntu

| Tag(s)             | Ubuntu release               | Standard support ends\* | Notes                             |
| ------------------ | ---------------------------- | ----------------------- | --------------------------------- |
| `latest`, `ubuntu` | 26.04 LTS (Resolute Raccoon) | May 2031                | Current LTS                       |
| `ubuntu-26.04`     | 26.04 LTS (Resolute Raccoon) | May 2031                | Current LTS                       |
| `ubuntu-24.04`     | 24.04 LTS (Noble Numbat)     | May 2029                | Previous LTS                      |
| `ubuntu-22.04`     | 22.04 LTS (Jammy Jellyfish)  | June 2027               | Older LTS                         |
| `ubuntu-20.04`     | 20.04 LTS (Focal Fossa)      | May 2025 (ended)        | Legacy (ESM only; may be removed) |

\*The end of Canonical's free security updates. Extended Security Maintenance (ESM) can continue after that. An image may be retired sooner if packages SteamCMD needs stop being available.

`latest` moves to each new Ubuntu LTS shortly after it is released. Pin a specific `ubuntu-XX.04` tag if you need the base to stay the same.

### Other distros (testing only)

These images exist to test [LinuxGSM](https://linuxgsm.com) on other distros. They work the same way as the Ubuntu images, but they are not supported releases.

| Tag(s)      | Release              |
| ----------- | -------------------- |
| `debian-13` | Debian 13 (Trixie)   |
| `debian-12` | Debian 12 (Bookworm) |
| `rocky-9`   | Rocky Linux 9        |

Rocky Linux 10 isn't available, because it no longer ships the 32-bit (i686) libraries SteamCMD needs.

## Quick start

Open an interactive SteamCMD prompt:

```bash
docker run -it --rm gameservermanagers/steamcmd:latest
```

Download Garry's Mod Dedicated Server (app ID 4020) into `./server-data`, keeping SteamCMD's own files in `./steam-app` so later runs are faster. Create both directories first, so they're owned by you rather than by root:

```bash
mkdir -p server-data steam-app
docker run -it --rm \
  -e PUID="$(id -u)" -e PGID="$(id -g)" \
  -v "$PWD/server-data:/data" \
  -v "$PWD/steam-app:/home/steam/.local/share/Steam" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

Everything after the image name is passed to SteamCMD. Run the same command again to update the app.

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
    command: +force_install_dir /data +login anonymous +app_update 4020 +quit
```

```bash
mkdir -p server-data steam-app
docker compose run --rm steamcmd
```

## Data persistence

The image uses two directories:

| Path                             | What's in it                                                                                      |
| -------------------------------- | ------------------------------------------------------------------------------------------------- |
| `/data`                          | The app files, when you pass `+force_install_dir /data`.                                          |
| `/home/steam/.local/share/Steam` | SteamCMD's own files: its binaries and updates, app manifests, download caches and cached logins. |

Mount both. Without the Steam directory, SteamCMD re-downloads its own update on every run and forgets your login.

Always pass `+force_install_dir` before `+login`. If you leave it out, the app is installed inside the Steam directory instead:

```text
/home/steam/.local/share/Steam/steamapps/common/<AppName>
```

The examples use bind mounts (host directories). Named Docker volumes work too:

```bash
docker volume create steamcmd-data
docker volume create steamcmd-app
docker run -it --rm \
  -v steamcmd-data:/data \
  -v steamcmd-app:/home/steam/.local/share/Steam \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 +quit
```

## User and group IDs (PUID / PGID)

SteamCMD runs as the user `steam`, with UID and GID 1000 by default. Set `PUID` and `PGID` to match your host user, as in the [Quick start](#quick-start), and the files it creates in your mounted directories will be owned by you. The container starts as root to change the IDs, then drops to the `steam` user before running SteamCMD.

### Running with `--user`

Some platforms require containers to start as a non-root user (for example `--user 1000:1000`, rootless Docker or Kubernetes `runAsUser`). In that case the IDs aren't changed, `PUID` and `PGID` are ignored, and SteamCMD runs as the user you gave. The built-in Steam directory is owned by UID 1000, so with any other UID you must mount a writable directory at `/home/steam/.local/share/Steam`.

### Troubleshooting permissions

| Symptom                                             | Cause                                                               | Fix                                                                                |
| --------------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `mkdir: Permission denied` or nothing is downloaded | The host directory didn't exist, so Docker created it owned by root | Create the directories yourself before the first run, or `chown` them to your user |
| Can't read or change the downloaded files           | The host directory is owned by a different UID                      | Set `PUID` / `PGID` to your IDs, or `chown` the directory                          |
| Asked for a Steam Guard code every run              | The Steam directory isn't mounted, or isn't writable                | Mount it and make sure the container's user owns it                                |
| Root-owned files in the host directory              | The container ran with `--user root`                                | Remove `--user` and use `PUID` / `PGID`                                            |
| `Permission denied` on startup                      | Started with `--user` other than 1000 without a Steam directory     | Use `PUID` / `PGID` instead, or also mount a writable Steam directory              |

## Logging in with a Steam account

Use `+login anonymous` wherever you can; most dedicated servers allow it. Some apps, private branches and beta depots need a Steam account that owns them:

```bash
docker run -it --rm \
  -e PUID="$(id -u)" -e PGID="$(id -g)" \
  -v "$PWD/server-data:/data" \
  -v "$PWD/steam-app:/home/steam/.local/share/Steam" \
  gameservermanagers/steamcmd:latest \
  +@ShutdownOnFailedCommand 1 +force_install_dir /data \
  +login "${STEAM_USER}" "${STEAM_PASS}" +app_update 223350 +quit
```

**Steam Guard:** the first login asks for a Steam Guard code. Run the command above once with `-it` and type the code when asked. The login is then cached in the mounted Steam directory, so later runs, including scripted ones, don't ask again. Without that mount, every run asks for a new code. You can also pass a code as a third argument (`+login user pass CODE`), but don't put codes in scripts.

Keep your account safe:

- Use a dedicated Steam account with only the games you need, never your main account.
- Pass the username and password through environment variables or a secret. Don't commit them in compose files.
- The Steam directory holds cached login tokens. Keep it private.

## SteamCMD commands

Commands run in the order you give them, so order matters. A typical full command is:

```text
+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +force_install_dir /data +login anonymous +app_update <appid> validate +quit
```

| Command                                        | What it does                                                      | Example                                        |
| ---------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| `+login anonymous`                             | Log in anonymously (most dedicated servers allow it)              | `+login anonymous`                             |
| `+login <user> <pass>`                         | Log in with a Steam account                                       | `+login myuser mypass`                         |
| `+@NoPromptForPassword 1`                      | Fail instead of prompting for a password or Steam Guard code      | `+@NoPromptForPassword 1 +login myuser mypass` |
| `+@ShutdownOnFailedCommand 1`                  | Stop at the first command that fails                              | `+@ShutdownOnFailedCommand 1`                  |
| `+@sSteamCmdForcePlatformType <os>`            | Download the files for another platform (linux, windows or macos) | `+@sSteamCmdForcePlatformType windows`         |
| `+force_install_dir <path>`                    | Choose where the app is installed                                 | `+force_install_dir /data`                     |
| `+app_update <appid>`                          | Install or update an app                                          | `+app_update 896660`                           |
| `+app_update <appid> -beta <branch>`           | Install a beta branch                                             | `+app_update 896660 -beta public-test`         |
| `+app_update <appid> validate`                 | Check every file and re-download any that are missing or corrupt  | `+app_update 740 validate`                     |
| `+app_status <appid>`                          | Show an app's install status                                      | `+app_status 896660`                           |
| `+app_info_update 1`                           | Refresh the app info cache                                        | `+app_info_update 1`                           |
| `+workshop_download_item <appid> <itemid>`     | Download a Workshop item                                          | `+workshop_download_item 4020 3418671232`      |
| `+download_depot <appid> <depotid> <manifest>` | Download a specific depot version                                 | `+download_depot 90 90 402078904020789`        |
| `+runscript <file>`                            | Run commands from a file                                          | `+runscript /scripts/install.txt`              |
| `+quit`                                        | Exit once the earlier commands finish                             | `+quit`                                        |

Notes:

- `+force_install_dir` and any `+@` settings must come before `+login`.
- `validate` is slower. Use it for a first install, or when you suspect files are damaged, rather than on every update.
- To update several apps in one run, chain several `+app_update` commands, or put them in a `+runscript` file. Write each line of the file without the leading `+` and without shell quoting.
- Install the base app before downloading its Workshop items. Workshop content goes into the app's Workshop directory.
- `+download_depot` ignores `+force_install_dir` and saves to `/home/steam/.local/share/Steam/steamcmd/linux32/steamapps/content/`. It may need a logged-in account with access to the branch. Manifest IDs are specific to one version.

## FAQ

**How do I find an app ID?**
Search for the app on [SteamDB](https://steamdb.info) and use its App ID.

**Why do I get "Failed to connect" or SSL errors?**
Usually it's a short network problem, or a firewall inspecting traffic. Retry, and check that outbound HTTPS (443) and the Steam ports (TCP/UDP 27015 to 27050) are open.

**Do I need to publish any ports?**
Not for downloading. Game server ports belong to the container that runs the server.

**Does it run on ARM (Raspberry Pi, Apple Silicon)?**
Not natively, because SteamCMD is x86-only. On Apple Silicon, Docker Desktop can run the amd64 image under emulation (`--platform linux/amd64`), but it is slower.

## Building the image

There is a single `Dockerfile`. Choose the distro with the `DISTRO` (`ubuntu`, `debian` or `rocky`) and `DISTRO_VERSION` build arguments; the default is the current Ubuntu LTS. The base image defaults to `<distro>:<version>`. Set `BASE_IMAGE` when it is named differently, as Rocky Linux's is. `PUID` and `PGID` change the default user and group IDs.

```bash
docker build --build-arg DISTRO_VERSION=24.04 -t steamcmd:ubuntu-24.04 .
docker build --build-arg DISTRO=debian --build-arg DISTRO_VERSION=13 -t steamcmd:debian-13 .
docker build --build-arg DISTRO=rocky --build-arg DISTRO_VERSION=9 --build-arg BASE_IMAGE=rockylinux/rockylinux:9 -t steamcmd:rocky-9 .
docker build --build-arg PUID=1001 --build-arg PGID=1001 -t steamcmd:uid1001 .
```

How SteamCMD is installed differs by distro, but the result is the same:

- **Ubuntu and Debian** install the distro's `steamcmd` package. On Debian that means enabling the `contrib` and `non-free` components.
- **Rocky Linux** has no `steamcmd` package, so the image installs Valve's SteamCMD download and a small `steamcmd` wrapper ([`steamcmd-wrapper.sh`](steamcmd-wrapper.sh)) that sets up the same `/home/steam/.local/share/Steam` layout. `gosu` comes from its GitHub release and is checked against a pinned SHA-256.

## How new releases are added

The images that get built are listed in [`versions.json`](versions.json). Each week a workflow checks for a new Ubuntu LTS, Debian stable or Rocky Linux release. It opens a pull request to add a new release when:

- its base image is on Docker Hub, and
- the new image builds and passes a SteamCMD smoke test.

A new Ubuntu LTS also takes the `latest` tag. Rocky Linux 10 is skipped because it has no i686 libraries.

## Credits

This image is inspired by the [steamcmd/docker](https://github.com/steamcmd/docker) image and is mainly used for [LinuxGSM](https://linuxgsm.com) game servers.
