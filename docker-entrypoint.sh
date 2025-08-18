#!/usr/bin/env bash
set -euo pipefail

# Allow runtime override of steam user UID/GID via PUID/PGID env vars.
# If they differ from current numeric IDs, we modify /etc/passwd & /etc/group accordingly
# before executing steamcmd. This requires the container to start as root.

CURRENT_UID="$(id -u steam)"
CURRENT_GID="$(id -g steam)"
DESIRED_UID="${PUID:-$CURRENT_UID}"
DESIRED_GID="${PGID:-$CURRENT_GID}"

if [[ "${DESIRED_GID}" != "${CURRENT_GID}" ]]; then
  echo "Updating steam group GID: ${CURRENT_GID} -> ${DESIRED_GID}" >&2
  groupmod -o -g "${DESIRED_GID}" steam
  # Fix any files owned by old GID inside home (best effort)
  find /home/steam -xdev -group "${CURRENT_GID}" -exec chgrp -h "${DESIRED_GID}" {} + || true
fi

if [[ "${DESIRED_UID}" != "${CURRENT_UID}" ]]; then
  echo "Updating steam user UID: ${CURRENT_UID} -> ${DESIRED_UID}" >&2
  usermod -o -u "${DESIRED_UID}" steam
  find /home/steam -xdev -user "${CURRENT_UID}" -exec chown -h "${DESIRED_UID}" {} + || true
fi

# Ensure ownership of Steam data root (non-recursive check first, then minimal fix if needed)
if [[ ! -w /home/steam ]]; then
  echo "Warning: /home/steam not writable after UID/GID adjustment" >&2
fi

# Drop to steam user and run steamcmd
exec gosu steam:steam steamcmd "$@"
