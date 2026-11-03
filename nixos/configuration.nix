# The NixOS configuration shared by all the machines : the user and the modules (one per topic, in modules/).
# The machine specific part (hardware, user name, keyboard...) is in hosts/<hostname>/, see flake.nix.
{ config, lib, pkgs, inputs, options, myConf, ... }:

let
  # hashed password
  #mkpasswd -m sha-512
  USER_HASHED_PASSWORD = "$6$bIx/kUybHUmZ.QMQ$VimchBjbSHObo3MdTcmf3rqAax/QdVWzofy8epjnSilKzKUUlMr5fE34q/f903023PQYUsXYwCJ/igeWw8k.y1";
in
{
  imports = [
    ./modules/boot.nix # grub (minegrub theme), the boot console, the shutdown
    ./modules/desktop.nix # login (GDM), sway and i3, sound, fonts, portals, notifications
    ./modules/services.nix # nix, locale, network and VPN, ssh, docker, dev tools
    ./modules/packages.nix # the applications
  ];

  users.mutableUsers = false;
  users.users."${myConf.USER_NAME}" = {
    isNormalUser = true; # no privileges
    home = "/home/${myConf.USER_NAME}";       # Home directory path
    createHome = false;        # Don't create the home directory since it's a mount point
    # wheel : Enable ‘sudo’ for the user, 
    # docker : allow the user to use docker
    extraGroups = [ "wheel" "docker" "networkmanager" ]; 
    #mkpasswd -m sha-512
    hashedPassword = "${USER_HASHED_PASSWORD}";
  };

  users.users."root" = {
    initialHashedPassword = "${USER_HASHED_PASSWORD}";
    hashedPassword = "${USER_HASHED_PASSWORD}";
  };

  # The NixOS release of the first install of this system : the default settings for stateful data (file locations,
  # database versions...). Leave it, even after upgrading (see `man configuration.nix`).
  system.stateVersion = "23.11";
}
