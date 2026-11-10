#!/usr/bin/env bash

TARGET_FILE="trash.sh"
INSTALL_CMD="./install.sh"

printf "\e[33;1mFetching latest changes from GitHub...\n\e[0m"
git fetch origin

# Get the local and remote commit hashes for the target file or branch
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/main) # Or 'master' depending on your branch name

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
  printf "\e[32;1mRepository is already up to date. No action needed.\n\e[0m"
  exit 0
fi

printf "\e[34;1mPulling updates ...\n\e[0m"
git pull origin main

# Check specifically if the target file was modified in the latest pull
CHANGED_FILES=$(git diff --name-only "$LOCAL_HASH" "$REMOTE_HASH")

if echo "$CHANGED_FILES" | grep -q "$TARGET_FILE"; then
  printf "\e[33;1mTarget file '%s' has changed. Installing ...\n\e[0m" "$TARGET_FILE"
  if [ -x "$INSTALL_CMD" ]; then
    eval "$INSTALL_CMD"
    printf "\e[32;1mReinstallation complete.\n\e[0m"
  else
    printf "\e[31;1mError: Installer '%s' is not executable or not found.\n\e[0m" "$INSTALL_CMD"
    exit 1
  fi
else
  printf "\e[32;1mNo update on target '%s'. Skipping reinstallation.\n\e[0m" "$TARGET_FILE"
fi

