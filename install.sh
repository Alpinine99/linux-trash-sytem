#! /usr/bin/env bash


printf "\033[1m[x] Checking bash... "
if which bash >/dev/null 2>&1; then
    printf "\033[32myes\033[0m\n"
else
    printf "\033[31mno\033[0m\n"
    printf ">>> Install using package manager\n"
    exit 1
fi

printf "\033[1m[x] Checking path... "
mkdir -p $HOME/.local/bin
if echo $PATH | grep -q "$HOME/.local/bin"; then
    printf "\033[32myes\033[0m\n"
else
    printf "\033[31mno\033[0m\n"
    printf "\033[1m[x] Configuring path... "
    case "$SHELL" in
        *bash*) RC_FILE="$HOME/.bashrc" ;;
        *zsh*) RC_FILE="$HOME/.zshrc" ;;
        *fish*) RC_FILE="$HOME/.config/fish/config.fish" ;;
        *) RC_FILE="" ;;
    esac

    if [ -n "$RC_FILE" ]; then
        echo -e "\nexport PATH=\"$PATH:$HOME/.local/bin\"" >> $RC_FILE
    else
        printf "\033[31mno\033[0m\n"
        printf ">>> Add the line 'export PATH=\"$PATH:$HOME/.local/bin\"' to your shell rc file, then restart your shell\n"
        exit 1
    fi
    printf "\033[32myes\033[0m\n"
    printf "\033[33;1m[*] Shell restart required\033[0m\n"
fi

printf "\033[1m[x] Configuring shebang... "
bash_path=$(which bash)
sed -i "1c\#! $bash_path" ./trash.sh 2>/dev/null
if [ $? -ne 0 ]; then
    printf "\033[31mno\033[0m\n"
    printf "Confirm the file 'trash.sh' is present\n"
    exit 1
fi

printf "\033[1m[x] Installing script ... "
cp ./trash.sh $HOME/.local/bin/trash && chmod u+x $HOME/.local/bin/trash
if [ $? -ne 0 ]; then
    printf "\033[31mno\033[0m\n"
    printf "Confirm the file 'trash.sh' is present\n"
    exit 1
fi

printf "\033[32myes\033[0m\n"
printf "\033[34;1m[*] All set, run 'make'\033[0m\n"
exit 0
