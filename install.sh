#! /usr/bin/env bash

BIN_PATH="/usr/local/bin/trash"

printf "\033[1m[x] Installing script; sudo password maybe required ... \n\e[0m"

echo "sudo cp ./trash.sh $BIN_PATH && sudo chmod 755 $BIN_PATH"
sudo cp ./trash.sh "$BIN_PATH" && sudo chmod 755 "$BIN_PATH"

if [ $? -ne 0 ]; then
  printf "\033[31mno\033[0m\n"
  printf "Confirm the file 'trash.sh' is present\n"
  exit 1
fi

printf "\033[34;1m[*] All set, run 'trash # for help'\033[0m\n"
exit 0

