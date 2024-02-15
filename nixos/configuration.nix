# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, inputs, options, ... }:

let
  # efi mount point :
  EFI_MOUNTPOINT = "/boot/efi";
  # windows mount point :
  WINDOWS_MOUNTPOINT = "/mnt/windows";
  # default browser :
  DEFAULT_BROWSER = "firefox";

  # my_script
  my_script = inputs.my_personnal_script.packages.x86_64-linux.default;

  # script to generate a background each login (randomly choose an image from /etc/nixos/login_images/)
   # Define the script using writeShellScript
  myLoginScript = pkgs.writeShellScript "my-login-script.sh" ''
    #!/bin/sh
    # Select a random image from /etc/nixos/login_images/ and copy it to /etc/nixos/
    IMG=$(ls /etc/nixos/login_images/ | shuf -n 1)
    cp "/etc/nixos/login_images/$IMG" "/etc/nixos/background.png"
  '';
  # hashed password
  #mkpasswd -m sha-512
  USER_HASHED_PASSWORD = "$6$bIx/kUybHUmZ.QMQ$VimchBjbSHObo3MdTcmf3rqAax/QdVWzofy8epjnSilKzKUUlMr5fE34q/f903023PQYUsXYwCJ/igeWw8k.y1";
  # config
  config = import ./config_nix.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    
  # ------------------------------------------
  # Bootloader
  # ------------------------------------------

  # Use GRUB as bootloader
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false; # set to true if needed
      device = "nodev";
      useOSProber = true;
      enableCryptodisk = config.DISK_ENCRYPTION; # LUKs encryption
      minegrub-theme = {
        enable = true;
        splash = "Lise is watching you !";
      };
      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';
    };
    efi = {
      efiSysMountPoint = "${EFI_MOUNTPOINT}"; # adjust if your mount point differs
      canTouchEfiVariables = true;
    };
  };

  # ------------------------------------------
  # File system
  # ------------------------------------------
  
  # See hardware_configuration.nix !!!!!!!!

  # ------------------------------------------
  # Divers setup
  # ------------------------------------------
  
  nixpkgs.config.allowUnfree = true; # allow unfree licence packages, like VSCode
  # enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  # opengl
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];
  hardware.opengl.driSupport32Bit = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # ------------------------------------------
  # GUI
  # ------------------------------------------

  # Hyprland
  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #};
  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable the X11 windowing system with i3 as window manager.
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
  services.xserver = {
    enable = true;
    layout = "${config.KEYBOARD_LAYOUT}";
    xkbOptions = "eurosign:e,caps:escape";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    desktopManager = {
      xterm.enable = false;
      gnome.enable = true; # enable gnome
    };

    # ------------------------------ SESSIONS ------------------------------

    displayManager.defaultSession = "none+myI3";
    displayManager.session = [
      {
        manage = "window";
        name = "myI3";
        # start i3 in debug mode
        #start = ''sh /home/${config.USER_NAME}/.config/i3/generate_i3_config.sh & exec i3 --shmlog-size=26214400'';
        # start i3 in normal mode
        start = ''sh /home/${config.USER_NAME}/.config/i3/generate_i3_config.sh & exec i3'';
      }
    ];
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = builtins.readFile ./xmonad.hs;
    };
    windowManager.i3 = {
      enable = true;

      extraPackages = with pkgs; [
        i3status
        dmenu
        (polybar.override { i3Support = true; pulseSupport = true;})
        bc
        kitty
        flameshot # screenshot
        feh # wallpaper
        rofi # menu

        pulseaudio # audio
        pamixer # audio
        pavucontrol # audio
        playerctl # media keys
        zscroll # polybar

        xss-lock # screen saver
        xautolock # screen saver
        
        i3lock-color
        brightnessctl
        # bluetooth manager
        blueberry
        my_script

        python3
      ];
    };


    # ------------------------------ DISPLAY MANAGER ------------------------------
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    #videoDrivers = [ "nvidia" ];
    #displayManager.defaultSession = "none+i3";
  };

  # remove gnome apps
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
      ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-calculator
    yelp # help viewer
    gnome-maps
    gnome-weather
    gnome-contacts
    simple-scan
  ]);
  
  # configure console keymap
  console = {
    keyMap = "fr";
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [
      "FiraCode" "JetBrainsMono"
    ]; })
  ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire
  # If alsa doesnt work, make a fresh install of pulseaudio and alsa
  # cf https://discourse.nixos.org/t/cant-get-alsa-nixos-working/644
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # login background

 nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (let
                bg = "/etc/nixos/background.png";

              # to apply the patch, this line is needed : @@ -15,4 +15,8 @@ $_gdm_dialog_width: 23em;
              # the 15,4 tell that the patch is applied at line 15, and remove 4 lines (including the line 15)
              # the 15,8 tell that the patch is applied at line 15, add 8 lines (including the line 15)
              in pkgs.writeText "bg.patch" ''
                --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                @@ -15,4 +15,8 @@ $_gdm_dialog_width: 23em;
                 /* Login Dialog */
                 .login-dialog {
                   background-color: $_gdm_bg;
                +  background-image: url('file://${bg}');
                +  background-size: cover;
                +  background-repeat: no-repeat;
                +  background-position: center center;
                 }
              '')
            ];
          });
        });
      })
    ];
  };

  # Ensure the script to change the login background runs on user login
  systemd.services.my-login-script = {
    description = "Change the login background randomly";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${myLoginScript}";
      User = "root";
    };
  };

  # ------------------------------------------
  # Users
  # ------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  
  users.mutableUsers = false;
  users.users."${config.USER_NAME}" = {
    isNormalUser = true; # no privileges
    home = "/home/${config.USER_NAME}";       # Home directory path
    createHome = false;        # Don't create the home directory since it's a mount point
    # wheel : Enable ‘sudo’ for the user, 
    # audio : allow the user to manage audio (!!!!WARN!!! it use pulseaudio, not alsa)
    # disk : allow the user to use mount (command udisksctl)
    # docker : allow the user to use docker
    extraGroups = [ "wheel" "disk" "docker" "networkmanager" ]; 
    #mkpasswd -m sha-512
    hashedPassword = "${USER_HASHED_PASSWORD}";

    packages = with pkgs; [
      home-manager
      
      firefox
      chromium
      thunderbird
      vscode
      tree
      zotero
      discord
      minecraft
      gnome.gnome-terminal
      gnome.nautilus # file manager
      gnome.gnome-tweaks
      gnome.evince
      libreoffice
      spotify
      zoom-us # video conference
      playerctl # media keys

      stacer # system monitor

      inkscape # image viewer

      simplescreenrecorder # screen recorder

      vlc # video player

      okular # pdf viewer

      openvpn

      my_script

      obsidian # note taking
    ];
  };

  # Make the default browser the default application for the following mime types.
  xdg.mime = {
    enable = true;
    defaultApplications = {
      # pdf
      "application/pdf" = "okular.desktop";
      # web link
      "text/html" = "${DEFAULT_BROWSER}.desktop";
      "x-scheme-handler/http" = "${DEFAULT_BROWSER}.desktop";
      "x-scheme-handler/https" = "${DEFAULT_BROWSER}.desktop";
      "x-scheme-handler/about" = "${DEFAULT_BROWSER}.desktop";
      "x-scheme-handler/unknown" = "${DEFAULT_BROWSER}.desktop";
    };
  };
  users.users."root" = {
    initialHashedPassword = "${USER_HASHED_PASSWORD}";
    hashedPassword = "${USER_HASHED_PASSWORD}";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # obsidian dependency
  ];
 

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    # stable packages here
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gedit
    git
    htop
    neofetch
    networkmanagerapplet
    openssl
    direnv
    gcc
    usbutils
    appimage-run
    gparted
    python3 # scripting (add no packages here, use dev shell instead)
    lsof # list open files
  

    mesa # opengl
    mesa-demos
  ];  

  # ------------------------------------------
  # Services
  # ------------------------------------------

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # don’t shutdown when power button is short-pressed
  # https://nixos.wiki/wiki/Logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # clipboard
  services.greenclip.enable = true; 

  # disk manager
  services.udisks2.enable = true;

  # docker
  virtualisation.docker.enable = true;

  # direnv and .envrc (https://github.com/nix-community/nix-direnv)
  programs.direnv.enable = true;
  programs.bash.shellInit = ''
    eval "$(direnv hook bash)"
  ''; # add direnv to bashrc

  # Enable the SSH agent
  programs.ssh.startAgent = true;

  # https://github.com/Mic92/nix-ld > Enable the patch of some binaries which cannot be automatically patched
  programs.nix-ld.enable = true;

  # autorandr (screen management)
  services.autorandr.enable = true;
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

