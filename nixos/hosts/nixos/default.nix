# the standard work station (windows, fedora and nixos, see the README)
# for a new machine : copy this folder as hosts/<hostname>/, replace hardware-configuration.nix by the
# generated one (nixos-generate-config) and add the host in flake.nix
{
  imports = [ ./hardware-configuration.nix ];

  # load the intel graphics driver before the /home password (early KMS) : the display link of the dock
  # (Dell WD22TB4), set up at power on, is torn down if i915 doesn't use it within 12s (thunderbolt
  # dprx_timeout), and i915 was loaded after the password, so the dock screens stayed black after a slow login
  boot.initrd.kernelModules = [ "i915" ];

  # pc relative information, used by configuration.nix (named myConf to not shadow the module "config" argument)
  _module.args.myConf = {
    USER_NAME = "clahoche";
    KEYBOARD_LAYOUT = "fr";
    DISK_ENCRYPTION = true; # LUKS encrypted /home
  };
}
