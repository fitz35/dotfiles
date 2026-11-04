"""
`my_script github_menu <zed|code|terminal>` : rofi menu to open a project folder.

The listed folders are (most recently modified first) :
- the subfolders of each PARENT_FOLDERS,
- the HAND_PICKED_FOLDERS.
The selected folder is opened in zed (`zed`, $mod+t), vscode (`code`, $mod+Shift+t) or a kitty terminal (`terminal`, $mod+Alt+t) ;
zed and vscode start inside the `nix develop` shell of the folder when it has a flake.nix.
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


def open_editor(editor: str, directory: str) -> None:
    """the editor in the directory, inside its `nix develop` shell when it has a flake.nix"""
    os.chdir(directory)
    if os.path.exists("flake.nix"):
        if subprocess.run(["nix", "develop", "--command", editor, "."]).returncode == 0:
            return
        print(f"nix develop failed, opening {editor} without it")
    subprocess.run([editor, "."])


def open_terminal(directory: str) -> None:
    subprocess.Popen(["kitty", "--directory", directory])


ACTIONS = {
    "zed": lambda directory: open_editor("zeditor", directory),
    "code": lambda directory: open_editor("code", directory),
    "terminal": open_terminal,
}
# the prompt of the menu : which app the folder opens in
PROMPTS = {"zed": "Open in Zed", "code": "Open in VS Code", "terminal": "Open in a terminal"}


def main() -> None:
    parser = argparse.ArgumentParser(description="Open a project folder chosen in rofi.")
    parser.add_argument("action", choices=ACTIONS, help="open it in zed, vscode or a terminal")
    args = parser.parse_args()

    folders = list_folders()
    # the names are given through stdin, so the special characters don't break the command
    choice = subprocess.run([os.environ["MY_SCRIPT"], "rofi", "-dmenu", "-p", PROMPTS[args.action]],
                            input="\n".join(folders), text=True, capture_output=True).stdout.strip()
    if choice not in folders:
        sys.exit(1)  # nothing chosen
    ACTIONS[args.action](folders[choice])


if __name__ == "__main__":
    main()
