# Dotfiles

The NixOS system (`nixos/`) and the home configuration (i3, polybar, screens...) of my machines.

Work in progress : [PLAN.md](PLAN.md) (my_script merged here, Inria VPN in NetworkManager, Sway next to i3).

| Folder | Content |
| --- | --- |
| `nixos/` | the NixOS flake : system, packages, services. One folder per machine in `nixos/hosts/` |
| `i3/` | i3 config, screen management (autorandr profiles, workspaces per screen) |
| `polybar/` | the bar |
| `assets/` | wallpapers (`background_image/`) and login backgrounds (`login_images/`) |
| `my_script/` | the commands of i3 and polybar (rofi menus, lock, wallpaper, polybar modules), installed by nixos |
| `fonts/`, `greenclip/`, `dunst/` | custom font, clipboard manager config, notifications style |
| `ssh/`, `openvpn/` | ssh hosts and vpn connections (secrets stay local) |
| `nix/` | dev shells (python, swh mining) |
| `install.sh` | links the home configuration in `~` |

## New machine

1. Install NixOS from the ISO, as root (`sudo -i` : nix refuses a git repository owned by another user) : partition and mount the disks in `/mnt` (see [Workstation](#workstation)), then generate the hardware configuration : `nixos-generate-config --root /mnt`.
2. Clone this repository and add the machine : copy `nixos/hosts/nixos/` as `nixos/hosts/<hostname>/`, replace its `hardware-configuration.nix` by `/mnt/etc/nixos/hardware-configuration.nix`, adapt `default.nix` (user name, keyboard, encryption, and `networking.hostName = "<hostname>";` if it isn't `nixos`), add the host in `nixos/flake.nix`, then `git add` the new files (a flake only sees the files known by git).
3. Install : `sudo nixos-install --flake ./nixos#<hostname>`, then reboot.
4. Clone the repository in `~/Documents/github/dotfiles` and run `./install.sh` (an existing file is kept as `.bak`).
5. The local secrets, not in this repository :
   - ssh key for github : generate a [key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for each OS and add it to github (test : `ssh -T git@github.com`). The private ssh hosts are added in `~/.ssh/config` (copied once from `ssh/config`).
   - wifi 802.1X certificates in `/etc/nixos/wifi-certs/` (see [nixos/README.md](nixos/README.md#wifi-8021x-inria-interne-eduroam)).
   - vpn : `.env` and `pass.txt` of each `~/.config/openvpn/client/*/` (from the `.bk` templates).
   - screens : save the new screen setups with autorandr (see [i3/README.md](i3/README.md#multiscreen)).

Then, to apply a change of `nixos/` : `sh nixos/update_config.sh`, and to update the packages : `sh nixos/flake_update.sh` then `sh nixos/update_config.sh`. The home configuration is linked, a change is applied by reloading i3 (`$mod+Shift+c`).

## Workstation

The standard work station has 3 OS on the same disk :

| Partition | Content |
| --- | --- |
| EFI (vfat) | shared by the 3 OS, mounted in `/boot/efi` |
| Windows (BitLocker) | Windows |
| fedora (ext4) | Fedora (fallback) |
| nixos (ext4) | NixOS (`/` and `/boot`) |
| home (LUKS, ext4) | `/home`, shared by Fedora and NixOS (`DISK_ENCRYPTION` in `nixos/hosts/nixos/default.nix`) |

The NixOS grub (minegrub theme) boots the 2 others with os-prober.

> WARN : as `/home` is shared, the `~/.config` links of this repo are used by Fedora and NixOS : what is linked there must work on both (no `/nix/store` path)
