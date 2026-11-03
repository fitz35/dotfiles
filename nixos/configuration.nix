# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

# myConf (user name, keyboard...) comes from hosts/<hostname>/default.nix
{ config, lib, pkgs, inputs, options, myConf, ... }:

let
  # efi mount point :
  EFI_MOUNTPOINT = "/boot/efi";

  # my_script
  my_script = inputs.my_personnal_script.packages.x86_64-linux.default;

  # login background images, from this repository
  LOGIN_IMAGES = ../assets/login_images;
  # the login background displayed by the patched gnome-shell (see the overlay)
  LOGIN_BACKGROUND = "/var/lib/login-background/background.png";
  # script to pick a login background at each boot (randomly choose one of the login images)
  myLoginScript = pkgs.writeShellScript "my-login-script.sh" ''
    IMG=$(ls "${LOGIN_IMAGES}" | shuf -n 1)
    cp "${LOGIN_IMAGES}/$IMG" "${LOGIN_BACKGROUND}"
  '';
  # script to pick a grub background at each boot (randomly choose a minegrub background, shown at the next boot)
  # nixos-rebuild copies the theme in /boot/theme, with the background chosen in the minegrub-theme options
  myGrubBackgroundScript = pkgs.writeShellScript "my-grub-background.sh" ''
    MINEGRUB="${inputs.minegrub-theme}"
    THEME_DIR="/boot/theme"
    [ -d "$THEME_DIR" ] || exit 0

    IMG=$(ls "$MINEGRUB/background_options/" | shuf -n 1)
    cp "$MINEGRUB/background_options/$IMG" "$THEME_DIR/background.png"
    cp "$MINEGRUB/background_options/$IMG" "/boot/background.png"

    # the backgrounds from 1.15 use the modern buttons (same rule as the minegrub update_theme.py)
    STYLE="classic"
    COLORS="#ffffa0 #3f3f28"
    if [[ "$IMG" =~ ^([0-9]+)\.([0-9]+) ]] && (( BASH_REMATCH[1] > 1 || (BASH_REMATCH[1] == 1 && BASH_REMATCH[2] >= 15) )); then
      STYLE="modern"
      COLORS="#ffffff #383838"
    fi
    cp "$MINEGRUB/button_options/$STYLE/"selected_item_*.png "$THEME_DIR/"
    # the first selected_item_color is the text, the second the shadow
    ${pkgs.gawk}/bin/awk -v colors="$COLORS" '
      BEGIN { split(colors, c, " ") }
      /selected_item_color = "/ { n++; sub(/selected_item_color = "[^"]+"/, "selected_item_color = \"" c[n] "\"") }
      { print }
    ' "$THEME_DIR/theme.txt" > "$THEME_DIR/theme.txt.new"
    mv "$THEME_DIR/theme.txt.new" "$THEME_DIR/theme.txt"
    echo "grub background for the next boot : $IMG ($STYLE buttons)"
  '';
  # hashed password
  #mkpasswd -m sha-512
  USER_HASHED_PASSWORD = "$6$bIx/kUybHUmZ.QMQ$VimchBjbSHObo3MdTcmf3rqAax/QdVWzofy8epjnSilKzKUUlMr5fE34q/f903023PQYUsXYwCJ/igeWw8k.y1";
in
{
  # the results of the hardware scan are imported by hosts/<hostname>/default.nix

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
      enableCryptodisk = myConf.DISK_ENCRYPTION; # LUKs encryption
      minegrub-theme = {
        enable = true;
        splash = "Lise is watching you !";
        # one of the files in https://github.com/Lxtharia/minegrub-theme/tree/main/background_options
        # only used until the next boot, then my-grub-background picks a random one at each boot
        background = "background_options/1.8  - [Classic Minecraft].png";
        boot-options-count = 7; # place the bottom bar under the 7th entry (same as the 0nyr fork)
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

  # don't print the kernel errors on screen at boot (harmless "ACPI BIOS Error (bug)" from the laptop firmware)
  # they are still available with `journalctl -b -p err`
  boot.consoleLogLevel = 3;

  # don't arm the hardware watchdog (iTCO_wdt) at reboot / power off : it only resets a hung reboot after 10min,
  # and prints "watchdog: watchdog0: watchdog did not stop!" at each shutdown
  systemd.settings.Manager.RebootWatchdogSec = "0";

  # ------------------------------------------
  # File system
  # ------------------------------------------
  
  # See hosts/<hostname>/hardware-configuration.nix

  # /bin/bash for the scripts using #!/bin/bash (nixos only provides /bin/sh)
  systemd.tmpfiles.rules = [ "L+ /bin/bash - - - - /run/current-system/sw/bin/bash" ];

  # ------------------------------------------
  # Divers setup
  # ------------------------------------------
  
  nixpkgs.config.allowUnfree = true; # allow unfree licence packages, like VSCode
  # enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # keep the / partition from filling up
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d"; # keep 2 weeks of generations to rollback
  };
  nix.settings.auto-optimise-store = true; # hard link identical files in the store
  boot.tmp.cleanOnBoot = true; # remove the leftovers (nix-shell.* folders...) of /tmp at each boot

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # bluetooth manager (blueberry was removed in 26.05)

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  # opengl (hardware.opengl was renamed hardware.graphics in 24.11)
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.mesa ];
  hardware.graphics.enable32Bit = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ------------------------------------------
  # GUI
  # ------------------------------------------

  

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable the X11 windowing system with i3 as window manager.
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.desktopManager.gnome = {
    enable = true;
    flashback.customSessions = [
      {
        wmName = "gnome-i3";
        wmLabel = "Gnome + i3";
        wmCommand = "i3"; # the screens are set by the sessionCommands, as for the i3 session
        enableGnomePanel = false;
      }
    ];
  };

  # ------------------------------ WINDOW MANAGER ------------------------------

  services.xserver = {
    enable = true;
    # at login, before the window manager : apply the autorandr profile and write the i3 screens
    # (i3/screens.conf), else i3 starts with the screens of the previous session ; and turn the num lock on
    # (an X session always starts with it off)
    displayManager.sessionCommands = ''
      ${pkgs.python3}/bin/python3 /home/${myConf.USER_NAME}/.config/i3/screen_management.py -e
      ${pkgs.numlockx}/bin/numlockx on
    '';
    xkb.layout = "${myConf.KEYBOARD_LAYOUT}";
    xkb.options = "eurosign:e,caps:escape";

    windowManager.i3 = {
      enable = true;

      extraPackages = with pkgs; [
        dmenu
        (polybar.override { i3Support = true; pulseSupport = true;})
        gnome-keyring # password management
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
        
        i3lock-color
        brightnessctl
        my_script
      ];
    };
  };


  # ------------------------------ DISPLAY MANAGER ------------------------------
  # gdm always uses wayland since GNOME 50 (the "wayland" option was removed in 26.05)
  services.displayManager.gdm.enable = true;
  # num lock on in the login screen (locked : else gdm restores the last state it saw)
  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
      remember-numlock-state = false;
    };
    locks = [
      "/org/gnome/desktop/peripherals/keyboard/numlock-state"
      "/org/gnome/desktop/peripherals/keyboard/remember-numlock-state"
    ];
  }];

  # Workaround to fix the ssh-askpass error when using plasma and gnome
  # https://discourse.nixos.org/t/have-gnome-plasma-at-the-same-time/40991
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass"; 

  # remove gnome apps
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
      ]) ++ (with pkgs; [
    gnome-music
    epiphany # web browser
    geary # email reader
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
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire (pulseaudio and alsa apps go through it, pactl / pamixer are only clients)
  # no sound but a "Dummy Output" : the card profile is "off" in ~/.local/state/wireplumber/default-profile,
  # choose another one in pavucontrol (Configuration tab), wireplumber remembers it
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # login background : gnome-shell patched to display LOGIN_BACKGROUND (changed at each boot by my-login-script)
 nixpkgs = {
  overlays = [
    (self: super: {
      # Override gnome-shell directly at top-level
      gnome-shell = super.gnome-shell.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          (let
            bg = LOGIN_BACKGROUND;
          in super.pkgs.writeText "bg.patch" ''
            --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
            +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
            @@ -234,2 +234,6 @@ #lockDialogGroup {
               background-color: $_gdm_bg;
            +  background-image: url('file://${bg}');
            +  background-size: cover;
            +  background-repeat: no-repeat;
            +  background-position: center center;
             }
          '')
        ];
      });
    })
  ];
};


  # Change the login background at each boot, before gdm reads it
  systemd.services.my-login-script = {
    description = "Change the login background randomly";
    wantedBy = [ "display-manager.service" ];
    before = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${myLoginScript}";
      User = "root";
      StateDirectory = "login-background"; # creates /var/lib/login-background
    };
  };

  # Change the grub background at each boot (grub is already displayed, so it is used at the next boot)
  systemd.services.my-grub-background = {
    description = "Change the grub background randomly for the next boot";
    wantedBy = [ "multi-user.target" ];
    unitConfig.RequiresMountsFor = "/boot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${myGrubBackgroundScript}";
      User = "root";
    };
  };

  # ------------------------------------------
  # Users
  # ------------------------------------------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  
  users.mutableUsers = false;
  users.users."${myConf.USER_NAME}" = {
    isNormalUser = true; # no privileges
    home = "/home/${myConf.USER_NAME}";       # Home directory path
    createHome = false;        # Don't create the home directory since it's a mount point
    # wheel : Enable ‘sudo’ for the user, 
    # disk : allow the user to use mount (command udisksctl)
    # docker : allow the user to use docker
    extraGroups = [ "wheel" "disk" "docker" "networkmanager" ]; 
    #mkpasswd -m sha-512
    hashedPassword = "${USER_HASHED_PASSWORD}";

    packages = with pkgs; [      
      firefox
      chromium
      thunderbird
      vscode
      zed-editor
      tree
      zotero
      discord
      unzip
      #minecraft
      nautilus # file manager
      evince
      libreoffice
      spotify
      zoom-us # video conference

      inkscape # image viewer

      simplescreenrecorder # screen recorder

      vlc # video player

      kdePackages.okular# pdf viewer

      openvpn

      obsidian # note taking

      warp-terminal

      xmind

      texliveFull

      cups # printer
      lshw # hardware info
      iotop # list process with high io usage
    ];
  };

  users.users."root" = {
    initialHashedPassword = "${USER_HASHED_PASSWORD}";
    hashedPassword = "${USER_HASHED_PASSWORD}";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget


  environment.systemPackages = with pkgs; [
    gnome-tweaks
    # stable packages here
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gedit
    git
    git-lfs
    htop
    fastfetch # neofetch replacement (neofetch was removed in 26.05)
    networkmanagerapplet
    openconnect # vpn
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

  # xdg portal setup
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdgOpenUsePortal = true;
  };

  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

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
  services.gnome.gcr-ssh-agent.enable = false;
  services.openssh.enable = true;

  # clipboard
  services.greenclip.enable = true; 

  # disk manager
  services.udisks2.enable = true;

  # docker
  virtualisation.docker.enable = true;
  # stop the containers with the daemon (default true : they are left running for a docker upgrade, then killed
  # at the end of the shutdown, slow and unclean for postgres, "Exited (255)")
  virtualisation.docker.liveRestore = false;

  # direnv and .envrc (https://github.com/nix-community/nix-direnv)
  programs.direnv.enable = true; # also adds the direnv hook to bash

  # Enable the SSH agent
  programs.ssh.startAgent = true;

  # https://github.com/Mic92/nix-ld > Enable the patch of some binaries which cannot be automatically patched
  programs.nix-ld.enable = true;

  # autorandr (screen management)
  services.autorandr.enable = true;
  # an unknown screen (video projector...) is turned on at the right of the laptop, without any workspace
  # (same fallback as i3/screen_management.py)
  services.autorandr.defaultTarget = "horizontal";
  
  # Enable polkit (https://nixos.wiki/wiki/Polkit) : privileges for the GUI apps (disks, network...)
  security.polkit.enable = true;

  # Enable Tailscale (https://tailscale.com/)
  services.tailscale.enable = true;


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

