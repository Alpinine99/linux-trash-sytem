#! /usr/bin/env bash

BIN_PATH="/usr/local/bin/trash"
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")/trash.sh"

printf "\033[1m[x] Installing script; sudo password maybe required ... \n\e[0m"

if [ ! -f "$SCRIPT_PATH" ]; then
  printf 'Error: Cannot find trash.sh next to install.sh (%s)\n' "$SCRIPT_PATH" >&2
  exit 1
fi

if ! sudo cp -- "$SCRIPT_PATH" "$BIN_PATH"; then
  printf 'Error: Could not install trash.sh to %s. Check sudo permissions.\n' "$BIN_PATH" >&2
  exit 1
fi

if ! sudo chmod 755 "$BIN_PATH"; then
  printf 'Error: Could not make %s executable.\n' "$BIN_PATH" >&2
  exit 1
fi

printf "\033[34;1m[*] All set, run 'trash -h' for help\033[0m\n"
exit 0
