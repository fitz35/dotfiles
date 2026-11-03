# System and services : nix itself, locale, network and VPN, bluetooth, ssh, docker, the dev tools.
{ config, lib, pkgs, myConf, ... }:

{
  # ------------------------------ NIX ------------------------------
  nixpkgs.config.allowUnfree = true; # unfree licences, like vscode
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # keep the / partition from filling up
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d"; # keep 2 weeks of generations to rollback
  };
  nix.settings.auto-optimise-store = true; # hard link identical files in the store
  # https://github.com/Mic92/nix-ld : run the binaries not built for nixos (vscode servers, pip wheels...)
  programs.nix-ld.enable = true;
  # /bin/bash for the scripts using #!/bin/bash (nixos only provides /bin/sh)
  systemd.tmpfiles.rules = [ "L+ /bin/bash - - - - /run/current-system/sw/bin/bash" ];

  # ------------------------------ LOCALE ------------------------------
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8"; # polybar needs en_US
  console.keyMap = "fr";

  # ------------------------------ NETWORK AND VPN ------------------------------
  networking.networkmanager.enable = true;
  # VPN : the "vpn inria" connection (AnyConnect, password in the keyring), toggled by my_script vpn_menu or nm-applet
  networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
  # Tailscale (https://tailscale.com/), also toggled by my_script vpn_menu
  services.tailscale.enable = true;
  # the user can run tailscale up / down without sudo (my_script vpn_menu)
  services.tailscale.extraSetFlags = [ "--operator=${myConf.USER_NAME}" ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # bluetooth manager (blueberry was removed in 26.05)

  # ------------------------------ SSH ------------------------------
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # ------------------------------ DISKS, PRIVILEGES ------------------------------
  services.udisks2.enable = true; # mount the USB keys without root (nautilus)
  # polkit (https://nixos.wiki/wiki/Polkit) : privileges for the GUI apps (disks, network...)
  security.polkit.enable = true;

  # ------------------------------ DEV TOOLS ------------------------------
  virtualisation.docker.enable = true;
  # stop the containers with the daemon (default true : they are left running for a docker upgrade, then killed
  # at the end of the shutdown, slow and unclean for postgres, "Exited (255)")
  virtualisation.docker.liveRestore = false;
  # direnv and .envrc (https://github.com/nix-community/nix-direnv), also adds the direnv hook to bash
  programs.direnv.enable = true;
}
