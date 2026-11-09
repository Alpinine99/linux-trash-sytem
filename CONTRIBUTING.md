# Contributing to linux-trash-sytem

Thanks for wanting to help. This is a small Bash project, so a first contribution can be a few lines: a typo, a clearer message, a fix to one script. You do not need to ask permission to start.

## Ways to help

- Fix a bug or improve an error message.
- Improve the docs (README, comments, help text).
- Pick up an issue labelled [`good first issue`](https://github.com/Alpinine99/linux-trash-sytem/labels/good%20first%20issue). These are small, self-contained, and explain what "done" looks like.
- Report a bug or suggest a feature by opening an issue.

## Picking an issue

1. Comment on the issue to say you are taking it, so two people do not do the same work.
2. If it is unclear, ask in the issue before you start. Questions are welcome.
3. If you go quiet for a couple of weeks, the issue may be offered to someone else. That is fine, you can always come back.

## Setting up

1. Fork the repository on GitHub, then clone your fork:

   ```bash
   git clone https://github.com/<your-username>/linux-trash-sytem.git
   cd linux-trash-sytem
   git checkout -b my-change
   ```

2. You will need Bash, GNU coreutils, `awk` and `git`. [`shellcheck`](https://www.shellcheck.net/) is used for linting (`sudo apt install shellcheck`, `sudo pacman -S shellcheck`, or `sudo xbps-install shellcheck`).

**Do not run `./install.sh` while developing.** It copies the script into `/usr/local/bin` and needs `sudo`. Run `./trash.sh` straight from the folder instead.

## Testing safely

`trash` stores everything under `$HOME/.local/.trash`, so test with a throwaway `HOME` and your real files stay untouched. This block runs the main flows in a temporary folder and cleans up after itself:

```bash
REPO="$PWD"
(
  export HOME="$(mktemp -d)"; cd "$HOME" || exit 1
  echo hello > a.txt; mkdir dir; echo world > dir/b.txt

  "$REPO/trash.sh" a.txt dir          # both gone from the folder
  "$REPO/trash.sh" -l                 # history shows two TRASHED lines
  "$REPO/trash.sh" -r a.txt           # a.txt is back
  "$REPO/trash.sh" -p "$HOME/out" -r dir   # dir is restored into ./out
  "$REPO/trash.sh" a.txt; "$REPO/trash.sh" -e now   # trash is emptied
  ls -A "$HOME/.local/.trash"         # only the two log files remain

  rm -rf "$HOME"
)
```

Check that your change did what you intended, and that the flows above still work. If you changed behaviour, say how you tested it in your pull request.

Then lint:

```bash
shellcheck *.sh
```

A few notes already exist in the current scripts. Please do not add new ones, and feel free to fix existing ones (there is an issue for that).

## Code style

- Bash, two-space indentation, quote your variables (`"$var"`).
- Use `local` inside functions.
- Print problems with the `err`, `warn` and `info` helpers in `trash.sh` (errors and warnings go to stderr), and return a non-zero exit code on failure.
- Keep dependencies minimal. If you add a new command, make sure it is part of GNU coreutils and mention it in the README Requirements.
- Anything that deletes must stay inside `~/.local/.trash`. Be careful with `rm -rf`.

## Commits and pull requests

- Keep each pull request to one change.
- Write a short commit message in the present tense, for example `fix usage text` or `add --purge to uninstall.sh`.
- Update the README if you change how something is installed or used.
- In the pull request, describe what you changed, why, and how you tested it. Link the issue (`Closes #12`).
- Maintainers review when they can. If you do not hear back after a week, a polite nudge is fine.

## Reporting bugs

Open an issue with:

- your distribution and Bash version (`bash --version`),
- the exact command you ran,
- what you expected, and what happened instead (paste the output).

Please do not include real private file names. For a security problem, say so in the issue title without posting exploit details, and the maintainer will follow up.

## Code of conduct

Be kind and patient, assume good intentions, and give feedback on the code, not the person. Harassment or disrespect is not welcome, and the maintainer may remove comments or block people who keep it up.

## License

By contributing you agree that your contribution is released under the project's [MIT License](LICENSE).
