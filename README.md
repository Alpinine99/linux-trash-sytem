# Trashing Recovery System

A simple Bash-based trash and restore utility that allows you to safely move files to a personal trash directory, inspect logs, restore items, and manage the trash contents.

## 🔍 Details

This is a trash/restore tool implemented in shell script and compiled to a binary file. It maintains a private trash directory and a log of trashed items for easy recovery and cleanup.

## 📁 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Alpinine99/trashing-recovery-system.git
   cd trashing-recovery-system
   ```

2. Run `./configure` to create and confirm a compatible environment:

   ```bash
   ./configure
   ```

   > instructions are given in case of incompatibility, such as missing dependencies.

3. In case of a success message from `./configure` run `make` to compile the binary.

    ```bash
    make
    ```

4. You can test the binary from the current directory:

    ```bash
    ./binx -h
    ```

5. Install the binary:

    ```bash
    make install
    ```

    > **NOTE:** The binary is installed on user space and so no sudo required, the binary is only available to the current user.

## 🗑️ Uninstallation

1. Move back to the project folder:

    ```bash
    cd trashing-recovery-system
    ```

2. Run `make uninstall` to remove the binary:

    ```bash
    make uninstall
    ```

> The script uses `bash` and standard Unix utilities such as `mv`, `date`, and `tac`.

## 🛠 Usage

```bash
# view this help message
binx -h

# get logs
binx -l

# trash one or more files or directories
binx <file> <file> ...

# restore an item (name or folder)
binx -r <file/folder name>

# restore an item to a custom path
binx -p <custom path> -r <file/folder name>

# empty trash using a date filter
binx -e <date/"now"> <up/down>

# examples for emptying:
binx -e "Fri Mar  6 11:57:43 PM EAT 2026" up      # deletes from set date up
binx -e "Fri Jan  6 12:57:43 PM EAT 2026" down    # deletes from set date down

# clear everything immediately
binx -e now
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
