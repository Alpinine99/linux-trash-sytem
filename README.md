# Trashing Recovery System

A simple Bash-based trash and restore utility that allows you to safely move files to a personal trash directory, inspect logs, restore items, and manage the trash contents.

## 🔍 Details

This is a trash/restore tool implemented in shell script and compiled to a binary file. It maintains a private trash directory and a log of trashed items for easy recovery and cleanup.

## 📁 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Alpinine99/linux-trash-sytem.git binsys
   cd binsys
   ```

2. Run `./install.sh` to create and confirm a compatible environment then install:

   ```bash
   ./install.sh
   ```

   > instructions are given in case of incompatibility, such as missing dependencies.

## 🗑️ Uninstallation

1. Move back to the project folder:

    ```bash
    cd binsys
    ```

2. Run `./uninstall.sh` to remove the binary:

    ```bash
    ./uninstall.sh
    ```

> The script uses `bash` and standard Unix utilities such as `mv`, `date`, and `tac`.

## 🛠 Usage

```bash
# view this help message
trash -h

# get logs
trash -l

# trash one or more files or directories
trash <file> <file> ...

# restore an item (name or folder)
trash -r <file/folder name>

# restore an item to a custom path
trash -p <custom path> -r <file/folder name>

# empty trash using a date filter
trash -e <date/"now"> <up/down>

# examples for emptying:
trash -e <date|epoch|'now'> <up|down>
trash -e "2026-03-06 23:57:43" up    # deletes from set date up
trash -e "7 days ago" down           # deletes from set date down

# clear everything immediately
trash -e now
```

## 📦 Behavior

- Trashed items are moved to `~/.local/.trash` and logged to `~/.local/.trash/.trashing.log`.
- Files are renamed to prevent name collisions and for security using a random suffix.
- Permissions are restricted on trashed files for safety.
- When restoring, you are prompted if multiple matches exist.
- The `-e` option allows selective cleanup based on log timestamps.

## 📄 Documentation & Examples

For more information and usage examples, check the [repository](https://github.com/Alpinine99/trashing-recovery-system.git).

## ⚠️ Notes

- The script operates on the current user's home directory and respects file permissions.
- Ensure you do not accidentally trash critical files—restore is possible until the trash is emptied.

---

Developed by **Alpinine99**
