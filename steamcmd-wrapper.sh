#!/bin/sh
set -eu

STEAMROOT="${XDG_DATA_HOME:-"${HOME}/.local/share"}/Steam"

if [ ! -e "${HOME}/.steam" ]; then
  mkdir -p "${HOME}/.steam"
  ln -s "${STEAMROOT}" "${HOME}/.steam/root"
  ln -s "${STEAMROOT}" "${HOME}/.steam/steam"
fi

if [ ! -e "${STEAMROOT}/steamcmd" ]; then
  mkdir -p "${STEAMROOT}/steamcmd"
  cp -r /usr/lib/games/steam/. "${STEAMROOT}/steamcmd/"
fi

exec "${STEAMROOT}/steamcmd/steamcmd.sh" "$@"
