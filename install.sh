#! /usr/bin/env bash

BIN_PATH="/usr/local/bin/trash"
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")/trash.sh"

# BOLD=$'\e[1m'
RED=$'\e[31;1m'
GRN=$'\e[32;1m'
# YEL=$'\e[33;1m'
# UL=$'\e[4;1m'
# RST=$'\e[0m'

err()  { printf '%sE - %s%s\n' "$RED" "$*" "$RST" >&2; }
# warn() { printf '%sW - %s%s\n' "$YEL" "$*" "$RST" >&2; }
info() { printf '%sI - %s%s\n' "$GRN" "$*" "$RST"; }

info "Installing script; sudo password maybe required ..."

if [ ! -f "$SCRIPT_PATH" ]; then
  err "Cannot find trash.sh next to install.sh ($SCRIPT_PATH)"
  exit 1
fi

if ! sudo cp -- "$SCRIPT_PATH" "$BIN_PATH"; then
  err "Could not install trash.sh to $BIN_PATH. Check sudo permissions."
  exit 1
fi

if ! sudo chmod 755 "$BIN_PATH"; then
  err "Could not make $BIN_PATH executable."
  exit 1
fi

info "All set, run 'trash -h' for help"
exit 0

