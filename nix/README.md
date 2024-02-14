# NiX

Nix is an imutable packet manager to manage independant environnement.

## Installation

### Fedora

To install [Nix](https://nixos.org/download.html) on fedora, run the command as sudo :

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

You need to disable [SElinux](https://www.tecmint.com/disable-selinux-in-centos-rhel-fedora/). Open the file `/etc/sysconfig/selinux` and edit the line `SELINUX=disabled`.

Make the simlink : `ln default.nix ~/default.nix`

### Using nix environnement in vscode

USe the extension `arrterian.nix-env-selector`. Add the path to the nix file like : ``nixEnvSelector.nixFile``

## Reproducible shell

To make a [reproducible shell](https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs) in your project, you must specify the version of the package used with :

`nix-shell -p niv --run "niv init"`

It will generate in the folder `nix/` and generate the informations for the actuel nix release.

Next, you must add the following line to the `shell.nix` file at the root of the project :

```nix
{ sources ? import ./nix/sources.nix

, pkgs ? import sources.nixpkgs {}

}:
```

Finally, run `nix-shell` to trigger the shell.

# Python environnement

Use the info [here](https://ryantm.github.io/nixpkgs/languages-frameworks/python/).

## Work with no packaged python module

[Here](https://github.com/NixOS/nixpkgs/blob/49829a9adedc4d2c1581cc9a4294ecdbff32d993/doc/languages-frameworks/python.section.md#how-to-consume-python-modules-using-pip-in-a-virtual-environment-like-i-am-used-to-on-other-operating-systems-how-to-consume-python-modules-using-pip-in-a-virtual-environment-like-i-am-used-to-on-other-operating-systems) is the documentation. The trick is to launch a .venv environnement in the [shell](python/shell.nix) hook wich call pip and the [requirements](python/requirements.txt) file. Add the lines `autoPatchelf ./venv` inside `postVenvCreation` and `autoPatchelfHook` inside `buildInputs` to link the global environnement (nix-shell) to the local one (.venv).

## vscode python interpreter

To configure vscode python interpreter, open the nix-shell and run `which python` to have the path, and paste it inside the interpreter settings.
