# PowerDNS Util Autocompletion Script

This repository contains a script to set up autocompletion for the `pdnsutil` command, used with PowerDNS. It will enable autocompletion for various `pdnsutil` commands and zone names when you are using a shell.

## Requirements / Prérequis

- **`pdnsutil`** must be installed and accessible in your `$PATH` for the script to work properly.
- This script has been designed to work with bash autocompletion.

### 1. Clone the repository

```bash
git clone https://github.com/your-username/pdnsutil-autocompletion.git
cd pdnsutil-autocompletion

### 2. Generate the autocompletion file

```bash
./generate_pdnsutil_completion.sh
