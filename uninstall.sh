#!/usr/bin/env bash

PURGE=false
case "${1:-}" in
  '') ;;
  --purge) PURGE=true ;;
  *) printf 'Usage: %s [--purge]\n' "$(basename "$0")" >&2; exit 1 ;;
esac
if [ "$#" -gt 1 ]; then
  printf 'Usage: %s [--purge]\n' "$(basename "$0")" >&2
  exit 1
fi

read -r -n 1 -p "Do you want to uninstall trash [Y/n] " CONFIRM
printf "\n"

BIN_PATH="/usr/local/bin/trash"

shopt -s nocasematch
if [[ "$CONFIRM" =~ ^y?$ ]]; then
  printf '\e[31;1mRemoving %s; sudo password maybe required\n\e[0m' "$BIN_PATH"
  echo sudo rm -f "$BIN_PATH"
  if ! sudo rm -f "$BIN_PATH"; then
    printf 'Could not remove %s\n' "$BIN_PATH" >&2
    exit 1
  fi
  if $PURGE; then
    read -r -n 1 -p "Also delete ~/.local/.trash and everything in it? [y/N] " PURGE_CONFIRM
    printf '\n'
    if [[ "$PURGE_CONFIRM" == y ]]; then
      if [[ -z "${HOME:-}" || "$HOME" == / ]]; then
        printf 'Refusing to purge: HOME is not a safe directory.\n' >&2
        exit 1
      fi
      TRASH_DIR="$HOME/.local/.trash"
      if ! rm -rf -- "$TRASH_DIR"; then
        printf 'Could not remove trash directory %s\n' "$TRASH_DIR" >&2
        exit 1
      fi
      printf 'Removed trash directory: %s\n' "$TRASH_DIR"
    else
      printf 'Trashed files were not deleted.\n'
    fi
  else
    printf "\e[33;1mTrashed files stored in '%s/.local/.trash' feel free to delete them too.\n\e[0m" "$HOME"
  fi
else
  printf "\e[32;1mUninstall canceled\n\e[0m"
fi

shopt -u nocasematch
exit 0

