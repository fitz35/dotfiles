# the standard work station (windows, fedora and nixos, see the README)
# for a new machine : copy this folder as hosts/<hostname>/, replace hardware-configuration.nix by the
# generated one (nixos-generate-config) and add the host in flake.nix
{
  imports = [ ./hardware-configuration.nix ];

  # pc relative information, used by configuration.nix (named myConf to not shadow the module "config" argument)
  _module.args.myConf = {
    USER_NAME = "clahoche";
    KEYBOARD_LAYOUT = "fr";
    DISK_ENCRYPTION = true; # LUKS encrypted /home
  };
}
