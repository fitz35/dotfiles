# Dotfiles

The NixOS system (`nixos/`) and the home configuration (sway / i3, bars, screens...) of my machines. Sway is the default session, i3 (X) stays available at the login.

Work in progress : [PLAN.md](PLAN.md) (my_script merged here, Inria VPN in NetworkManager, Sway next to i3).

| Folder | Content |
| --- | --- |
| `nixos/` | the NixOS flake : system, packages, services. One folder per machine in `nixos/hosts/` |
| `i3/` | i3 config (`common.conf` is shared with sway), screen management (autorandr profiles, workspaces per screen) |
| `sway/`, `waybar/`, `kanshi/` | sway config (Wayland part), its bar, its screen profiles |
| `polybar/` | the i3 bar |
| `assets/` | wallpapers (`background_image/`) and login backgrounds (`login_images/`) |
| `my_script/` | the commands of i3 and polybar (rofi menus, lock, wallpaper, polybar modules), installed by nixos |
| `fonts/`, `greenclip/`, `dunst/`, `zed/`, `flameshot/` | custom font, clipboard manager config, notifications style, zed (with the VS Code look), flameshot (grim adapter) |
| `ssh/` | ssh hosts (the private ones stay local) |
| `claude/` | Claude Code : global `CLAUDE.md` (token hygiene), `settings.json` (model, effort), the Stop hook reminding to open a new agent window above 100k tokens of context |
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
   - NAS : `sh nixos/nas_setup.sh <tailscale name of the NAS>` once Tailscale is logged in (see [nixos/README.md](nixos/README.md#nas)).
   - vpn : create the NetworkManager connection once with `nm-connection-editor` (Inria : AnyConnect, gateway `vpn.inria.fr/all`, CA certificate kept outside the repository), the password is saved in the keyring.
   - screens : add the new screen setups to `kanshi/config` (sway) and autorandr (i3), see [i3/README.md](i3/README.md#multiscreen).

Then, to apply a change of `nixos/` : `sh nixos/update_config.sh`, and to update the packages : `sh nixos/flake_update.sh` then `sh nixos/update_config.sh`. The home configuration is linked, a change is applied by reloading sway / i3 (`$mod+Shift+c`).

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
