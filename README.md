# Trash: a trash and restore command for Linux

`trash` moves files and folders into a private trash directory instead of deleting them, keeps a log of what happened, and lets you restore items or empty the trash by date. It is a single Bash script (`trash.sh`) that the installer copies to `/usr/local/bin/trash`.

## 📋 Requirements

- Linux with Bash
- GNU coreutils (`date -d`, `realpath`, `mktemp`, `tac`, `tr`) and `awk`
- `less` (only used by `trash -l` when printing to a terminal)
- `sudo` (installing and uninstalling write to `/usr/local/bin`)

> macOS and BSD are not supported: their `date`, `realpath` and `tac` behave differently.

## 📁 Installation

1. Clone the repository and move into it:

   ```bash
   git clone https://github.com/Alpinine99/linux-trash-sytem.git
   cd linux-trash-sytem
   ```

2. Run the installer **from inside the project folder**:

   ```bash
   ./install.sh
   ```

   It copies `trash.sh` to `/usr/local/bin/trash` and makes it executable (`sudo` may ask for your password). There is no compile step; the installed command is the script itself.

3. Check it works:

   ```bash
   trash -h
   ```

## 🔄 Updating

Run this from the cloned folder:

```bash
./update.sh
```

It fetches the latest commits from `origin`, compares them with your copy, and pulls `main` if there is something new. If `trash.sh` changed, it runs `./install.sh` again for you. Otherwise it leaves your installed command alone.

> `update.sh` needs the project to be a git clone on the `main` branch. If you edited files in the clone, commit or stash your changes first or the pull may stop.

## 🧹 Uninstallation

1. Move into the project folder:

   ```bash
   cd linux-trash-sytem
   ```

2. Run the uninstaller:

   ```bash
   ./uninstall.sh
   ```

   It asks `Do you want to uninstall trash [Y/n]`. Press `y` or just **Enter** to continue; `n` cancels. It removes only `/usr/local/bin/trash`.

   To also delete the trash directory, use `./uninstall.sh --purge`. This asks for a **second confirmation**, and deletes `~/.local/.trash` only if you explicitly answer `y`. This permanently deletes any files and logs still in that directory. The normal `./uninstall.sh` command never deletes the trash directory.

3. **Your trashed files are not touched.** They stay in `~/.local/.trash`, together with the logs. To remove them as well, either empty the trash first (before uninstalling):

   ```bash
   trash -e now          # deletes every trashed item, keeps the logs
   ```

   or delete the whole folder afterwards (this cannot be undone):

   ```bash
   rm -rf ~/.local/.trash
   ```

## 🛠 Usage

```bash
# show the help message
trash -h

# trash one or more files or directories
trash notes.txt old-project/

# show the history (newest first)
trash -l

# restore an item by file or folder name
trash -r notes.txt

# restore to a different folder
trash -p ~/Documents -r notes.txt

# empty by date: <date | epoch | now> <up | down>
trash -e "7 days ago" down            # delete items trashed 7 days ago or earlier
trash -e "2026-03-06 23:57:43" up     # delete items trashed at that time or later
trash -e now                          # delete everything in the trash
```

If you leave out `up`/`down`, `down` is used. Dates can be anything GNU `date -d` understands, or a Unix timestamp.

## 📦 How it works

- Trashed items are moved to `~/.local/.trash`, a folder only you can open (permissions `700`).
- Each item is renamed to a random 15-character ID so two files with the same name never collide. Moving keeps the original file permissions, so nothing needs fixing when you restore.
- Two log files live in the trash folder:
  - `.trashing.log` is the index of what is in the trash now: time, original path and trash path, separated by tabs.
  - `.history.log` is the record of everything that happened (`TRASHED`, `RESTORED`, `DELETED`). `trash -l` shows it newest first.
- `trash -r <name>` finds items by file name or full original path. If several match, you pick one from a menu. It never overwrites an existing file; use `-p` to restore somewhere else.
- `trash -e` only ever deletes inside `~/.local/.trash`, even if the index file was edited by hand.
- `trash` refuses to trash its own trash folder.

## 🩺 Troubleshooting

| Problem | Cause and fix |
| --- | --- |
| `cp: cannot stat './trash.sh'` during install | You ran `install.sh` from another folder. `cd` into the project folder first. |
| `trash: command not found` after installing | `/usr/local/bin` is not in your `PATH`. Add it, or open a new terminal. |
| `tac: command not found` or `date: illegal option` | Your system is not GNU/Linux. See Requirements. |
| `'<folder>/<name>' already exists, specify recovery path!` | Something already sits at the original location. Restore with `-p <other folder>`. |

## 🤝 Contributing

Contributions are welcome, and small ones are great. Read [CONTRIBUTING.md](CONTRIBUTING.md) for how to run and test the scripts safely, and look for issues labelled [`good first issue`](https://github.com/Alpinine99/linux-trash-sytem/labels/good%20first%20issue).

## 📄 License

See [LICENSE](LICENSE).

---

Developed by **Alpinine99**
