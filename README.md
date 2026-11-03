# Installation files

## Workstation

The standard work station has 3 OS on the same disk :

| Partition | Content |
| --- | --- |
| EFI (vfat) | shared by the 3 OS, mounted in `/boot/efi` |
| Windows (BitLocker) | Windows |
| fedora (ext4) | Fedora |
| nixos (ext4) | NixOS (`/` and `/boot`) |
| home (LUKS, ext4) | `/home`, shared by Fedora and NixOS (`DISK_ENCRYPTION` and `HOME_PARTITION = "/dev/mapper/enc-home"` in `nixos/config_nix.nix`) |

The NixOS grub (minegrub theme) boots the 2 others with os-prober.

> WARN : as `/home` is shared, the `~/.config` links of this repo are used by Fedora and NixOS : what is linked there must work on both (no `/nix/store` path)

## ssh for github

generate a [key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for each os and add it to github. It will automatically add it each log in. To test connection : `ssh -T git@github.com`
