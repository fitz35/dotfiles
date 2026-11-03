# The applications : the ones of the user, then the system tools. Search one : nix search nixpkgs <name>
# (the tools of the desktop, like rofi or waybar, are in desktop.nix ; the per-project tools go in a flake dev shell)
{ config, lib, pkgs, myConf, ... }:

{
  users.users.${myConf.USER_NAME}.packages = with pkgs; [
    firefox
    chromium
    thunderbird
    vscode
    zed-editor
    tree
    zotero
    discord
    unzip
    nautilus # file manager
    evince
    libreoffice
    spotify
    zoom-us # video conference

    inkscape # image viewer

    simplescreenrecorder # screen recorder

    vlc # video player

    kdePackages.okular # pdf viewer

    obsidian # note taking

    warp-terminal

    xmind

    texliveFull

    cups # printer
    lshw # hardware info
    iotop # list process with high io usage
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    gedit
    git
    git-lfs
    htop
    fastfetch # neofetch replacement (neofetch was removed in 26.05)
    networkmanagerapplet
    openconnect # vpn (also used by ~/Documents/certificat/inria-intern/connect_to_vpn.sh, until it's retired)
    openssl
    direnv
    gcc
    usbutils
    appimage-run
    gparted
    python3 # scripting (add no packages here, use dev shell instead)
    lsof # list open files

    # open xdg utilities (open default app for exemple), the portals are in xdg.portal
    xdg-utils
    xdg-launch

    mesa # opengl
    mesa-demos
  ];
}
