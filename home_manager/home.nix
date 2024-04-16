{pkgs, perso_config, inputs, ... }:
let
  my_script = inputs.my_personnal_script.packages.x86_64-linux.default;
  # default browser :
  DEFAULT_BROWSER = "firefox";
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

  # Make the default browser the default application for the following mime types.
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      # pdf
      "application/pdf" = ["${pkgs.okular}"];
      # web link
      "text/html" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/http" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/https" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/about" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/unknown" = ["${DEFAULT_BROWSER}.desktop"];
    };
    defaultApplications = {
      # pdf
      "application/pdf" = ["${pkgs.okular}"];
      # web link
      "text/html" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/http" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/https" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/about" = ["${DEFAULT_BROWSER}.desktop"];
      "x-scheme-handler/unknown" = ["${DEFAULT_BROWSER}.desktop"];
    };
  };

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
}