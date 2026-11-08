#!/usr/bin/env bash

read -n 1 -p "Do you want to uninstall trash [Y/n] " CONFIRM
printf "\n"

BIN_PATH="/usr/local/bin/trash"

shopt -s nocasematch
if [[ "$CONFIRM" =~ ^y?$ ]]; then
  printf "\e[31;1mRemoving $BIN_PATH; sudo password maybe required\n\e[0m"
  echo sudo rm -f "$BIN_PATH"
  sudo rm -f "$BIN_PATH"
  printf "\e[33;1mTrashed files stored in '$HOME/.local/.trash' feel free to delete them too.\n\e[0m"
else
  printf "\e[32;1mUninstall canceled\n\e[0m"
fi

shopt -u nocasematch
exit 0

