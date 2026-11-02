# flake.nix for /etc/nixos/
{
  description = "Custom Clement's NixOS configuration";

  inputs = {
       # WARNING : CAN'T DECLARE REUSABLE VARIABLES HERE

      # Official NixOS package source
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

      # Minecraft grub2 theme
      # official repo (the splash customization was fixed in https://github.com/Lxtharia/minegrub-theme/pull/35, no need of the 0nyr fork anymore)
      minegrub-theme.url = "github:Lxtharia/minegrub-theme";
      minegrub-theme.inputs.nixpkgs.follows = "nixpkgs"; # use our stable nixpkgs instead of its pinned unstable one
    
      my_personnal_script.url = "github:fitz35/my_personnal_script";
      my_personnal_script.inputs.nixpkgs.follows = "nixpkgs";
    };

  outputs = {nixpkgs, ...} @ inputs: {
    # replace whatever comes after nixosConfigurations with your hostname.
    # My laptop configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { _module.args.inputs = inputs; } # pass "inputs" to configurtion.nix, making available myscript into the configuration
        ./configuration.nix
        inputs.minegrub-theme.nixosModules.default
      ];
    };
  };
}