# Installation

## From fedora

[Here](https://nixos.org/manual/nixos/stable/#sec-installing-from-other-distro) :
Install the tool :

```shell
nix-env -f '<nixpkgs>` -iA nixos-install-tools
```

After, you must mount to `/mnt` the partition where nixos will be installed, and the efi partition to `/mnt/boot/efi`. Next, launch the tool :

```shell
sudo `which nixos-generate-config` --root /mnt
```

You can then override the nixos configuration at `/mnt/etc/nixos/configuration.nix`

You can execute the following to link :

```shell
sudo rm /mnt/etc/nixos/configuration.nix
sudo cp ./config_nix.nix /mnt/etc/nixos/config_nix.nix
sudo cp ./flake.nix /mnt/etc/nixos/flake.nix
sudo cp ./configuration.nix /mnt/etc/nixos/configuration.nix
```

You can modify the config_nix.nix file with partition name for example.

After, you must export the NIX_PATH :

```shelll
export NIX_PATH=nixpkgs=/home/clement/.nix-defexpr/channels/nixpkgs
```

After, build nixos :

```shell
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --root /mnt
```

### Inside nixos

After modification of the configuration file, reload with

```shell
sudo nixos-rebuild switch
```

Theire is the script too : `sudo sh ./update_config.sh`

> WARN : don't forget to modify config_nix.nix !

## Flake

Flake is used to make reproducible environnement.

### Direnv

The extension nix-env-selector dont work with [flake](https://github.com/arrterian/nix-env-selector/issues/53), a workaround is to use [nix direnv](https://github.com/nix-community/nix-direnv).

`programs.direnv.enable = true;` allow the use of `use flake` in `.envrc` and environement management like this [extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

> WARN : need to add `eval "$(direnv hook bash)"` to bashrc, or in the config

## Locales

> WARN : take care of the locales !!!!! the default one of a config is us_US so if it has incoherence with the system it will raise the `perl : warn your locales are bad !` error message. See [here](https://nixos.org/manual/nixos/stable/options#opt-i18n.defaultLocale)

> Warn : Polybar need us_US

## Filesystem

When installing nixos using the ISO, mount the relewant disk in the `/mnt` file system, and generate the `hardware-configuration.nix` with `generate-config --root /mnt`. Then, you can custom the `configuration.nix` (activate `nix.settings.experimental-features = [ "nix-command" "flakes" ];` for example) 

# sound
> WARN : Don't use pulseaudio daemon, it will screw up the sound config ! See [here](https://discourse.nixos.org/t/cant-get-alsa-nixos-working/644/2) But you can add pulseaudio as package to have pactl for example.

# OpenGL

[Here](https://nixos.wiki/wiki/OpenGL), Add to configuration.nix

```nix
hardware.opengl.enable = true;
hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];
environment.systemPackages = with pkgs; [
    mesa
];
```

# Using zotero

To use effictevly zotero in nixeos, we must follow [these](https://nixos.wiki/wiki/Zotero).

# GDM [Background](https://discourse.nixos.org/t/gdm-background-image-and-theme/12632/4) image

The [patch](https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/3877) must be in the nixos folder (`/etc/nixos/`).

> WARN : This doesn't work, apply the patch directly

[Here](https://discourse.nixos.org/t/unable-to-change-background-in-gdm/33563/4) is the steps to apply the patch directly.


# Xsession

The description can be found [here](https://gist.github.com/bennofs/bb41b17deeeb49e345904f2339222625).

# clean OS

```shell
sudo nix-env --delete-generations 2d
sudo nix-collect-garbage -d
```