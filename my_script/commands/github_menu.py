"""
`my_script github_menu <code|terminal>` : rofi menu to open a project folder.

The listed folders are (most recently modified first) :
- the subfolders of each PARENT_FOLDERS,
- the HAND_PICKED_FOLDERS.
The selected folder is opened in vscode (`code`, $mod+t) or in a kitty terminal (`terminal`, $mod+Alt+t).
"""

import argparse
import os
import subprocess
import sys
from typing import Dict

# the subfolders of these folders are listed
PARENT_FOLDERS = ["~/Documents/github/"]
# and these folders
HAND_PICKED_FOLDERS = ["~/Documents/github/perso-divers/document/"]


def list_folders() -> Dict[str, str]:
    """{name shown in the menu: path}, most recently modified first (the subfolders, then the hand picked ones)"""
    folders: Dict[str, str] = {}
    for parent in map(os.path.expanduser, PARENT_FOLDERS):
        subfolders = [name for name in os.listdir(parent) if os.path.isdir(os.path.join(parent, name))]
        for name in sorted(subfolders, key=lambda name: os.path.getmtime(os.path.join(parent, name)), reverse=True):
            folders[name] = os.path.join(parent, name, "")
    for folder in sorted(HAND_PICKED_FOLDERS, key=lambda folder: os.path.getmtime(os.path.expanduser(folder)), reverse=True):
        folders[folder] = os.path.join(os.path.expanduser(folder), "")
    return folders


def open_code(directory: str) -> None:
    """vscode in the directory, inside its `nix develop` shell when it has a flake.nix"""
    os.chdir(directory)
    if os.path.exists("flake.nix"):
        if subprocess.run(["nix", "develop", "--command", "code", "."]).returncode == 0:
            return
        print("nix develop failed, opening vscode without it")
    subprocess.run(["code", "."])


def open_terminal(directory: str) -> None:
    subprocess.Popen(["kitty", "--directory", directory])


ACTIONS = {"code": open_code, "terminal": open_terminal}


def main() -> None:
    parser = argparse.ArgumentParser(description="Open a project folder chosen in rofi.")
    parser.add_argument("action", choices=ACTIONS, help="open it in vscode or in a terminal")
    args = parser.parse_args()

    folders = list_folders()
    # the names are given through stdin, so the special characters don't break the command
    choice = subprocess.run([os.environ["MY_SCRIPT"], "rofi", "-dmenu", "-p", f"Select a folder to open {args.action} in "],
                            input="\n".join(folders), text=True, capture_output=True).stdout.strip()
    if choice not in folders:
        sys.exit(1)  # nothing chosen
    ACTIONS[args.action](folders[choice])


if __name__ == "__main__":
    main()
