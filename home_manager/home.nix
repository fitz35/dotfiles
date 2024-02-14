{config, perso_config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${config.USER_NAME}";
  home.homeDirectory = "/home/${config.USER_NAME}";

  # ------------------ Bash ------------------
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      
    '';
  };

  # Packages that should be installed to the user profile.
  home.packages = [
    # ! WARNING ! # Use this wisely, prefer using configuration.nix
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ------------------ Hyprland ------------------
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # ............... Monitors ...............
    monitors = [
      "${config.BUILT_IN_MONITOR},preferred,0x0,1"


      # Default
      ",preferred,auto,1"
    ];

    # ............... Workspaces ...............


    # ............... Keybindings ...............
    
    bindm = [
      # mouse movements
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    # ............... inputs ...............
    input = {
        kb_layout = config.KEYBOARD_LAYOUT;

        follow_mouse = 1;

        touchpad = {
            natural_scroll = true;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };

  };
}