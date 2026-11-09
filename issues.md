# Starter issues for linux-trash-sytem

Copy each one into **Issues → New issue** on GitHub: paste the title, paste the text below it into the description, then open **Labels** on the right and choose `good first issue`.


---

## Issue 1

**Title** (copy this into the title box):

```
Fix the help text: old repo URL and missing -h
```

**Description** (copy everything below into the description box):

````markdown
**What's wrong**
`trash -h` (and running `trash` with no arguments) prints a link to the old repository name, `trashing-recovery-system.git`, which only works through a redirect. The usage list also does not mention `-h` itself.

**Where**
`usage()` in `trash.sh` (around lines 10 to 27).

**What to do**
1. Change the documentation URL to `https://github.com/Alpinine99/linux-trash-sytem` (no `.git`).
2. Add a line for `trash -h` to the usage list.

**Done when**
- `./trash.sh -h` shows the new URL and lists `-h`.
- `shellcheck trash.sh` reports nothing new.

See CONTRIBUTING.md for how to test safely.
````


---

## Issue 2

**Title** (copy this into the title box):

```
install.sh should work from any folder and explain failures
```

**Description** (copy everything below into the description box):

````markdown
**What's wrong**
`install.sh` copies `./trash.sh`, so it only works when you run it from inside the project folder. From anywhere else the user sees `cp: cannot stat './trash.sh'` and a bare red `no`, which is confusing.

**Where**
`install.sh`

**What to do**
1. Make the script find `trash.sh` next to itself (for example with `"$(dirname "$0")/trash.sh"`).
2. If the file is missing or the copy fails, print a clear error message instead of just `no`.
3. Replace the `$?` check with `if ! sudo cp ...; then` (shellcheck note SC2181).

**Done when**
- `/path/to/repo/install.sh` works when run from another folder.
- Running it with `trash.sh` missing prints a helpful message and exits with a non-zero code.
- `shellcheck install.sh` is clean.
````


---

## Issue 3

**Title** (copy this into the title box):

```
uninstall.sh: add a --purge option to also delete the trash folder
```

**Description** (copy everything below into the description box):

````markdown
**What's wrong**
`uninstall.sh` only removes `/usr/local/bin/trash`. Trashed files and logs stay in `~/.local/.trash`, and the user is told to delete them by hand.

**Where**
`uninstall.sh`

**What to do**
1. Add a `--purge` flag. When given, after the normal confirmation ask a second question: `Also delete ~/.local/.trash and everything in it? [y/N]`. Only delete on an explicit `y`.
2. Without `--purge`, behaviour stays exactly the same.
3. Mention `--purge` in the Uninstallation section of the README.
4. Optional: fix the shellcheck notes in this file (SC2162 for `read`, SC2059 for variables in `printf`).

**Done when**
- `./uninstall.sh --purge` removes the folder only after the second confirmation.
- The default run does not touch `~/.local/.trash`.
- Test with a throwaway `HOME` (see CONTRIBUTING.md), never your real trash.
````


---

## Issue 4

**Title** (copy this into the title box):

```
trash -e: check the arguments before saying 'Nothing to clean'
```

**Description** (copy everything below into the description box):

````markdown
**What's wrong**
`empty()` returns early with `Nothing to clean!` when the trash is empty, before it checks the arguments. So with an empty trash, `trash -e banana` and `trash -e now sideways` both print `Nothing to clean!`. With items in the trash the same commands correctly say `Invalid date!` or `Direction must be 'up' or 'down'`.

**Where**
`empty()` in `trash.sh` (around lines 188 to 210).

**What to do**
Move the direction check and the date parsing above the "nothing to clean" check, so bad input is always reported as bad input.

**Done when**
- With an empty trash: `trash -e banana` prints `Invalid date!` and exits non-zero.
- With an empty trash: `trash -e now sideways` prints the direction error and exits non-zero.
- With an empty trash: `trash -e now` still prints `Nothing to clean!`.
- The restore, trash and empty flows in CONTRIBUTING.md still work.
````


---

## Issue 5

**Title** (copy this into the title box):

```
Add a ShellCheck GitHub Actions workflow and fix existing notes
```

**Description** (copy everything below into the description box):

````markdown
**What's wrong**
Nothing checks the scripts automatically, and `shellcheck *.sh` currently reports nine notes (SC2181, SC2155, SC2015, SC2162, SC2059).

**What to do**
1. Add `.github/workflows/shellcheck.yml` that runs ShellCheck on `*.sh` for every push and pull request.
2. Fix the existing notes (they are all small), or open a separate PR for that.

**Done when**
- The workflow runs on a pull request and passes.
- `shellcheck *.sh` prints nothing.
````
