# the standard work station : Dell Precision 3581 (i7-13700H, Intel GPU + NVIDIA RTX A1000), windows, fedora and nixos
# (see the README)
# for a new machine : copy this folder as hosts/<hostname>/, replace hardware-configuration.nix by the
# generated one (nixos-generate-config), adapt the hardware part below, and add the host in flake.nix
{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # pc relative information, used by configuration.nix (named myConf to not shadow the module "config" argument)
  _module.args.myConf = {
    USER_NAME = "clahoche";
    KEYBOARD_LAYOUT = "fr";
    DISK_ENCRYPTION = true; # LUKS encrypted /home
  };

  # ------------------------------ GPU ------------------------------
  # load the intel graphics driver before the /home password (early KMS) : the display link of the dock
  # (Dell WD22TB4), set up at power on, is torn down if i915 doesn't use it within 12s (thunderbolt
  # dprx_timeout), and i915 was loaded after the password, so the dock screens stayed black after a slow login
  boot.initrd.kernelModules = [ "i915" ];
  # hardware video decoding of the Intel GPU (VA-API, check : vainfo) : less battery for the videos
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  # the NVIDIA RTX A1000 has no screen output (laptop, DP, HDMI, dock are all on the Intel GPU) and isn't used :
  # no driver, and the kernel may power the driverless card down (power/control=auto, else it stays on).
  # Check : cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status (suspended) and the battery energy-rate ;
  # to use it again, remove these lines
  boot.blacklistedKernelModules = [ "nouveau" ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"
  '';

  # ------------------------------ FIRMWARE, THERMAL ------------------------------
  # firmware updates (BIOS, dock WD22TB4...) : fwupdmgr get-updates, then fwupdmgr update (by hand)
  services.fwupd.enable = true;
  # Intel thermal management (avoids the hard throttling)
  services.thermald.enable = true;
}
