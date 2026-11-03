# NixOS

The system is built directly from this folder (a flake, with its `flake.lock`) :

| File | Content |
| --- | --- |
| `flake.nix` | the inputs (nixpkgs stable, minegrub, my_script) and one entry per machine |
| `configuration.nix` | the configuration shared by all the machines |
| `hosts/<hostname>/` | the machine specific part : `hardware-configuration.nix` (generated) and `default.nix` (user name, keyboard, encryption) |
| `update_config.sh` | `nixos-rebuild switch` for this machine (picked by its hostname) |
| `flake_update.sh` | update `flake.lock` (then run `update_config.sh`) |

> WARN : stay on the stable release (`nixos-XX.YY`), not unstable.

> WARN : a new file must be added to git (`git add`) before a rebuild, else the flake doesn't see it.

The installation of a new machine is described in the [README](../README.md#new-machine). To install from another linux instead of the ISO, see [here](https://nixos.org/manual/nixos/stable/#sec-installing-from-other-distro) (mount the partitions in `/mnt`, the efi one in `/mnt/boot/efi`, then `nixos-install --flake`).

Old generations are removed automatically every week (`nix.gc`, 2 weeks kept), and `/tmp` is cleaned at each boot.

## Direnv

The extension nix-env-selector doesn't work with [flake](https://github.com/arrterian/nix-env-selector/issues/53), a workaround is to use [nix direnv](https://github.com/nix-community/nix-direnv).

`programs.direnv.enable = true;` allows `use flake` in `.envrc` (the bash hook is added automatically) and environment management like this [extension](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).

## Locales

> WARN : take care of the locales !!!!! the default one of a config is us_US so if it has incoherence with the system it will raise the `perl : warn your locales are bad !` error message. See [here](https://nixos.org/manual/nixos/stable/options#opt-i18n.defaultLocale)

> Warn : Polybar need us_US

# Sound

> WARN : Don't use pulseaudio daemon, it will screw up the sound config ! See [here](https://discourse.nixos.org/t/cant-get-alsa-nixos-working/644/2) But you can add pulseaudio as package to have pactl for example.

# Using zotero

To use effectively zotero in nixos, we must follow [these](https://nixos.wiki/wiki/Zotero).

# Backgrounds

- GDM : gnome-shell is patched (overlay in `configuration.nix`, see [here](https://discourse.nixos.org/t/unable-to-change-background-in-gdm/33563/4)) to display `/var/lib/login-background/background.png`, a random image of `assets/login_images/` chosen at each boot.
- grub : a random [minegrub](https://github.com/Lxtharia/minegrub-theme) background is chosen at each boot, for the next one.

# Wifi 802.1X (inria-interne, eduroam)

Since 26.05, `wpa_supplicant` runs sandboxed (`ProtectHome=yes`) and can't read the CA certificates stored in `/home` : the connection fails with `Failed to load root certificates`. The certificates are kept out of this repo, in `/etc/nixos/wifi-certs/` :

```shell
sudo mkdir -p /etc/nixos/wifi-certs
sudo cp <inria CA chain>.pem /etc/nixos/wifi-certs/inria-intern.pem
sudo cp ~/.config/cat_installer/ca.pem /etc/nixos/wifi-certs/eduroam.pem
nmcli connection modify inria-interne 802-1x.ca-cert /etc/nixos/wifi-certs/inria-intern.pem
nmcli connection modify eduroam 802-1x.ca-cert /etc/nixos/wifi-certs/eduroam.pem
```

# Xsession

The description can be found [here](https://gist.github.com/bennofs/bb41b17deeeb49e345904f2339222625).
