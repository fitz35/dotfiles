# The applications : the ones of the user, then the system tools. Search one : nix search nixpkgs <name>
# (the tools of the desktop, like rofi or waybar, are in desktop.nix ; the per-project tools, like LaTeX or a
# compiler version, go in a flake dev shell of the project)
{ config, lib, pkgs, myConf, ... }:

{
  users.users.${myConf.USER_NAME}.packages = with pkgs; [
    # web and mail
    firefox
    chromium
    thunderbird

    # code
    vscode
    zed-editor
    warp-terminal

    # notes and documents
    obsidian
    zotero
    libreoffice
    xmind
    evince # pdf
    kdePackages.okular # pdf (annotations)

    # communication
    discord
    zoom-us

    # media
    spotify
    vlc
    inkscape # vector drawing
    simplescreenrecorder # screen recorder (X only : works in i3, not in sway)

    # files
    nautilus
    unzip
    tree

    # system
    lshw # hardware info
    iotop # the processes with a high io usage
  ];

  environment.systemPackages = with pkgs; [
    # editors (vim : always there to fix a config)
    vim
    gedit

    # command line
    git
    git-lfs
    wget
    htop
    fastfetch
    lsof # the open files
    usbutils # lsusb
    openssl

    # network
    networkmanagerapplet # nm-applet (sway and i3)
    openconnect # vpn (also used by ~/Documents/certificat/inria-intern/connect_to_vpn.sh, until it's retired)

    # dev (the rest in the dev shells of the projects)
    gcc
    python3 # scripting (no python packages here)
    appimage-run

    # disks
    gparted

    # desktop integration (open the default app...), the portals are in desktop.nix
    xdg-utils
    xdg-launch

    # graphics check (glxinfo, glxgears)
    mesa-demos
  ];
}
