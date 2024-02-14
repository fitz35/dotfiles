{pkgs, perso_config, inputs, ... }:
let
  my_script = inputs.my_personnal_script.packages.x86_64-linux.default;

in 
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${perso_config.USER_NAME}";
  home.homeDirectory = "/home/${perso_config.USER_NAME}";

  # ------------------ Bash ------------------
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      
    '';
  };

  # Packages that should be installed to the user profile.
  home.packages = [
    # ! WARNING ! # Use this wisely, prefer using configuration.nix. Can be used for hyprland and display configuration
    my_script
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

  # ------------------ Hyprland -----------------------------------------------------------------------------
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # ............... Startup ...............
    exec-once = [
      "greenclip daemon"
      "flameshot"
    ];

    # ............... Monitors ...............
    monitors = [
      "${perso_config.BUILT_IN_MONITOR},preferred,0x0,1"


      # Default
      ",preferred,auto,1"
    ];

    # ............... layout ...............

    dwindle = {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = "yes"; # you probably want this
    };

    master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
    };

    # ............... Workspaces ...............


    # ............... Keybindings ...............
    
    bindm = [
      # mouse movements
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"

      # workspaces
      # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
      
    ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              "$mod, F${ws}, workspace, ${toString (x + 1 + 10)}"
              "$mod SHIFT, F${ws}, movetoworkspace, ${toString (x + 1 + 10)}"
            ]
          )
          10)
      );


    # ............... inputs ...............
    input = {
        kb_layout = perso_config.KEYBOARD_LAYOUT;

        follow_mouse = 1;

        touchpad = {
            natural_scroll = "yes";
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };

    # ............... Theme ...............
    general = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      col.inactive_border = "rgba(595959aa)";

      layout = "dwindle";

      # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      allow_tearing = false;
    };

    decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10;
        
        blur ={
            enabled = true;
            size = 3;
            passes = 1;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        col.shadow = "rgba(1a1a1aee)";
    };

    animations = {
        enabled = "yes";

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
    };

  };
}