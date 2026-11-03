# Desktop : the login (GDM), the sway session (default) and the i3 one (no GNOME desktop), their tools, sound, fonts, portals, notifications.
# Their home config (i3/, sway/, waybar/, polybar/...) is linked by install.sh.
{ config, lib, pkgs, myConf, ... }:

let
  # my_script : the commands of i3 / sway and their bars, from this repository (../../my_script/)
  my_script = pkgs.callPackage ../../my_script { };

  # login background images, from this repository
  LOGIN_IMAGES = ../../assets/login_images;
  # the login background displayed by the patched gnome-shell (see the overlay)
  LOGIN_BACKGROUND = "/var/lib/login-background/background.png";
  # script to pick a login background at each boot (randomly choose one of the login images)
  myLoginScript = pkgs.writeShellScript "my-login-script.sh" ''
    IMG=$(ls "${LOGIN_IMAGES}" | shuf -n 1)
    cp "${LOGIN_IMAGES}/$IMG" "${LOGIN_BACKGROUND}"
  '';
in
{
  # ------------------------------ LOGIN (GDM) ------------------------------
  # gdm always uses wayland since GNOME 50 (the "wayland" option was removed in 26.05)
  services.displayManager.gdm.enable = true;
  # sway is the session chosen by default at the login (i3 stays in the list of GDM)
  services.displayManager.defaultSession = "sway";

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

  # login background : gnome-shell (the GDM greeter) patched to display LOGIN_BACKGROUND, changed at each boot
  nixpkgs.overlays = [
    (self: super: {
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

  # ------------------------------ GNOME PIECES ------------------------------
  # the GNOME desktop itself is not installed (never used : only GDM, sway and i3), only the pieces used outside it
  services.gnome.gnome-keyring.enable = true; # password store (vpn, ssh keys...), unlocked at the login (login PAM)
  services.gvfs.enable = true; # nautilus : trash, phones (mtp), network shares
  services.hardware.bolt.enable = true; # authorize the thunderbolt dock
  services.upower.enable = true; # battery level (waybar, polybar)
  services.power-profiles-daemon.enable = true; # power modes (powerprofilesctl)
  programs.dconf.enable = true; # settings of the gtk apps
  # ssh keys : the ssh-agent of programs.ssh.startAgent, not the one of the keyring ; passphrases asked in a window
  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh.askPassword = "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";

  # ------------------------------ SWAY (default session) ------------------------------
  # config : sway/config of the repo (shares i3/common.conf), bar : waybar/, screens : kanshi/
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # gtk apps get the session environment
    extraPackages = with pkgs; [
      waybar # bar
      kanshi # screen profiles
      swayidle # lock after 2 min (my_script lock)
      grim slurp # screenshots
      wl-clipboard cliphist # clipboard history (wl-paste --watch cliphist store in sway/config)
    ];
  };
  # electron apps (vscode, discord, obsidian...) run natively on wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ------------------------------ I3 (X session) ------------------------------
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
        dunst # notifications (started by D-Bus at the first one, see services.dbus.packages)
        libnotify # notify-send
        polkit_gnome # password prompt of the GUI apps needing root (started by i3)

        i3lock-color
        brightnessctl
        my_script
      ];
    };
  };
  services.libinput.enable = true; # touchpad
  # autorandr (screen profiles of i3)
  services.autorandr.enable = true;
  # an unknown screen (video projector...) is turned on at the right of the laptop, without any workspace
  # (same fallback as i3/screen_management.py)
  services.autorandr.defaultTarget = "horizontal";
  # clipboard history of i3 (my_script clipboard)
  services.greenclip.enable = true;

  # ------------------------------ SHARED BY SWAY AND I3 ------------------------------
  # notifications : dunst is started by D-Bus at the first notification (config : dunst/dunstrc of the repo)
  services.dbus.packages = [ pkgs.dunst ];
  systemd.packages = [ pkgs.dunst ];
  # the polkit agent (password prompt of the GUI apps) is started from /run/current-system/sw/libexec
  environment.pathsToLink = [ "/libexec" ];

  # portals : file chooser, open with, screen sharing (wlr, on sway)
  xdg.portal = {
    enable = true;
    # the gnome portal needs a running GNOME session : gtk (file chooser...) and wlr (screen sharing, sway) are enough
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };
  xdg.portal.wlr.enable = true;

  # default apps
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

  # graphics (hardware.opengl was renamed hardware.graphics in 24.11)
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.mesa ];
  hardware.graphics.enable32Bit = true;

  # sound : pipewire (pulseaudio and alsa apps go through it, pactl / pamixer are only clients)
  # no sound but a "Dummy Output" : the card profile is "off" in ~/.local/state/wireplumber/default-profile,
  # choose another one in pavucontrol (Configuration tab), wireplumber remembers it
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.tinos
  ];
}
