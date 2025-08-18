# SteamCMD Docker Image

<p align="center">
  <a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://user-images.githubusercontent.com/4478206/197542699-ae13797a-78bb-4f37-81c2-d4880fd7709f.jpg" alt="SteamCMD"></a>
<br>
<a href="https://hub.docker.com/r/gameservermanagers/steamcmd"><img src="https://img.shields.io/docker/pulls/gameservermanagers/steamcmd.svg?style=flat-square&amp;logo=docker&amp;logoColor=white" alt="Docker Pulls"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/actions"><img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/GameServerManagers/docker-steamcmd/docker-publish.yml?style=flat-square"></a>
<a href="https://www.codacy.com/gh/GameServerManagers/docker-steamcmd/dashboard"><img src="https://img.shields.io/codacy/grade/42d400dcdd714ae080d77fcb40d00f1c?style=flat-square&logo=codacy&logoColor=white" alt="Codacy grade"></a>
<a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://img.shields.io/badge/SteamCMD-000000?style=flat-square&amp;logo=Steam&amp;logoColor=white" alt="SteamCMD"></a>
<a href="https://github.com/GameServerManagers/docker-steamcmd/blob/main/LICENSE"><img src="https://img.shields.io/github/license/gameservermanagers/docker-steamcmd?style=flat-square" alt="MIT License"></a></p>

## About

SteamCMD is a command-line version of the Steam client. It allows you to download and install games on a headless server. This container image builds daily and is available on [Docker Hub](https://hub.docker.com/r/gameservermanagers/steamcmd) as well as [GitHub Container Registry](https://github.com/GameServerManagers/docker-steamcmd/pkgs/container/steamcmd).

## Tags

| Tag(s)             | Ubuntu Release              | Standard Support Ends\* | Notes                              |
| ------------------ | --------------------------- | ----------------------- | ---------------------------------- |
| `latest`, `ubuntu` | 24.04 LTS (Noble)           | April 2029              | Current LTS                        |
| `ubuntu-24.04`     | 24.04 LTS (Noble Numbat)    | April 2029              | Current LTS                        |
| `ubuntu-22.04`     | 22.04 LTS (Jammy Jackalope) | April 2027              | Previous LTS                       |
| `ubuntu-20.04`     | 20.04 LTS (Focal Fossa)     | April 2025              | Legacy (receives security updates) |

\*Dates are end of standard (free) security updates per Canonical's published LTS schedule. Extended Security Maintenance (ESM) may continue beyond these dates, but images may be deprecated earlier if upstream packages (e.g. SteamCMD dependencies) become unavailable.

## Usage

Pull the latest image and open SteamCMD interactive prompt:

```bash
docker run -it --rm gameservermanagers/steamcmd:latest
```

Download and update a dedicated server into the current host directory (example: Garry's Mod / appid 4020):

```bash
docker run -it --rm \
  -v "$PWD:/data" \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 validate +quit
```

## Data Persistence

SteamCMD data (manifests, configs, logs etc) is stored under `/home/steam/.local/share/Steam` (owned by the non‑root `steam` user). Mount a host directory or a docker volume at that path to persist it across runs. Ensure the host path is writable by the container's UID:GID (default `1000:1000`, or your custom `PUID:PGID`). If you dont use `force_install_dir` files will be downloaded to `steamapps/common`.

### Bind Mount Example

```bash
mkdir -p /path/on/host/steamcmd-data
chown 1000:1000 /path/on/host/steamcmd-data
docker run -it --rm \
  -v "$PWD:/data" \
  -v /path/on/host/steamcmd-data:/home/steam/.local/share/Steam \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 validate +quit
```

### Docker Volume Example

```bash
docker volume create steamcmd-data
docker run -it --rm \
  -v "$PWD:/data" \
  -v steamcmd-data:/home/steam/.local/share/Steam \
  gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 validate +quit
```

## SteamCMD Commands

Common commands / flags you can chain after the image name (order matters; see notes below):

| Command / Flag                                 | Purpose                                                             | Example Snippet                                |
| ---------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------- |
| `+login anonymous`                             | Anonymous login (most dedicated servers allow)                      | `+login anonymous`                             |
| `+login <user> <pass>`                         | Authenticated login (needed for some apps / private betas)          | `+login myuser mypass`                         |
| `+@NoPromptForPassword 1`                      | Suppress interactive password/guard prompts (fail fast)             | `+@NoPromptForPassword 1 +login myuser mypass` |
| `+@ShutdownOnFailedCommand 1`                  | Abort remaining commands if one fails                               | `+@ShutdownOnFailedCommand 1`                  |
| `+force_install_dir <path>`                    | Set target directory for app files (must come before `+app_update`) | `+force_install_dir /data`                     |
| `+app_update <appid>`                          | Install or update an app (server / game)                            | `+app_update 896660`                           |
| `+app_update <appid> validate`                 | Integrity check & re-download missing/corrupt files (slower)        | `+app_update 740 validate`                     |
| `+app_status <appid>`                          | Print install status / progress (debug)                             | `+app_status 896660`                           |
| `+app_info_update 1`                           | Refresh app info cache (used before querying details)               | `+app_info_update 1`                           |
| `+workshop_download_item <appid> <itemid>`     | Download a specific workshop item                                   | `+workshop_download_item 4020 3418671232`      |
| `+download_depot <appid> <depotid> <manifest>` | Fetch a specific depot/manifest (version pinning)                   | `+download_depot 90 90 402078904020789`        |
| `+sSteamCmdForcePlatformType <os>`             | Force platform (linux / windows / macos) for content                | `+sSteamCmdForcePlatformType windows`          |
| `+runscript <file>`                            | Execute batch of commands from script file                          | `+runscript /scripts/install.txt`              |
| `+quit`                                        | Exit steamcmd when previous commands complete                       | `+quit`                                        |

### Command Notes

- Recommended order: `+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +force_install_dir /data +login ... +app_update <appid> validate +quit`
- Always place `+force_install_dir` before the first `+app_update` or files go to the default library (`/home/steam/Steam/steamapps`).
- Append `validate` sparingly; use it for initial install or when corruption is suspected.
- Use a script file (`+runscript`) for complex multi-app workflows; each line should mirror the inline form (without shell quoting issues).
- For workshop items, ensure the base app (server) is installed first; workshop content lands under the app's workshop directory.
- `+download_depot` may require authenticated login and correct branch access; manifests are version-specific.

## Notes

This container is based off of the [steamcmd](https://github.com/steamcmd/docker) container and is primarily used for [LinuxGSM](https://linuxgsm.com) game servers.

## Login Examples

SteamCMD supports anonymous and authenticated logins. Use anonymous wherever possible.

### Anonymous (preferred)

```bash
docker run --rm -it gameservermanagers/steamcmd:latest \
  +force_install_dir /data +login anonymous +app_update 4020 validate +quit
```

### Authenticated (username/password)

Some apps (e.g. certain private branches, tools, or beta depots) require a Steam account.

#### Stateless (no persistent Steam data)

This will almost always trigger Steam Guard on first use and again later because nothing is persisted:

```bash
docker run --rm \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +@ShutdownOnFailedCommand 1 \
  +force_install_dir /data \
  +login "${STEAM_USER}" "${STEAM_PASS}" +app_update 223350 +quit
```

#### Persistent (recommended)

Persist `/home/steam/.local/share/Steam` so the sentry (guard) file is cached and subsequent runs skip the code prompt.

```bash
docker run --rm \
  -v "$PWD/steam-data:/home/steam/.local/share/Steam" \
  -v "$PWD/server-data:/data" \
  gameservermanagers/steamcmd:latest \
  +@ShutdownOnFailedCommand 1 \
  +force_install_dir /data \
  +login "${STEAM_USER}" "${STEAM_PASS}" +app_update 223350 +quit
```

Recommendations:

- Always mount persistent Steam data for authenticated workflows (see Data Persistence section) to avoid repeated Steam Guard prompts.
- Pass credentials via environment variables or a one‑shot secret, not hard‑coded in compose files committed to source control.
- After any Steam Guard (2FA / email) prompt, you can supply the code inline: `+login user pass CODE` (third argument) or run once interactively to cache the sentry file in the mounted Steam directory.
- Use a dedicated throwaway account with only the required entitlements; never your main account.
- Treat the mounted Steam data directory as sensitive (contains auth tokens / sentry files). Do not publish it.

### Handling Steam Guard / 2FA

1. Run interactively once with a persistent Steam data mount.
2. Enter the code when prompted (do NOT add it to scripts).
3. Subsequent scripted runs succeed without further prompts because the sentry file is stored.

If you need fully non‑interactive guarded logins (CI), pre-stage the sentry file by performing step 1 locally and copying the Steam config directory into your CI secret store.

## Known Pitfalls

- Missing `+force_install_dir` before `+app_update` causes files to land in the default Steam library instead of your intended mount.
- Running as root (by overriding user) can create permission mismatches when later running as the default `steam` user.
- Using `validate` every run significantly slows updates; reserve it for first install or suspected corruption.
- Authenticated logins without a persistent Steam data volume will continually re-trigger Steam Guard challenges.
- Workshop items for some games require the game server to read them from a specific path; double‑check game docs for any required symlinks or copy steps.
- Clock skew or wrong system time (TZ/ntp) can cause auth or SSL errors; ensure the host clock is correct.
- Over-zealous bind mounts (e.g. mounting an empty host dir over `/home/steam`) can hide required directories created during image build.

## FAQ

**Q: How do I find an appid?**
Search [SteamDB](https://steamdb.info) and use the numeric App ID shown.

**Q: Why do I get "Failed to connect" or SSL errors?**
Usually transient network or firewall DPI interference. Retry, or ensure outbound TCP 27015/27036 & HTTPS ports are open.

**Q: Can I run multiple updates in one container invocation?**
Yes, either chain multiple `+app_update` commands or use a runscript file with one per line.

**Q: How do I pin a specific version?**
Use `+download_depot` with a known manifest id (from SteamDB) after installing the main app. Keep in mind manifests disappear over time.

**Q: My login works locally but not in CI. Why?**
Your sentry file (Steam Guard token) wasn't copied. Persist and supply the Steam config directory or use anonymous where allowed.

**Q: Do I need to expose any ports?**
No for downloading content. Game server ports are handled by the separate server container you build/run using the downloaded files.
