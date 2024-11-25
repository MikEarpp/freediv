PowerDNS Util Autocompletion Script

This repository contains a script to set up autocompletion for the pdnsutil command, used with PowerDNS. It will enable autocompletion for various pdnsutil commands and zone names when you are using a shell.

Requirements

    pdnsutil must be installed and accessible in your $PATH for the script to work properly.

    This script has been designed to work with bash autocompletion.

How to use
1. Clone the repository

Clone this repository to your local machine:

git clone https://github.com/your-username/pdnsutil-autocompletion.git
cd pdnsutil-autocompletion

2. Install the script

The script will create a bash_completion file for pdnsutil. To use it:

Option 1: Manual installation

    Run the script to generate the autocompletion file:

./generate_pdnsutil_completion.sh

Source the generated file by adding the following to your ~/.bashrc or ~/.bash_profile:

source ~/path/to/pdnsutil-autocompletion/pdnsutil_<version>_.bash_completion

Restart your terminal or source your ~/.bashrc:

    source ~/.bashrc

Option 2: Automatic installation (requires root privileges)

Run the installation script to automatically install the autocompletion:

sudo ./install_pdnsutil_completion.sh

3. Enjoy autocompletion!

Once installed, the pdnsutil command will have autocompletion for all supported commands and zone names. Start typing pdnsutil and press Tab to see available options.
